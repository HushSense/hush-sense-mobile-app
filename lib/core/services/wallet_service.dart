import 'dart:async';
import 'package:flutter/foundation.dart';
import 'hedera_wallet_types.dart';

/// Service wrapper for Hedera WalletConnect functionality
/// Provides a clean interface for wallet operations with comprehensive error handling
class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  /// Stream of wallet connection state changes
  Stream<ConnectionState> get connectionStream =>
      HederaWalletConnect.connectionStateStream;

  /// Connect to a Hedera wallet
  ///
  /// [preferredWallet] - Optional wallet preference ('hashpack', 'blade', 'kabila')
  /// Returns [AccountInfo] if successful, throws exception on failure
  Future<AccountInfo?> connect({String? preferredWallet}) async {
    try {
      debugPrint('🔗 Attempting to connect to Hedera wallet...');
      final accountInfo = await HederaWalletConnect.connect(
        preferredWallet: preferredWallet,
      );
      debugPrint(
          '✅ Successfully connected to wallet: ${accountInfo.accountId}');
      return accountInfo;
    } on WalletNotFoundException catch (e) {
      debugPrint('❌ No compatible wallet found: $e');
      rethrow;
    } on WalletNotInstalledException catch (e) {
      debugPrint('❌ Wallet not installed: ${e.walletName}');
      rethrow;
    } on UserRejectedConnectionException catch (e) {
      debugPrint('❌ User rejected wallet connection: $e');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected wallet connection error: $e');
      rethrow;
    }
  }

  /// Disconnect from the current wallet
  Future<void> disconnect() async {
    try {
      debugPrint('🔌 Disconnecting from wallet...');
      await HederaWalletConnect.disconnect();
      debugPrint('✅ Successfully disconnected from wallet');
    } catch (e) {
      debugPrint('❌ Error disconnecting from wallet: $e');
      rethrow;
    }
  }

  /// Check if wallet is currently connected
  bool isConnected() {
    final connected = HederaWalletConnect.isConnected();
    debugPrint(
        '🔍 Wallet connection status: ${connected ? "Connected" : "Disconnected"}');
    return connected;
  }

  /// Get the current connected account ID
  String? getAccountId() {
    final accountId = HederaWalletConnect.getAccountId();
    debugPrint('🆔 Current account ID: ${accountId ?? "None"}');
    return accountId;
  }

  /// Get detailed account information
  AccountInfo? getAccountInfo() {
    final accountInfo = HederaWalletConnect.getAccountInfo();
    if (accountInfo != null) {
      debugPrint(
          'ℹ️ Account info: ${accountInfo.accountId} on ${accountInfo.network}');
    }
    return accountInfo;
  }

  /// Get account balance in HBAR
  Future<double> getBalance() async {
    try {
      debugPrint('💰 Fetching account balance...');
      final balance = await HederaWalletConnect.getAccountBalance();
      debugPrint('✅ Account balance: $balance HBAR');
      return balance;
    } on NotConnectedException catch (e) {
      debugPrint('❌ Cannot get balance - wallet not connected: $e');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error fetching balance: $e');
      rethrow;
    }
  }

  /// Sign a transaction using the connected wallet
  ///
  /// [request] - Transaction request with bytes and metadata
  /// Returns [HederaTransactionResult] with signed transaction
  Future<HederaTransactionResult> signTransaction(
    HederaTransactionRequest request,
  ) async {
    try {
      debugPrint('✍️ Requesting transaction signature...');
      debugPrint('Transaction ID: ${request.transactionId}');
      debugPrint('Fee: ${request.fee} HBAR');
      debugPrint('Memo: ${request.memo}');

      final result = await HederaWalletConnect.signTransaction(request);

      if (result.success) {
        debugPrint('✅ Transaction signed successfully');
      } else {
        debugPrint('❌ Transaction signing failed');
      }

      return result;
    } on UserRejectedTransactionException catch (e) {
      debugPrint('❌ User rejected transaction: $e');
      rethrow;
    } on NotConnectedException catch (e) {
      debugPrint('❌ Cannot sign transaction - wallet not connected: $e');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected transaction signing error: $e');
      rethrow;
    }
  }

  /// Get list of available wallets on the device
  Future<List<AvailableWallet>> getAvailableWallets() async {
    try {
      debugPrint('📱 Fetching available wallets...');
      final wallets = await HederaWalletConnect.getAvailableWallets();
      debugPrint('✅ Found ${wallets.length} available wallets');

      for (final wallet in wallets) {
        debugPrint(
            '  - ${wallet.name}: ${wallet.isInstalled ? "Installed" : "Not installed"}');
      }

      return wallets;
    } catch (e) {
      debugPrint('❌ Error fetching available wallets: $e');
      rethrow;
    }
  }

  /// Open Play Store for wallet installation
  ///
  /// [packageName] - Android package name of the wallet app
  Future<void> openPlayStore(String packageName) async {
    try {
      debugPrint('🏪 Opening Play Store for: $packageName');
      await HederaWalletConnect.openPlayStore(packageName);
    } catch (e) {
      debugPrint('❌ Error opening Play Store: $e');
      rethrow;
    }
  }

  /// Get wallet connection status with detailed information
  WalletConnectionStatus getConnectionStatus() {
    final isConnected = this.isConnected();
    final accountId = getAccountId();
    final accountInfo = getAccountInfo();

    return WalletConnectionStatus(
      isConnected: isConnected,
      accountId: accountId,
      walletName: accountInfo?.walletName,
      network: accountInfo?.network,
    );
  }

  /// Dispose resources (call when service is no longer needed)
  void dispose() {
    debugPrint('🗑️ Disposing WalletService resources');
    // Note: HederaWalletConnect handles its own cleanup
  }
}

/// Wallet connection status information
class WalletConnectionStatus {
  final bool isConnected;
  final String? accountId;
  final String? walletName;
  final String? network;

  const WalletConnectionStatus({
    required this.isConnected,
    this.accountId,
    this.walletName,
    this.network,
  });

  @override
  String toString() {
    return 'WalletConnectionStatus(isConnected: $isConnected, accountId: $accountId, walletName: $walletName, network: $network)';
  }
}

/// Custom exceptions for wallet operations
class WalletServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const WalletServiceException(this.message, [this.originalError]);

  @override
  String toString() => 'WalletServiceException: $message';
}

/// Exception thrown when wallet operation requires connection but none exists
class WalletNotConnectedException extends WalletServiceException {
  const WalletNotConnectedException() : super('Wallet not connected');
}

/// Exception thrown when user cancels wallet operation
class WalletOperationCancelledException extends WalletServiceException {
  const WalletOperationCancelledException(String operation)
      : super('User cancelled $operation');
}
