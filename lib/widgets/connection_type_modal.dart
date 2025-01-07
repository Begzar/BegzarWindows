import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ConnectionTypeModal extends StatelessWidget {
  final String currentType;
  final Function(String) onTypeSelected;

  const ConnectionTypeModal({
    Key? key,
    required this.currentType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'connection_type_modal'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'sb',
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),
          _buildTypeItem(
            context: context,
            title: 'system_proxy'.tr(),
            subtitle: 'no_admin_needed'.tr(),
            type: 'systemProxy',
            icon: Icons.computer,
          ),
          const Divider(color: Colors.grey),
          _buildTypeItem(
            context: context,
            title: 'proxy_only'.tr(),
            subtitle: 'special_apps'.tr(),
            type: 'proxyOnly',
            icon: Icons.settings_ethernet,
          ),
          const Divider(color: Colors.grey),
          _buildTypeItem(
            context: context,
            title: 'vpn'.tr(),
            subtitle: 'admin_needed'.tr(),
            type: 'vpn',
            icon: Icons.vpn_lock,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String type,
    required IconData icon,
  }) {
    final isSelected = currentType == type;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF353535),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.green : Colors.grey[400],
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 16,
          fontFamily: 'sm',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontFamily: 'sm',
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        onTypeSelected(type);
        Navigator.pop(context);
      },
    );
  }
} 