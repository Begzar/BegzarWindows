import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


class VpnCard extends StatefulWidget {
  final int downloadSpeed;
  final int uploadSpeed;
  final String selectedServer;
  final String selectedServerLogo;
  final String duration;

  final int download;
  final int upload;

  const VpnCard(
      {super.key,
      required this.downloadSpeed,
      required this.uploadSpeed,
      required this.download,
      required this.upload,
      required this.selectedServer,
      required this.selectedServerLogo,
      required this.duration});

  @override
  State<VpnCard> createState() => _VpnCardState();
}

class _VpnCardState extends State<VpnCard> {
  String? ipText;
  String? ipflag;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -30,
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.duration,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontFamily: 'GM',
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 350,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    widget.selectedServerLogo,
                    width: 40,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedServer,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontFamily: 'GM',
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildIpButton(),
                    ],
                  ),
                ],
              ),
              Divider(color: Colors.grey.withOpacity(0.1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn(
                      icon: Icons.data_usage_rounded,
                      download: formatBytes(widget.downloadSpeed),
                      upload: formatBytes(widget.uploadSpeed),
                    ),
                    _buildStatColumn(
                      icon: Icons.wifi_rounded,
                      download: formatSpeedBytes(widget.download),
                      upload: formatSpeedBytes(widget.upload),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0Byte';

    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes < kb) return '$bytes Byte${bytes > 1 ? 's' : ''}';
    if (bytes < mb) return '${(bytes / kb).toStringAsFixed(2)}KB';
    if (bytes < gb) return '${(bytes / mb).toStringAsFixed(2)}MB';
    return '${(bytes / gb).toStringAsFixed(2)}GB';
  }

  String formatSpeedBytes(int bytes) {
    if (bytes <= 0) return '0byte/s';

    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes < kb) return '${bytes}byte/s';
    if (bytes < mb) return '${(bytes / kb).toStringAsFixed(2)}KB/s';
    if (bytes < gb) return '${(bytes / mb).toStringAsFixed(2)}MB/s';
    return '${(bytes / gb).toStringAsFixed(2)}GB/s';
  }

  Widget _buildIpButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            setState(() => isLoading = true);
            final ipInfo = await getIpApi();
            setState(() {
              ipflag = countryCodeToFlagEmoji(ipInfo['countryCode']!);
              ipText = ipInfo['ip'];
              isLoading = false;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
                    ),
                  )
                else ...[
                  Text(
                    ipText ?? 'check_ip_button'.tr(),
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontFamily: 'GM',
                      fontSize: 13,
                    ),
                  ),
                  if (ipflag != null) ...[
                    SizedBox(width: 6),
                    Text(
                      ipflag!,
                      style: const TextStyle(
                        fontFamily: 'GoogeFontEmoji',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String download,
    required String upload,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green[400],
          size: 20,
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "⬇️ $download",
              style: TextStyle(
                color: Colors.grey[300],
                fontFamily: 'GM',
                fontSize: 13,
              ),
            ),
            Text(
              "⬆️ $upload",
              style: TextStyle(
                color: Colors.grey[300],
                fontFamily: 'GM',
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String countryCodeToFlagEmoji(String countryCode) {
  countryCode = countryCode.toUpperCase();
  final flag = countryCode.codeUnits
      .map((codeUnit) => String.fromCharCode(0x1F1E6 + codeUnit - 0x41))
      .join();

  return Text(
        flag,
        style: const TextStyle(
          fontFamily: 'GoogeFontEmoji',
          fontSize: 16,
        ),
      ).data ??
      flag;
}

Future<Map<String, String>> getIpApi() async {
  try {

    final dio = Dio();

    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'PROXY 127.0.0.1:8569';
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
        String ip = data['ipAddress'] ?? 'Unknown IP';
        
        if (ip.contains('.')) {  // IPv4
          final parts = ip.split('.');
          if (parts.length == 4) {
            ip = '${parts[0]}.*.*.${parts[3]}';
          }
        } else if (ip.contains(':')) {  // IPv6
          final parts = ip.split(':');
          if (parts.length > 4) {
            ip = '${parts[0]}:${parts[1]}:****:${parts.last}';
          }
        }

        return {
          'countryCode': data['countryCode'] ?? 'Unknown',
          'ip': ip
        };
      }
    }

    return {'countryCode': 'Unknown', 'ip': 'Unknown IP'};
  } catch (e) {
    print('Error getting IP info: $e');
    return {'countryCode': 'Error', 'ip': 'Error'};
  }
}
