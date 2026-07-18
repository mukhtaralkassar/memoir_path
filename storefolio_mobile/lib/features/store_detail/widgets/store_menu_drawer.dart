import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/store.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/settings_screen.dart';

/// RTL-aware side menu drawer for a store.
class StoreMenuDrawer extends StatelessWidget {
  final Store store;

  const StoreMenuDrawer({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);
    final primary = AppTheme.parseHexColor(store.themeColor, AppTheme.primaryColor);

    return Drawer(
      child: Container(
        color: AppTheme.parseHexColor(store.backgroundColor, AppTheme.backgroundColor),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(fontColor, primary),
              const Divider(height: 1),
              _buildMenuItem(
                icon: Icons.store,
                label: isArabic ? 'المتجر' : 'Store',
                onTap: () => Navigator.pop(context),
              ),
              if (store.description?.isNotEmpty == true)
                _buildMenuItem(
                  icon: Icons.info_outline,
                  label: isArabic ? 'من نحن' : 'About Us',
                  onTap: () => _openAbout(context),
                ),
              _buildMenuItem(
                icon: Icons.settings,
                label: isArabic ? 'الإعدادات' : 'Settings',
                onTap: () => _openSettings(context),
              ),
              const Divider(height: 1),
              const Spacer(),
              _buildSocialLinks(isArabic, primary),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color fontColor, Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withAlpha(179),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (store.logoUrl != null)
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: store.logoUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.white24,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.white24,
                  child: const Icon(Icons.store, color: Colors.white),
                ),
              ),
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store, color: Colors.white),
            ),
          const SizedBox(height: 12),
          Text(
            store.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (store.description?.isNotEmpty == true)
            Text(
              store.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textHint),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _buildSocialLinks(bool isArabic, Color primary) {
    final links = _collectSocialLinks();
    if (links.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'تابعنا' : 'Follow Us',
            style: AppTheme.subtitle2.copyWith(color: AppTheme.textHint),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: links.map((link) => _buildSocialButton(link)).toList(),
          ),
        ],
      ),
    );
  }

  List<_SocialLink> _collectSocialLinks() {
    final links = <_SocialLink>[];
    if (store.whatsapp?.isNotEmpty == true) {
      links.add(_SocialLink(
        type: 'whatsapp',
        url: 'https://wa.me/${_cleanPhone(store.whatsapp!)}',
        color: const Color(0xFF25D366),
      ));
    }
    if (store.socialInstagram?.isNotEmpty == true) {
      links.add(_SocialLink(
        type: 'instagram',
        url: _ensureUrl(store.socialInstagram!),
        color: const Color(0xFFE1306C),
      ));
    }
    if (store.socialFacebook?.isNotEmpty == true) {
      links.add(_SocialLink(
        type: 'facebook',
        url: _ensureUrl(store.socialFacebook!),
        color: const Color(0xFF1877F2),
      ));
    }
    if (store.socialTiktok?.isNotEmpty == true) {
      links.add(_SocialLink(
        type: 'tiktok',
        url: _ensureUrl(store.socialTiktok!),
        color: const Color(0xFF000000),
      ));
    }
    return links;
  }

  Widget _buildSocialButton(_SocialLink link) {
    final icon = _socialIcon(link.type);
    return InkWell(
      onTap: () => _launchUrl(link.url),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: link.color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  IconData _socialIcon(String type) {
    switch (type) {
      case 'whatsapp':
        return Icons.chat;
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.link;
    }
  }

  String _ensureUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return 'https://$value';
  }

  String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  void _openAbout(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AboutStoreScreen(store: store)),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SocialLink {
  final String type;
  final String url;
  final Color color;

  _SocialLink({required this.type, required this.url, required this.color});
}

/// Simple About Us screen matching the website layout.
class AboutStoreScreen extends StatelessWidget {
  final Store store;

  const AboutStoreScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final backgroundColor = AppTheme.parseHexColor(store.backgroundColor, AppTheme.backgroundColor);
    final fontColor = AppTheme.parseHexColor(store.fontColor, AppTheme.textPrimary);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? 'من نحن' : 'About Us'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (store.logoUrl != null)
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: store.logoUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.store, size: 48, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Text(
              store.displayName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: fontColor,
              ),
            ),
            const SizedBox(height: 24),
            if (store.description?.isNotEmpty == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.parseHexColor(store.cardBackgroundColor, AppTheme.surfaceColor),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Text(
                  store.description!,
                  style: TextStyle(fontSize: 16, height: 1.6, color: fontColor),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
