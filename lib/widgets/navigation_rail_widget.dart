import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:begzar_windows/model/sing_status.dart';
import 'package:easy_localization/easy_localization.dart';

class NavigationRailWidget extends StatefulWidget {
  final int selectedIndex;
  final ValueNotifier<SingStatus> singStatus;
  final Function(int) onDestinationSelected;

  const NavigationRailWidget({
    Key? key,
    required this.selectedIndex,
    required this.singStatus,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  State<NavigationRailWidget> createState() => _NavigationRailWidgetState();
}

class _NavigationRailWidgetState extends State<NavigationRailWidget> {
  String? ip;
  String? countryCode;

  Future<Map<String, String>> getIpApi() async {
    try {
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter()
        ..createHttpClient = () {
          final client = HttpClient();
          client.findProxy = (uri) {
            return 'PROXY 127.0.0.1:7828';
          };
          return client;
        };

      final response = await dio.get(
        'https://freeipapi.com/api/json',
        options: Options(
          followRedirects: true,
          validateStatus: (status) => true,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is Map) {
          String ip = data['ipAddress'] ?? 'unknown'.tr();

          if (ip.contains('.')) {
            final parts = ip.split('.');
            if (parts.length == 4) {
              ip = '${parts[0]}.*.*.${parts[3]}';
            }
          } else if (ip.contains(':')) {
            final parts = ip.split(':');
            if (parts.length > 4) {
              ip = '${parts[0]}:${parts[1]}:****:${parts.last}';
            }
          }

          return {'countryCode': data['countryCode'] ?? 'Unknown', 'ip': ip};
        }
      }
      return {'countryCode': 'IR', 'ip': 'Unknown'};
    } catch (e) {
      return {'countryCode': 'IR', 'ip': 'Error'};
    }
  }

  String countryCodeToFlagEmoji(String countryCode) {
    countryCode = countryCode.toUpperCase();
    return countryCode.codeUnits
        .map((codeUnit) => String.fromCharCode(0x1F1E6 + codeUnit - 0x41))
        .join();
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)}${suffixes[i]}';
  }

  String formatSpeedBytes(int bytes) {
    if (bytes <= 0) return '0B/s';
    const suffixes = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)}${suffixes[i]}';
  }

  Widget _buildConnectionHeader(bool isExtraWideScreen) {
    return Row(
      children: [
        const Icon(Icons.wifi, color: Colors.green, size: 20),
        if (isExtraWideScreen) ...[
          const SizedBox(width: 8),
          Text(
            'connection_info'.tr(),
            style: TextStyle(
              color: Colors.grey[300],
              fontFamily: 'sm',
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIpButton() {
    return Material(
      color: const Color(0xFF353535),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final ipInfo = await getIpApi();
          if (ipInfo['ip'] != null) {
            setState(() {
              ip = ipInfo['ip'];
              countryCode = ipInfo['countryCode'];
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ip != null) ...[
                Text(
                  ip!,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontFamily:
                        context.locale.languageCode == 'fa' ? 'sm' : 'GB',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                if (countryCode != null)
                  Text(
                    countryCodeToFlagEmoji(countryCode!),
                    style: const TextStyle(
                      fontFamily: 'GoogeFontEmoji',
                      fontSize: 14,
                    ),
                  ),
              ] else
                Text(
                  'check_ip_button'.tr(),
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontFamily: 'sm',
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageStats(SingStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'network_speed'.tr(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontFamily: 'sm',
          ),
        ),
        const SizedBox(height: 4),
        _buildUsageRow('⬆️', formatSpeedBytes(status.uploadSpeed.toInt())),
        _buildUsageRow('⬇️', formatSpeedBytes(status.downloadSpeed.toInt())),
        const SizedBox(height: 12),
        Text(
          'total_usage'.tr(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontFamily: 'sm',
          ),
        ),
        const SizedBox(height: 4),
        _buildUsageRow('⬆️', formatBytes(status.upload.toInt())),
        _buildUsageRow('⬇️', formatBytes(status.download.toInt())),
      ],
    );
  }

  Widget _buildUsageRow(String icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[300],
              fontFamily: 'GM',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isExtraWideScreen = size.width > 800;

    return Container(
      width: isExtraWideScreen ? 180 : 88,
      child: Column(
        children: [
          const SizedBox(height: 64),
          if (isExtraWideScreen) ...[
            _buildConnectionInfo(isExtraWideScreen),
          ],
          const Spacer(),
          _buildNavItems(isExtraWideScreen),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItems(bool isExtraWideScreen) {
    return Column(
      children: [
        _buildNavItem(
          Iconsax.home,
          'home_nav'.tr(),
          0,
          isExtraWideScreen,
        ),
        _buildNavItem(
          Iconsax.setting,
          'settings_nav'.tr(),
          1,
          isExtraWideScreen,
        ),
        _buildNavItem(
          Iconsax.stickynote,
          'logs'.tr(),
          2,
          isExtraWideScreen,
        ),
        _buildNavItem(
          Iconsax.info_circle,
          'info_nav'.tr(),
          3,
          isExtraWideScreen,
        ),
      ],
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    bool showLabel,
  ) {
    final isSelected = widget.selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onDestinationSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: showLabel ? 150 : 60,
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[800] : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'sm',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionInfo(bool isExtraWideScreen) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ValueListenableBuilder<SingStatus>(
        valueListenable: widget.singStatus,
        builder: (context, status, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionHeader(isExtraWideScreen),
              if (isExtraWideScreen) ...[
                const SizedBox(height: 8),
                _buildIpButton(),
                const SizedBox(height: 12),
                _buildUsageStats(status),
              ],
            ],
          );
        },
      ),
    );
  }
}
