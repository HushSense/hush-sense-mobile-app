import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Hedera WalletConnect wrapper backed by WalletConnect v2 infrastructure.
class HederaWalletConnect {
  HederaWalletConnect._internal();

  static final HederaWalletConnect _instance = HederaWalletConnect._internal();

  static const _namespace = 'hedera';
  static const _hederaMethods = <String>[
    'hedera_signTransaction',
    'hedera_signAndExecuteTransaction',
    'hedera_executeTransaction',
    'hedera_signAndExecuteQuery',
    'hedera_signMessage',
    'hedera_getNodeAddresses',
  ];

  static const _hederaEvents = <String>[
    'hedera_accountsChanged',
    'hedera_chainChanged',
  ];

  static const _userRejectedErrorCode = 5000;

  static const _mirrorNodeUrls = <String, String>{
    'mainnet': 'https://mainnet-public.mirrornode.hedera.com',
    'testnet': 'https://testnet.mirrornode.hedera.com',
    'previewnet': 'https://previewnet.mirrornode.hedera.com',
  };

  ReownAppKit? _appKit;
  SessionData? _session;
  final Dio _dio = Dio();
  final StreamController<ConnectionState> _stateController =
    StreamController<ConnectionState>.broadcast();
  Future<void>? _initializationFuture;

  String _network = 'testnet';
  String? _accountId;
  String? _walletName;

  static Future<void> initialize({String? network}) async {
    await _instance._initialize(network: network);
  }

  static Future<void> ensureInitialized({String? network}) async {
    await _instance._initialize(network: network);
  }

  Future<void> _initialize({String? network}) async {
    if (_appKit != null) {
      debugPrint('[HederaWalletConnect] Already initialized for network $_network');
      return;
    }

    final pending = _initializationFuture;
    if (pending != null) {
      debugPrint('[HederaWalletConnect] Initialization in progress, awaiting existing future');
      await pending;
      return;
    }

    _initializationFuture = _performInitialization(network: network);
    try {
      await _initializationFuture;
    } finally {
      _initializationFuture = null;
    }
  }

  Future<void> _performInitialization({String? network}) async {
    final projectId = _getEnv('WALLETCONNECT_PROJECT_ID');
    if (projectId == null || projectId.isEmpty) {
      throw HederaWalletConnectException(
        'Missing WALLETCONNECT_PROJECT_ID in environment configuration.',
      );
    }

    debugPrint('[HederaWalletConnect] Using project id: ${_maskProjectId(projectId)}');

    final metadata = PairingMetadata(
      name: _getEnv('DAPP_NAME') ?? 'HushSense',
      description:
          _getEnv('DAPP_DESCRIPTION') ?? 'HushSense Hedera integration',
      url: _getEnv('DAPP_URL') ?? 'https://hushsense.com',
      icons: <String>[
        _resolveIconUrl(_getEnv('DAPP_ICON_URL')),
      ],
    );

    final selectedNetwork =
        (network ?? _getEnv('HEDERA_NETWORK') ?? 'testnet').toLowerCase();

    debugPrint('[HederaWalletConnect] Initializing (network: $selectedNetwork)');

    try {
      _appKit = await ReownAppKit.createInstance(
        projectId: projectId,
        metadata: metadata,
      );
    } on ReownSignError catch (e) {
      debugPrint(
        '[HederaWalletConnect] Failed to create ReownAppKit instance (code: ${e.code}): ${e.message}',
      );
      rethrow;
    } on ReownCoreError catch (e) {
      debugPrint(
        '[HederaWalletConnect] Failed to create ReownAppKit instance (code: ${e.code}): ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[HederaWalletConnect] Failed to create ReownAppKit instance: $e');
      rethrow;
    }

    debugPrint('[HederaWalletConnect] ReownAppKit instance created');

    _network = _mirrorNodeUrls.containsKey(selectedNetwork)
        ? selectedNetwork
        : 'testnet';

    _appKit!.onSessionDelete.subscribe(
      (event) => _handleSessionClosed(reason: 'Session deleted by wallet'),
    );
    _appKit!.onSessionExpire.subscribe(
      (event) => _handleSessionClosed(reason: 'Session expired'),
    );

    _emitState(ConnectionState.disconnected());
    debugPrint('[HederaWalletConnect] Initialization complete');
  }

  static Future<AccountInfo> connect({String? preferredWallet}) async {
    return _instance._connect(preferredWallet: preferredWallet);
  }

  static Future<void> disconnect() async {
    await _instance._disconnect();
  }

  static bool isConnected() => _instance._session != null;

  static String? getAccountId() => _instance._accountId;

  static AccountInfo? getAccountInfo() {
    final session = _instance._session;
    final accountId = _instance._accountId;
    final walletName = _instance._walletName;
    final network = _instance._network;

    if (session == null || accountId == null || walletName == null) {
      return null;
    }

    return AccountInfo(
      accountId: accountId,
      walletName: walletName,
      network: network,
    );
  }

  static Future<double> getAccountBalance() async {
    return _instance._getAccountBalance();
  }

  static Future<HederaTransactionResult> signTransaction(
    HederaTransactionRequest request,
  ) async {
    return _instance._signTransaction(request);
  }

  static Future<List<AvailableWallet>> getAvailableWallets() async {
    return _instance._getAvailableWallets();
  }

  static Future<void> openPlayStore(String packageName) async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );
    if (!await url_launcher.launchUrl(url,
        mode: url_launcher.LaunchMode.externalApplication)) {
      throw NetworkException('Failed to open Play Store for $packageName');
    }
  }

  static Stream<ConnectionState> get connectionStateStream =>
      _instance._stateController.stream;

  Future<AccountInfo> _connect({String? preferredWallet}) async {
    debugPrint(
      '[HederaWalletConnect] connect invoked (preferred: ${preferredWallet ?? 'any'})',
    );

    final app = _appKit;
    if (app == null) {
      debugPrint('[HederaWalletConnect] connect aborted - not initialized');
      throw HederaWalletConnectException(
        'HederaWalletConnect.initialize must be called before connect.',
      );
    }

    _emitState(ConnectionState.connecting());
    debugPrint('[HederaWalletConnect] Requesting session from relay');

    final requiredNamespaces = <String, RequiredNamespace>{
      _namespace: RequiredNamespace(
        chains: <String>['$_namespace:$_network'],
        methods: _hederaMethods,
        events: _hederaEvents,
      ),
    };

    final connectResponse = await app.connect(
      requiredNamespaces: requiredNamespaces,
    );

    debugPrint(
      '[HederaWalletConnect] Session URI received: ${connectResponse.uri != null}',
    );

    if (connectResponse.uri != null) {
      await _launchWalletUri(connectResponse.uri!, preferredWallet);
    }

    try {
      debugPrint('[HederaWalletConnect] Awaiting wallet approval');
      final session = await connectResponse.session.future;
      if (session.namespaces[_namespace]?.accounts.isEmpty ?? true) {
        throw SessionException('Wallet did not expose any Hedera accounts.');
      }

      final fullAccount = session.namespaces[_namespace]!.accounts.first;
      final parsedAccount = _parseAccount(fullAccount);

      _session = session;
      _accountId = parsedAccount.accountId;
      _walletName = session.peer.metadata.name;

      debugPrint('[HederaWalletConnect] Session approved by ${_walletName ?? 'unknown'}');

      final info = AccountInfo(
        accountId: parsedAccount.accountId,
        walletName: _walletName!,
        network: parsedAccount.network,
      );

      _emitState(
        ConnectionState.connected(
          accountId: info.accountId,
          walletName: info.walletName,
          network: info.network,
        ),
      );

      return info;
    } on ReownSignError catch (e) {
      debugPrint('[HederaWalletConnect] Reown error during connect: $e');
      _handleSessionClosed();
      if (e.code == _userRejectedErrorCode) {
        throw UserRejectedConnectionException(e.message);
      }
      throw HederaWalletConnectException(e.message);
    } on ReownCoreError catch (e) {
      debugPrint('[HederaWalletConnect] Core error during connect: $e');
      _handleSessionClosed();
      throw HederaWalletConnectException(e.message);
    } catch (e) {
      debugPrint('[HederaWalletConnect] Unexpected error while connecting: $e');
      _handleSessionClosed();
      rethrow;
    }
  }

  Future<void> _disconnect() async {
    final app = _appKit;
    final session = _session;
    if (app == null || session == null) {
      return;
    }

    await app.disconnectSession(
      topic: session.topic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
    );

    _handleSessionClosed();
  }

  Future<double> _getAccountBalance() async {
    final accountId = _accountId;
    if (accountId == null) {
      throw NotConnectedException('No wallet connected');
    }

    final mirrorBase = _mirrorNodeUrls[_network] ?? _mirrorNodeUrls['testnet']!;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$mirrorBase/api/v1/accounts/$accountId',
      );
      final balance = response.data?['balance'] as Map<String, dynamic>?;
      final tinybars = balance?['balance'];
      if (tinybars is int) {
        return tinybars / 100000000; // tinybars -> HBAR
      }
      if (tinybars is String) {
        return double.parse(tinybars) / 100000000;
      }
      throw NetworkException('Unexpected balance payload');
    } on DioException catch (e) {
      throw NetworkException('Failed to load account balance: ${e.message}');
    }
  }

  Future<HederaTransactionResult> _signTransaction(
    HederaTransactionRequest request,
  ) async {
    final app = _appKit;
    final session = _session;
    final accountId = _accountId;
    if (app == null || session == null || accountId == null) {
      throw NotConnectedException('No wallet connected');
    }

    try {
      final result = await app.request(
        topic: session.topic,
        chainId: '$_namespace:$_network',
        request: SessionRequestParams(
          method: 'hedera_signTransaction',
          params: {
            'signerAccountId': '$_namespace:$_network:$accountId',
            'transactionBody': request.transactionBytes,
          },
        ),
      );

      if (result is Map && result['signatureMap'] is String) {
        return HederaTransactionResult(
          success: true,
          signedTransaction: result['signatureMap'] as String,
        );
      }

      return const HederaTransactionResult(
        success: false,
        errorMessage: 'Wallet returned an unexpected response',
      );
    } on ReownSignError catch (e) {
      if (e.code == 5000) {
        throw UserRejectedTransactionException(e.message);
      }
      return HederaTransactionResult(success: false, errorMessage: e.message);
    } on ReownCoreError catch (e) {
      return HederaTransactionResult(success: false, errorMessage: e.message);
    } catch (e) {
      return HederaTransactionResult(success: false, errorMessage: '$e');
    }
  }

  Future<List<AvailableWallet>> _getAvailableWallets() async {
    return const <AvailableWallet>[
      AvailableWallet(
        name: 'HashPack',
        packageName: 'app.hashpack.wallet',
        isInstalled: false,
      ),
      AvailableWallet(
        name: 'Blade Wallet',
        packageName: 'com.bladewallet.app',
        isInstalled: false,
      ),
      AvailableWallet(
        name: 'Kabila',
        packageName: 'com.kabila.wallet',
        isInstalled: false,
      ),
    ];
  }

  Future<void> _launchWalletUri(Uri uri, String? preferredWallet) async {
    debugPrint('[HederaWalletConnect] Launching wallet URI: $uri');
    // No per-wallet deep links yet; optionally use preferred wallet scheme.
    if (!await url_launcher.launchUrl(
      uri,
      mode: url_launcher.LaunchMode.externalApplication,
    )) {
      throw WalletNotFoundException(
        'Unable to open wallet. Please install a Hedera-compatible wallet.',
      );
    }
  }

  void _handleSessionClosed({String? reason}) {
    if (reason != null) {
      debugPrint('[HederaWalletConnect] Session closed: $reason');
    } else {
      debugPrint('[HederaWalletConnect] Session closed');
    }
    _session = null;
    _accountId = null;
    _walletName = null;
    _emitState(ConnectionState.disconnected());
  }

  void _emitState(ConnectionState state) {
    if (!_stateController.isClosed) {
      debugPrint(
        '[HederaWalletConnect] Emitting state: ${state.toDebugString()}',
      );
      _stateController.add(state);
    }
  }

  String? _getEnv(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _resolveIconUrl(String? icon) {
    if (icon == null || icon.isEmpty) {
      return 'https://hushsense.com/icon.png';
    }
    if (!icon.startsWith('http')) {
      debugPrint(
        '[HederaWalletConnect] Warning: DAPP_ICON_URL should be an https URL. Falling back to default icon.',
      );
      return 'https://hushsense.com/icon.png';
    }
    return icon;
  }

  String _maskProjectId(String projectId) {
    if (projectId.length <= 8) {
      return '****';
    }
    final prefix = projectId.substring(0, 4);
    final suffix = projectId.substring(projectId.length - 4);
    return '$prefix***$suffix';
  }

  static _ParsedAccount _parseAccount(String value) {
    final parts = value.split(':');
    if (parts.length < 3) {
      throw SessionException('Invalid account identifier: $value');
    }
    return _ParsedAccount(
      network: parts[1],
      accountId: parts[2],
    );
  }
}

class _ParsedAccount {
  const _ParsedAccount({required this.network, required this.accountId});

  final String network;
  final String accountId;
}

/// Account information from connected wallet.
class AccountInfo {
  final String accountId;
  final String walletName;
  final String network;

  const AccountInfo({
    required this.accountId,
    required this.walletName,
    required this.network,
  });
}

/// Available wallet information.
class AvailableWallet {
  final String name;
  final String packageName;
  final bool isInstalled;

  const AvailableWallet({
    required this.name,
    required this.packageName,
    required this.isInstalled,
  });
}

/// Connection state for wallet.
class ConnectionState {
  final bool isConnected;
  final bool isConnecting;
  final String? accountId;
  final String? walletName;
  final String? network;
  final String? errorMessage;

  const ConnectionState({
    required this.isConnected,
    this.isConnecting = false,
    this.accountId,
    this.walletName,
    this.network,
    this.errorMessage,
  });

  factory ConnectionState.disconnected() {
    return const ConnectionState(isConnected: false);
  }

  factory ConnectionState.connecting() {
    return const ConnectionState(isConnected: false, isConnecting: true);
  }

  factory ConnectionState.connected({
    required String accountId,
    required String walletName,
    required String network,
  }) {
    return ConnectionState(
      isConnected: true,
      accountId: accountId,
      walletName: walletName,
      network: network,
    );
  }

  String toDebugString() {
    return 'ConnectionState(isConnected: $isConnected, '
        'isConnecting: $isConnecting, accountId: ${accountId ?? 'null'}, '
        'walletName: ${walletName ?? 'null'}, network: ${network ?? 'null'}, '
        'error: ${errorMessage ?? 'null'})';
  }

  factory ConnectionState.error(String message) {
    return ConnectionState(
      isConnected: false,
      errorMessage: message,
    );
  }

  bool get hasError => errorMessage != null;
}

/// Transaction request for signing.
class HederaTransactionRequest {
  final String transactionId;
  final String transactionBytes;
  final String? memo;
  final double fee;

  const HederaTransactionRequest({
    required this.transactionId,
    required this.transactionBytes,
    this.memo,
    required this.fee,
  });
}

/// Result of transaction signing.
class HederaTransactionResult {
  final bool success;
  final String? signedTransaction;
  final String? errorMessage;

  const HederaTransactionResult({
    required this.success,
    this.signedTransaction,
    this.errorMessage,
  });
}

/// Exception classes for wallet operations.
class WalletNotFoundException implements Exception {
  final String message;
  WalletNotFoundException(this.message);
  @override
  String toString() => 'WalletNotFoundException: $message';
}

class WalletNotInstalledException implements Exception {
  final String walletName;
  WalletNotInstalledException(this.walletName);
  @override
  String toString() => 'WalletNotInstalledException: $walletName not installed';
}

class UserRejectedConnectionException implements Exception {
  final String message;
  UserRejectedConnectionException(this.message);
  @override
  String toString() => 'UserRejectedConnectionException: $message';
}

class UserRejectedTransactionException implements Exception {
  final String message;
  UserRejectedTransactionException(this.message);
  @override
  String toString() => 'UserRejectedTransactionException: $message';
}

class NotConnectedException implements Exception {
  final String message;
  NotConnectedException(this.message);
  @override
  String toString() => 'NotConnectedException: $message';
}

class SessionException implements Exception {
  final String message;
  SessionException(this.message);
  @override
  String toString() => 'SessionException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}

class HederaWalletConnectException implements Exception {
  final String message;
  HederaWalletConnectException(this.message);
  @override
  String toString() => 'HederaWalletConnectException: $message';
}
