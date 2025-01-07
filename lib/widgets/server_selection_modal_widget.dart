import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ServerSelectionModal extends StatelessWidget {
  final String selectedServer;
  final Function(String) onServerSelected;

  ServerSelectionModal(
      {required this.selectedServer, required this.onServerSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_server'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Lottie.asset('assets/lottie/auto.json', width: 30),
            title: Text('selected_server'.tr()),
            subtitle: Text('auto_server_handle'.tr()),
            trailing: selectedServer == 'auto'
                ? Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => onServerSelected('auto'),
          ),
          Divider(),
          ListTile(
            // leading: Icon(Icons.flag, color: Colors.white, size: 32),
            leading: Lottie.asset('assets/lottie/server.json', width: 30),
            title: Text('mci'.tr()),
            subtitle: Text('mci_server_handle'.tr()),
            trailing: selectedServer == 'mci'
                ? Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => onServerSelected('mci'),
          ),
          ListTile(
            leading: Lottie.asset('assets/lottie/server.json', width: 30),
            title: Text('mtn'.tr()),
            subtitle: Text('mtn_server_handle'.tr()),
            trailing: selectedServer == 'mtn'
                ? Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => onServerSelected('mtn'),
          ),
        ],
      ),
    );
  }
}