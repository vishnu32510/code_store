import 'package:code_store_core/code_store_core.dart';
import 'package:code_store_share/code_store_share.dart';
import 'package:flutter/material.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final IShareService _shareService = getIt<IShareService>();

  final TextEditingController _textController = TextEditingController(
    text: '🚀 Check out CodeStore - the ultimate production-ready Flutter modular boilerplate!',
  );
  final TextEditingController _urlController = TextEditingController(
    text: 'https://github.com/vishnu32510/code_store',
  );

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _shareCustomMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      getIt<IToastService>().showError('Please enter text to share');
      return;
    }

    _shareService.shareContent(
      AppShareContent(
        text: text,
        url: _urlController.text.trim(),
        subject: 'CodeStore Flutter App',
      ),
    );
  }

  void _shareReferralCode() {
    _shareService.shareText(
      text: 'Join me on CodeStore! Use my referral code: CODESTORE-PRO-2026 to get 1 month of Pro access free.\nhttps://codestore.app/ref/CODESTORE-PRO-2026',
      subject: 'Your Exclusive CodeStore Invitation',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share & Referrals'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildReferralHero(context, colors),
          const SizedBox(height: 24),
          Text(
            'Custom Message Share Sheet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message Body',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Link / URL (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _shareCustomMessage,
            icon: const Icon(Icons.share_rounded),
            label: const Text('Open System Share Sheet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralHero(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.card_giftcard_rounded, color: colors.primary),
              ),
              const SizedBox(width: 12),
              const Text(
                'Invite Friends & Earn Pro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Share your personalized invite link to unlock premium credits for each referred user.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _shareReferralCode,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Share Referral Invite'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
