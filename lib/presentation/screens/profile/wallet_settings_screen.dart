import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/wallet_connect_button.dart';
import '../../../domain/models/user_profile.dart';
import '../../../core/services/hedera_wallet_types.dart';

class WalletSettingsScreen extends ConsumerWidget {
  const WalletSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletStateProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimary),
        ),
        title: const Text(
          'Wallet Settings',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.w600,
            fontFamily: 'Funnel Sans',
          ),
        ),
        actions: [
          if (walletState.isConnected)
            IconButton(
              onPressed: () => _showWalletInfo(context, walletState),
              icon: const Icon(Icons.info_outline,
                  color: AppConstants.textPrimary),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connect your Hedera wallet to earn HUSH tokens for noise measurements and participate in the decentralized network.',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontFamily: 'Funnel Sans',
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // Wallet Connection Section
            _buildWalletConnectionSection(walletState, userProfile),

            const SizedBox(height: AppConstants.paddingXL),

            // Wallet Features Section
            if (walletState.isConnected) ...[
              _buildWalletFeaturesSection(context, walletState),
              const SizedBox(height: AppConstants.paddingXL),
            ],

            // Available Wallets Section
            _buildAvailableWalletsSection(ref),

            const SizedBox(height: AppConstants.paddingXL),

            // Help Section
            _buildHelpSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletConnectionSection(
      WalletState walletState, AsyncValue<UserProfile?> userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hedera Wallet Connection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
              fontFamily: 'Funnel Sans',
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          const WalletConnectButton(showBalance: true),
          if (walletState.isConnected &&
              userProfile.hasValue &&
              userProfile.value?.hushTokenBalance != null) ...[
            const SizedBox(height: AppConstants.paddingM),
            _buildTokenBalance(userProfile.value!.hushTokenBalance!),
          ],
        ],
      ),
    );
  }

  Widget _buildTokenBalance(double hushBalance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryTeal,
            AppConstants.primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HUSH Token Balance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Funnel Sans',
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            '${hushBalance.toStringAsFixed(2)} HUSH',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Funnel Sans',
            ),
          ),
          Text(
            '≈ \$${(hushBalance * 0.05).toStringAsFixed(2)} USD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Funnel Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletFeaturesSection(
      BuildContext context, WalletState walletState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wallet Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
            fontFamily: 'Funnel Sans',
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        _buildFeatureCard(
          icon: Icons.history,
          title: 'Transaction History',
          subtitle: 'View your reward transactions',
          onTap: () => _showTransactionHistory(context),
        ),
        const SizedBox(height: AppConstants.paddingS),
        _buildFeatureCard(
          icon: Icons.account_balance,
          title: 'Account Details',
          subtitle: 'Copy account ID and view network info',
          onTap: () => _showAccountDetails(context, walletState),
        ),
        const SizedBox(height: AppConstants.paddingS),
        _buildFeatureCard(
          icon: Icons.refresh,
          title: 'Refresh Balance',
          subtitle: 'Update your wallet balance',
          onTap: () => _refreshWalletBalance(context),
        ),
      ],
    );
  }

  Widget _buildAvailableWalletsSection(WidgetRef ref) {
    final availableWallets = ref.watch(availableWalletsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Supported Wallets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
                fontFamily: 'Funnel Sans',
              ),
            ),
            TextButton(
              onPressed: () => _showWalletSelection(ref.context),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'Funnel Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        availableWallets.when(
          data: (wallets) => Column(
            children: wallets
                .take(3)
                .map((wallet) => _buildWalletCard(wallet, ref))
                .toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text(
            'Error loading wallets: $error',
            style: const TextStyle(
              fontFamily: 'Funnel Sans',
              color: AppConstants.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
            fontFamily: 'Funnel Sans',
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        _buildFeatureCard(
          icon: Icons.help_outline,
          title: 'Wallet Guide',
          subtitle: 'Learn how to use Hedera wallets',
          onTap: () => _showWalletGuide(context),
        ),
        const SizedBox(height: AppConstants.paddingS),
        _buildFeatureCard(
          icon: Icons.security,
          title: 'Security Tips',
          subtitle: 'Keep your wallet safe',
          onTap: () => _showSecurityTips(context),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppConstants.primaryTeal),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Funnel Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Funnel Sans',
            color: AppConstants.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildWalletCard(AvailableWallet wallet, WidgetRef ref) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
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
            ? const Icon(Icons.check_circle, color: AppConstants.primaryTeal)
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
      ),
    );
  }

  void _showWalletInfo(BuildContext context, WalletState walletState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Wallet Information',
          style: TextStyle(fontFamily: 'Funnel Sans'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Account ID', walletState.accountId ?? 'Unknown'),
            _buildInfoRow('Wallet', walletState.walletName ?? 'Unknown'),
            _buildInfoRow('Network', walletState.network ?? 'Unknown'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(fontFamily: 'Funnel Sans'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Funnel Sans',
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _copyToClipboard(value),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Funnel Sans',
                  color: AppConstants.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _showTransactionHistory(BuildContext context) {
    // TODO: Implement transaction history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction history coming soon!')),
    );
  }

  void _showAccountDetails(BuildContext context, WalletState walletState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Account Details',
          style: TextStyle(fontFamily: 'Funnel Sans'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (walletState.accountId != null) ...[
              Text(
                'Account ID',
                style: TextStyle(
                  fontFamily: 'Funnel Sans',
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppConstants.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        walletState.accountId!,
                        style: const TextStyle(
                          fontFamily: 'Funnel Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(walletState.accountId!),
                      icon: const Icon(Icons.copy, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(fontFamily: 'Funnel Sans'),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshWalletBalance(BuildContext context) {
    // TODO: Implement balance refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Balance refreshed!')),
    );
  }

  void _showWalletSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WalletSelectionDialog(),
    );
  }

  void _installWallet(WidgetRef ref, AvailableWallet wallet) async {
    try {
      final walletService = ref.read(walletServiceProvider);
      await walletService.openPlayStore(wallet.packageName);
    } catch (e) {
      debugPrint('Failed to open Play Store: $e');
    }
  }

  void _showWalletGuide(BuildContext context) {
    // TODO: Implement wallet guide
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet guide coming soon!')),
    );
  }

  void _showSecurityTips(BuildContext context) {
    // TODO: Implement security tips
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security tips coming soon!')),
    );
  }
}
