import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:iconsax/iconsax.dart';

class AboutScreen extends StatelessWidget {
  final ValueNotifier<Locale> languageNotifier;

  const AboutScreen({
    Key? key,
    required this.languageNotifier,
  }) : super(key: key);

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<String?> _getVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, child) {
        return FutureBuilder<String?>(
          future: _getVersion(),
          builder: (context, snapshot) {
            final version = snapshot.data;
            
            return Scaffold(
              backgroundColor: const Color(0xff192028),
              appBar: AppBar(
                backgroundColor: const Color(0xff192028),
                elevation: 0,
                title: Text(
                  'about'.tr(),
                  style: const TextStyle(
                    fontFamily: 'sb',
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Logo Container with Animation
                      TweenAnimationBuilder(
                        duration: const Duration(seconds: 1),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // App Name with Animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Text(
                              'app_title'.tr(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontFamily: 'sb',
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      if (version != null)
                        Text(
                          '${'version'.tr()}$version',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: context.locale.languageCode == 'fa' ? 'sm' : 'GB',
                            color: Colors.grey[400],
                          ),
                        ),
                      const SizedBox(height: 40),
                      
                      // Contact Cards
                      _buildContactCard(
                        icon: Iconsax.message,
                        title: 'email'.tr(),
                        onTap: () => _launchURL('mailto:info@begzar.xyz'),
                      ),
                      _buildContactCard(
                        icon: Iconsax.message_programming,
                        title: 'Github',
                        onTap: () => _launchURL('https://github.com/Begzar/BegzarWindowsApp'),
                      ),
                      _buildContactCard(
                        icon: Iconsax.message_circle,
                        title: 'telegram_channel'.tr(),
                        onTap: () => _launchURL('https://t.me/begzar'),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Text(
                          'about_description'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontFamily: 'sm',
                            color: Colors.grey[300],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text(
                        'copyright'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: context.locale.languageCode == 'fa' ? 'sm' : 'GB',
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353535),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.grey[400], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'sm',
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 