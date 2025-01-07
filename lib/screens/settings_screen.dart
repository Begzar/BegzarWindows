import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:begzar_windows/common/settings_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final VoidCallback onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.onLanguageChanged,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String selectedLogLevel = "warn";
  late bool isAdBlockEnabled = false;
  late bool isProxyShareEnabled = false;
  late String selectedDNS = "Google";
  final List<String> dnsOptions = ['Google', 'Cloudflare'];

  final List<Map<String, dynamic>> supportedLanguages = [
    {'name': 'English', 'code': 'en', 'country': 'US'},
    {'name': 'فارسی', 'code': 'fa', 'country': 'IR'},
    {'name': '中文', 'code': 'zh', 'country': 'CH'},
    {'name': 'Русский', 'code': 'ru', 'country': 'RU'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsManager.loadSettings();
    setState(() {
      selectedLogLevel = settings.logLevel;
      isAdBlockEnabled = settings.adBlockEnabled;
      isProxyShareEnabled = settings.proxyShareEnabled;
      selectedDNS = settings.selectedDNS;
    });
  }

  Future<void> _updateLogLevel(String level) async {
    await SettingsManager.updateSettings(logLevel: level);
    setState(() => selectedLogLevel = level);
    widget.onSettingsChanged();
  }

  Future<void> _updateAdBlock(bool value) async {
    await SettingsManager.updateSettings(adBlockEnabled: value);
    setState(() => isAdBlockEnabled = value);
    widget.onSettingsChanged();
  }

  Future<void> _updateProxyShare(bool value) async {
    await SettingsManager.updateSettings(proxyShareEnabled: value);
    setState(() => isProxyShareEnabled = value);
    widget.onSettingsChanged();
  }

  Future<void> _updateDNS(String dns) async {
    await SettingsManager.updateSettings(selectedDNS: dns);
    setState(() => selectedDNS = dns);
    widget.onSettingsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff192028),
      appBar: AppBar(
        backgroundColor: const Color(0xff192028),
        elevation: 0,
        title: Text(
          'settings_nav'.tr(),
          style: TextStyle(
            fontFamily: 'sb',
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('language'.tr()),
          _buildLanguageSelector(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('log_level'.tr()),
          _buildLogLevelSelector(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('security'.tr()),
          _buildSettingSwitch(
            'ad_block'.tr(),
            'remove_annoying_ads'.tr(),
            isAdBlockEnabled,
            Iconsax.shield_tick,
            _updateAdBlock,
          ),
          const SizedBox(height: 16),
          _buildSettingSwitch(
            'proxy_share'.tr(),
            'share_with_other_devices'.tr(),
            isProxyShareEnabled,
            Iconsax.share,
            _updateProxyShare,
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle('dns'.tr()),
          _buildDNSSelector(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontFamily: 'sb',
        ),
      ),
    );
  }

  Widget _buildLogLevelSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildLogLevelOption('info', 'full_info'.tr()),
          _buildDivider(),
          _buildLogLevelOption('warn', 'warnings'.tr()),
          _buildDivider(),
          _buildLogLevelOption('debug', 'debugging'.tr()),
          _buildDivider(),
          _buildLogLevelOption('error', 'errors'.tr()),
        ],
      ),
    );
  }

  Widget _buildLogLevelOption(String level, String title) {
    final isSelected = selectedLogLevel == level;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _updateLogLevel(level),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontFamily: 'sm',
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF353535),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[400], size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontFamily: 'sm',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontFamily: 'sm',
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
          activeTrackColor: Colors.green.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildDNSSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: dnsOptions.map((dns) {
          final isSelected = selectedDNS == dns;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _updateDNS(dns),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          dns,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            fontFamily: 'sm',
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (dns != dnsOptions.last) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        title: Text(
          'language'.tr(),
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontFamily: 'sm',
          ),
        ),
        trailing: DropdownButton<String>(
          value: '${context.locale.languageCode}_${context.locale.countryCode}',
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[300]),
          dropdownColor: const Color(0xFF2A2A2A),
          underline: const SizedBox(),
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontFamily: 'sm',
          ),
          items: supportedLanguages.map((language) {
            return DropdownMenuItem<String>(
              value: '${language['code']}_${language['country']}',
              child: Text(
                language['name'],
                style: TextStyle(
                  fontFamily: language['code'] == 'fa' ? 'sm' : 'GM',
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              final parts = newValue.split('_');
              final newLocale = Locale(parts[0], parts[1]);
              widget.onLanguageChanged(newLocale);
              context.setLocale(newLocale);
            }
          },
        ),
      ),
    );
  }
} 