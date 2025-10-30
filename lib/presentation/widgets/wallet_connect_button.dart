import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/hedera_wallet_types.dart';
import '../providers/app_providers.dart';

class WalletConnectButton extends ConsumerStatefulWidget {
  final String? preferredWallet;
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;
  final bool showBalance;
  final EdgeInsets? padding;

  const WalletConnectButton({
    super.key,
    this.preferredWallet,
    this.onConnected,
    this.onDisconnected,
    this.showBalance = false,
    this.padding,
  });

  @override
  ConsumerState<WalletConnectButton> createState() =>
      _WalletConnectButtonState();
}

class _WalletConnectButtonState extends ConsumerState<WalletConnectButton> {
  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateProvider);
    final walletBalance = ref.watch(walletBalanceProvider);

    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildConnectionButton(walletState),
          if (widget.showBalance && walletState.isConnected) ...[
            const SizedBox(height: AppConstants.paddingS),
            _buildBalanceDisplay(walletBalance),
          ],
          if (walletState.error != null) ...[
            const SizedBox(height: AppConstants.paddingS),
            _buildErrorDisplay(walletState.error!),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionButton(WalletState walletState) {
    if (walletState.isConnected) {
      return _buildDisconnectButton(walletState);
    } else {
      return _buildConnectButton(walletState);
    }
  }

  Widget _buildConnectButton(WalletState walletState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: walletState.isConnecting ? null : _handleConnect,
        icon: walletState.isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.account_balance_wallet),
        label: Text(
          walletState.isConnecting ? 'Connecting...' : 'Connect Hedera Wallet',
          style: const TextStyle(
            fontFamily: 'Funnel Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnectButton(WalletState walletState) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppConstants.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppConstants.primaryTeal.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppConstants.primaryTeal,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  const Text(
                    'Wallet Connected',
                    style: TextStyle(
                      fontFamily: 'Funnel Sans',
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingS),
              if (walletState.accountId != null) ...[
                Text(
                  'Account: ${_formatAccountId(walletState.accountId!)}',
                  style: const TextStyle(
                    fontFamily: 'Funnel Sans',
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
              if (walletState.walletName != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Wallet: ${walletState.walletName}',
                  style: const TextStyle(
                    fontFamily: 'Funnel Sans',
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
              if (walletState.network != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Network: ${walletState.network}',
                  style: const TextStyle(
                    fontFamily: 'Funnel Sans',
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingS),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleDisconnect,
            icon: const Icon(Icons.logout),
            label: const Text(
              'Disconnect',
              style: TextStyle(
                fontFamily: 'Funnel Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.textSecondary,
              side: BorderSide(
                  color: AppConstants.textSecondary.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceDisplay(AsyncValue<double?> balanceAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 1,
        ),
      ),
      child: balanceAsync.when(
        data: (balance) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HBAR Balance',
              style: TextStyle(
                fontFamily: 'Funnel Sans',
                fontSize: 12,
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              balance != null
                  ? '${balance.toStringAsFixed(8)} HBAR'
                  : 'Unable to fetch',
              style: const TextStyle(
                fontFamily: 'Funnel Sans',
                fontSize: 16,
                color: AppConstants.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (balance != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _refreshBalance,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 14,
                      color: AppConstants.primaryTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontFamily: 'Funnel Sans',
                        fontSize: 12,
                        color: AppConstants.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        loading: () => const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppConstants.paddingS),
            Text(
              'Loading balance...',
              style: TextStyle(
                fontFamily: 'Funnel Sans',
                fontSize: 12,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
        error: (error, stack) => Text(
          'Error loading balance',
          style: TextStyle(
            fontFamily: 'Funnel Sans',
            fontSize: 12,
            color: Colors.red[600],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: Colors.red[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: AppConstants.paddingS),
          Expanded(
            child: Text(
              _getErrorMessage(error),
              style: TextStyle(
                fontFamily: 'Funnel Sans',
                fontSize: 12,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConnect() async {
    try {
      await ref.read(walletStateProvider.notifier).connectWallet(
            preferredWallet: widget.preferredWallet,
          );
      widget.onConnected?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet connected successfully!'),
            backgroundColor: AppConstants.primaryTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to connect wallet: ${_getErrorMessage(e.toString())}'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _handleDisconnect() async {
    try {
      await ref.read(walletStateProvider.notifier).disconnectWallet();
      widget.onDisconnected?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet disconnected'),
            backgroundColor: AppConstants.textSecondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disconnect wallet: ${e.toString()}'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _refreshBalance() async {
    await ref.read(walletStateProvider.notifier).refreshBalance();
    ref.invalidate(walletBalanceProvider);
  }

  String _formatAccountId(String accountId) {
    if (accountId.length > 20) {
      return '${accountId.substring(0, 10)}...${accountId.substring(accountId.length - 6)}';
    }
    return accountId;
  }

  String _getErrorMessage(String error) {
    if (error.contains('WalletNotFoundException')) {
      return 'No compatible wallet found. Please install HashPack, Blade, or Kabila wallet.';
    } else if (error.contains('UserRejectedConnectionException')) {
      return 'Connection was cancelled. Please try again.';
    } else if (error.contains('WalletNotInstalledException')) {
      return 'Wallet app not installed. Please install from Play Store.';
    } else if (error.contains('NetworkException')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('TimeoutException')) {
      return 'Connection timed out. Please try again.';
    } else {
      return 'Connection failed. Please try again.';
    }
  }
}

/// Wallet Selection Dialog
class WalletSelectionDialog extends ConsumerWidget {
  const WalletSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableWallets = ref.watch(availableWalletsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Wallet',
              style: TextStyle(
                fontFamily: 'Funnel Sans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            const Text(
              'Choose a Hedera wallet to connect:',
              style: TextStyle(
                fontFamily: 'Funnel Sans',
                fontSize: 14,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            availableWallets.when(
              data: (wallets) => Column(
                children: wallets
                    .map((wallet) => _buildWalletOption(
                          context,
                          ref,
                          wallet,
                        ))
                    .toList(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Text(
                'Error loading wallets: $error',
                style: TextStyle(
                  fontFamily: 'Funnel Sans',
                  color: Colors.red[600],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Funnel Sans',
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletOption(
      BuildContext context, WidgetRef ref, AvailableWallet wallet) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryTeal.withOpacity(0.1),
          child: Icon(
            Icons.account_balance_wallet,
            color: AppConstants.primaryTeal,
          ),
        ),
        title: Text(
          wallet.name,
          style: const TextStyle(
            fontFamily: 'Funnel Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          wallet.isInstalled ? 'Installed' : 'Not installed',
          style: TextStyle(
            fontFamily: 'Funnel Sans',
            color: wallet.isInstalled
                ? AppConstants.primaryTeal
                : AppConstants.textSecondary,
          ),
        ),
        trailing: wallet.isInstalled
            ? const Icon(Icons.chevron_right)
            : TextButton(
                onPressed: () => _installWallet(ref, wallet),
                child: const Text(
                  'Install',
                  style: TextStyle(
                    fontFamily: 'Funnel Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        onTap: wallet.isInstalled
            ? () => _connectWallet(context, ref, wallet.packageName)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  Future<void> _connectWallet(
      BuildContext context, WidgetRef ref, String walletPackage) async {
    Navigator.of(context).pop();

    try {
      await ref.read(walletStateProvider.notifier).connectWallet(
            preferredWallet: walletPackage,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _installWallet(WidgetRef ref, AvailableWallet wallet) async {
    try {
      final walletService = ref.read(walletServiceProvider);
      await walletService.openPlayStore(wallet.packageName);
    } catch (e) {
      debugPrint('Failed to open Play Store: $e');
    }
  }
}
