import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogsModal extends StatelessWidget {
  const LogsModal({required this.logs});
  final ValueNotifier<String> logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildDivider(),
          _buildLogsContent(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'logs_modal'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white12,
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildLogsContent() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: logs,
          builder: (context, logsValue, _) {
            return SingleChildScrollView(
              reverse: true,
              child: SelectableText.rich(
                TextSpan(
                  children: logsValue.split('\n').map((line) {

                    if (line.contains('ERROR') || line.contains('error')) {
                      return TextSpan(
                        text: '$line\n',
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      );
                    } else if (line.contains('WARN') || line.contains('warn')) {
                      return TextSpan(
                        text: '$line\n',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      );
                    } else if (line.contains('INFO') || line.contains('info')) {
                      return TextSpan(
                        text: '$line\n',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      );
                    } else if (line.contains('DEBUG') || line.contains('debug')) {
                      return TextSpan(
                        text: '$line\n',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      );
                    }

                    return TextSpan(
                      text: '$line\n',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontSize: 13),
            ),
            icon: const Icon(Icons.copy, size: 16),
            label: Text('copy_logs'.tr()),
            onPressed: () => _copyLogs(context),
          ),
        ],
      ),
    );
  }

  void _copyLogs(BuildContext context) {
    Clipboard.setData(ClipboardData(text: logs.value));
    AwesomeDialog(
      context: context,
      desc: 'logs_copied'.tr(),
      showCloseIcon: true,
      dialogType: DialogType.success,
    ).show();
  }
}
