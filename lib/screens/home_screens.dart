import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:begzar_windows/common/cha.dart';
import 'package:begzar_windows/common/http_client.dart';
import 'package:begzar_windows/widgets/connection_widgets.dart';
import 'package:begzar_windows/widgets/logs_widget.dart';
import 'package:begzar_windows/widgets/server_selection_modal_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:begzar_windows/model/sing_status.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/theme.dart';
import 'package:bcore/bcore.dart';
import 'package:process_run/shell.dart';
import 'package:iconsax/iconsax.dart';
import 'package:begzar_windows/widgets/connection_type_modal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:begzar_windows/common/settings_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class HomePage extends StatefulWidget {
  final ValueNotifier<SingStatus> mainSingStatus;
  final ValueNotifier<String> logsNotifier;
  final ValueNotifier<Locale> languageNotifier;

  const HomePage({
    super.key,
    required this.mainSingStatus,
    required this.logsNotifier,
    required this.languageNotifier,
  });

  void updateSettings() {
    final state = _HomePageState.instance;
    if (state != null) {
      state.updateSettings();
    }
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static _HomePageState? instance;

  late final ValueNotifier<SingStatus> singStatus;
  late final ValueNotifier<String> logsNotifier;
  late final ValueNotifier<Locale> languageNotifier;

  String Ctype = "systemProxy";
  final storage = new FlutterSecureStorage();

  late final BcoreDesktop bcoreDesktop = BcoreDesktop(
    statusListner: (status) {
      final totalDownloadMB = status.totalDownload;
      final totalUploadMB = status.totalUpload;
      final downloadSpeed = status.download;
      final uploadSpeed = status.upload;
      final duration = status.duration;
      final durationString = duration.toString().split(".")[0];
      if (status.state == 'CONNECTED') {
        singStatus.value = SingStatus(
            state: 'CONNECTED',
            duration: durationString,
            uploadSpeed: uploadSpeed.toDouble(),
            downloadSpeed: downloadSpeed.toDouble(),
            upload: totalUploadMB.toDouble(),
            download: totalDownloadMB.toDouble());
      }
    },
    logListner: (log) {
      logsNotifier.value += '$log\n';
    },
  );

  bool proxyOnly = false;
  List<String> bypassSubnets = [];
  String? coreVersion;
  String? versionName;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int? connectedServerDelay;
  late SharedPreferences _prefs;
  String selectedServer = 'auto';
  String? selectedServerLogo;
  String? domainName;
  bool isFetchingPing = false;
  late String selectedLogLevel;
  late bool isAdBlockEnabled;
  late bool isProxyShareEnabled;
  late String selectedDNS;

  @override
  void initState() {
    super.initState();
    instance = this;
    singStatus = widget.mainSingStatus;
    logsNotifier = widget.logsNotifier;
    languageNotifier = widget.languageNotifier;
    isAdmin();
    getVersionName();
    _loadServerSelection();
    _loadSettings();
  }

  @override
  void dispose() {
    if (instance == this) {
      instance = null;
    }
    super.dispose();
  }

  Future<bool> isAdmin() async {
    if (!Platform.isWindows) return false;

    final shell = Shell();
    try {
      var result = await shell.run('whoami /priv');

      for (var line in result.outText.split('\n')) {
        if (line.contains("SeCreateGlobalPrivilege") &&
            line.contains("Enabled")) {
          return true;
        }
      }
      AwesomeDialog(
        context: context,
        showCloseIcon: true,
        desc: 'access_error'.tr(),
        dialogType: DialogType.info,
      ).show();
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isWideScreen = size.width > 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(isWideScreen),
      backgroundColor: const Color(0xff192028),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showServerSelectionModal(context),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    selectedServer == 'auto'
                        ? Lottie.asset('assets/lottie/auto.json', width: 30)
                        : Lottie.asset('assets/lottie/server.json', width: 30),
                    const SizedBox(width: 12),
                    Text(
                      selectedServer == 'auto'
                          ? 'Automatic'
                          : selectedServer == 'mci'
                              ? 'Server 1'
                              : 'Server 2',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        fontFamily: 'sm',
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ValueListenableBuilder(
                  valueListenable: singStatus,
                  builder: (context, value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConnectionWidget(
                          onTap: () => _handleConnectionTap(value),
                          isLoading: isLoading,
                          status: value.state,
                        ),
                        if (value.state == 'CONNECTED') ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              _buildDelayIndicator(),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildVersionInfo(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
    return AppBar(
      title: Text(
        'app_title'.tr(),
        style: TextStyle(
          color: ThemeColor.foregroundColor,
          fontSize: isWideScreen ? 22 : 18,
        ),
      ),
      automaticallyImplyLeading: !isWideScreen,
      actions: [_buildLogsButton(isWideScreen)],
      centerTitle: true,
      backgroundColor: ThemeColor.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildLogsButton(bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: _showTypeSelectionModal,
        child: const Icon(
          Iconsax.refresh_circle,
          color: Color.fromARGB(255, 224, 224, 224),
          size: 26,
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isWideScreen, double contentWidth) {
    return Expanded(
      flex: 2,
      child: ValueListenableBuilder(
        valueListenable: singStatus,
        builder: (context, value, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: isWideScreen ? contentWidth * 0.7 : contentWidth,
                  child: ConnectionWidget(
                    onTap: () => _handleConnectionTap(value),
                    isLoading: isLoading,
                    status: value.state,
                  ),
                ),
                if (value.state == 'CONNECTED') _buildDelayIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDelayIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: connectedServerDelay == null ? 50 : 80,
      height: 30,
      child: Center(
        child: connectedServerDelay == null
            ? LoadingAnimationWidget.fallingDot(
                color: const Color.fromARGB(255, 214, 182, 0),
                size: 35,
              )
            : _buildDelayDisplay(),
      ),
    );
  }

  Widget _buildDelayDisplay() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: serverDelay,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: context.locale.languageCode == 'fa'
            ? [
                const Text('ms'),
                const SizedBox(width: 2),
                Text(connectedServerDelay.toString()),
                const SizedBox(width: 6),
                const Icon(CupertinoIcons.wifi, color: Colors.white, size: 16),
              ]
            : [
                const Icon(CupertinoIcons.wifi, color: Colors.white, size: 16),
                Text(connectedServerDelay.toString(),
                    style: TextStyle(fontFamily: 'GB')),
                const SizedBox(width: 2),
                const Text('ms', style: TextStyle(fontFamily: 'GB')),
                const SizedBox(width: 6),
              ],
      ),
    );
  }



  void _handleConnectionTap(SingStatus value) async {
    if (value.state == "DISCONNECTED") {
      getDomain();
    } else {
      singStatus.value = SingStatus(state: 'DISCONNECTED');
      logsNotifier.value = 'Begzar v${versionName} log manager.\n';
      bcoreDesktop.stopV2Ray();
      disableSystemProxy();
    }
  }

  Widget _buildVersionInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          versionName != null
              ? 'version_name'.tr() + versionName!
              : 'version_name'.tr() + 'Loading...',
          style: TextStyle(
            fontFamily: 'GR',
            color: Colors.grey[300],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showServerSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return ServerSelectionModal(
          selectedServer: selectedServer,
          onServerSelected: (server) {
            String? logoPath;
            if (server == 'auto') {
              logoPath = 'assets/images/auto.png';
            } else if (server == 'mci') {
              logoPath = 'assets/images/mci.png';
            } else if (server == 'mtn') {
              logoPath = 'assets/images/mtn.png';
            }
            setState(() {
              selectedServer = server;
            });
            _saveServerSelection(server, logoPath!);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showLogsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) => LogsModal(logs: logsNotifier),
    );
  }

  void _showTypeSelectionModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return ConnectionTypeModal(
          currentType: Ctype,
          onTypeSelected: (type) {
            setState(() {
              Ctype = type;
            });

            if (singStatus.value.state == 'CONNECTED') {
              bcoreDesktop.stopV2Ray();
              disableSystemProxy();
            }
          },
        );
      },
    );
  }

  void disableSystemProxy() async {
    var command = '''
    Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings" -Name ProxyEnable -Value 0 -Force;
    ''';

    var result = await Process.run('powershell', ['-Command', command]);

    if (result.exitCode == 0) {
      logsNotifier.value += 'System Proxy Disabled\n';
    } else {
      logsNotifier.value += 'Error disabling system proxy: ${result.stderr}\n';
    }
  }

  void serverDelay() async {
    try {
      setState(() {
        connectedServerDelay = null;
      });

      final response = await Dio().get(
          "http://127.0.0.1:9090/group/proxy/delay?url=https%3A%2F%2Fwww.gstatic.com%2Fgenerate_204&timeout=2000");
      final data = response.data;

      if (mounted && data is Map) {
        final firstEntry = data.entries.first;
        final delay = firstEntry.value;

        if (delay != null) {
          setState(() {
            connectedServerDelay = delay as int;
          });
        } else {
          setState(() {
            connectedServerDelay = -1;
          });
        }
      }
    } catch (e) {
      setState(() {
        connectedServerDelay = -1;
      });
    }
  }

  Future<void> _loadServerSelection() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedServer = _prefs.getString('selectedServer') ?? 'auto ';
      selectedServerLogo =
          _prefs.getString('selectedServerLogo') ?? 'assets/images/auto.png';
    });
  }

  Future<void> _saveServerSelection(String server, String logoPath) async {
    await _prefs.setString('selectedServer', server);
    await _prefs.setString('selectedServerLogo', logoPath);
    setState(() {
      selectedServer = server;
      selectedServerLogo = logoPath;
    });
  }

  Future<List<String>> getDeviceArchitecture() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.supportedAbis;
  }

  void getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionName = packageInfo.version;
    });
  }

  String decrypt(String secureData, String x1, String x2, String key) {
  final encryptedData = {
    'ciphertext': secureData, // secure
    'nonce': x1, // x1
    'tag': x2 // x2
  };
  final savedKey = key;
    try {
    final decrypted = Decryptor.decryptChaCha20(encryptedData, savedKey);
      return decrypted.toString();
    } catch (e) {
      return 'Error during decryption: $e';
    }
  }

  Future<void> getDomain() async {
    try {
              singStatus.value = SingStatus(
            state: 'CONNECTING',
            duration: "00:00:00",
            uploadSpeed: 0,
            downloadSpeed: 0,
            upload: 0,
            download: 0);
            
      setState(() {
        isLoading = true;
      });
      final response = await httpClient.get('/');      
      domainName = response.data;
      checkUpdate();
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_access_data'.tr()),
          ),
        );
      }
    }
  }

  void checkUpdate() async {
    try {
      //final serverParam = getServerParam();
      String userKey = await storage.read(key: 'user') ?? '';
      if(userKey == ''){
        final response = await Dio().get("https://$domainName/api/firebase/init/android"); // change latar
        final dataJson = response.data as Map<String, dynamic>;
        final key = dataJson['key'];
        userKey = key;
        await storage.write(key: 'user', value: key);
      }else{
        userKey = await storage.read(key: 'user') ?? '';
      } 


      final response = await Dio().get("https://$domainName/api/firebase/init/data/$userKey"); // change latar
      final dataJson = response.data as Map<String, dynamic>;
      if(dataJson['status'] == true){
        final secureData = dataJson['data']['secure'];
        final x1 = dataJson['data']['x1'];
        final x2 = dataJson['data']['x2'];

        final serverEncode = decrypt(secureData, x1, x2, userKey);
    
        final List<String> serverList = await fetchServers(serverEncode);
        print(serverList);
        await connect(serverList);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(dataJson['error'].toString()),
          ),
        );
      }


      // final data_base64 = utf8.decode(base64.decode(response.data));

      // final decode_json = jsonDecode(data_base64);
      // final dec = jsonDecode(decrypt(decode_json['data']));
      // final version = dec['version'];
      // final serverEncode = dec['server'];

      // if (version == versionName) {
      //   final List<String> serverList = await fetchServers(serverEncode);
      //   await connect(serverList);
      // } else {
      //   List<String> getArchitecture = await getDeviceArchitecture();
      //   String updateUrl = '';

      //   bool isV8aDevice = getArchitecture.contains("arm64-v8a");
      //   bool isV7aInstalled = false;

      //   for (String element in getArchitecture) {
      //     if (element == "armeabi-v7a") {
      //       isV7aInstalled = true;
      //     }
      //   }

      //   if (isV7aInstalled && isV8aDevice) {
      //     updateUrl = dec['url-v7a'];
      //   } else {
      //     for (String element in getArchitecture) {
      //       if (element == "arm64-v8a") {
      //         updateUrl = dec['url-v8a'];
      //         break;
      //       } else if (element == "armeabi-v7a") {
      //         updateUrl = dec['url-v7a'];
      //         break;
      //       }
      //     }
      //   }

        // if (updateUrl.isNotEmpty) {
        //   AwesomeDialog(
        //     context: context,
        //     dialogType: DialogType.warning,
        //     animType: AnimType.rightSlide,
        //     title: 'آپدیت جدید',
        //     desc: 'برای دانلود ورژن جدید روی دکمه دانلود کلیک کنید',
        //     dialogBackgroundColor: Colors.white,
        //     btnCancelOnPress: () {},
        //     btnOkOnPress: () async {
        //       await launchUrl(Uri.parse(utf8.decode(base64Decode(updateUrl))),
        //           mode: LaunchMode.externalApplication);
        //     },
        //     btnOkText: 'دانلود',
        //     btnCancelText: 'بستن',
        //     buttonsTextStyle:
        //         TextStyle(fontFamily: 'sm', color: Colors.white, fontSize: 14),
        //     titleTextStyle:
        //         TextStyle(fontFamily: 'sb', color: Colors.black, fontSize: 16),
        //     descTextStyle:
        //         TextStyle(fontFamily: 'sm', color: Colors.black, fontSize: 14),
        //   ).show();
        // } else {
        //   if (mounted) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(
        //         content: Text('نسخه ی مجاز پدیت برای گوشی شما یافت نشد !'),
        //       ),
        //     );
        //   }
        // }
      // }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('خطا در بررسی نسخه اپلیکیشن، لطفاً مجدداً تلاش کنید.'),
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<String>> fetchServers(String serverEncode) async {
    try {
      final List<String> serverList =
          LineSplitter.split(serverEncode).toList();
      return serverList;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('خطا در دریافت اطلاعات از سرور، طفاً مجدداً تلاش کنید.'),
          ),
        );
      }
      return [];
    }
  }

  Future<void> connect(List<String> serverList) async {
    final link = serverList;

    setState(() {
      isLoading = true;
      isFetchingPing = true;
    });

    logsNotifier.value += 'Connecting to server...\n';
    logsNotifier.value +=
        'Settings : 🌍Connection Type: $Ctype | 🌍ProxyShare: $isProxyShareEnabled | ♾️AdBlock: $isAdBlockEnabled | 📱DNS: $selectedDNS \n';

    final parser = V2raySingParser();
    await parser.parse(
        link, Ctype, isProxyShareEnabled, isAdBlockEnabled, selectedDNS);

    parser.log["level"] = selectedLogLevel;
    final configuration = parser.json();

    bcoreDesktop.startV2Ray(config: configuration);
    //singStatus.value = SingStatus(state: 'CONNECTED');

    try {
      setState(() {
        connectedServerDelay = null;
      });

      final response = await Dio().get(
          "http://127.0.0.1:9090/group/proxy/delay?url=https%3A%2F%2Fwww.gstatic.com%2Fgenerate_204&timeout=2000");
      final data = response.data;

      if (mounted && data is Map) {
        final firstEntry = data.entries.first;
        final delay = firstEntry.value;

        if (delay != null) {
          setState(() {
            connectedServerDelay = delay as int;
          });
        } else {
          setState(() {
            connectedServerDelay = -1;
          });
        }
      }
    } catch (e) {
      setState(() {
        connectedServerDelay = -1;
      });
    }
  }

  String getServerParam() {
    if (selectedServer == 'MCI') {
      return 'mci';
    } else if (selectedServer == 'IRANCELL') {
      return 'mtn';
    } else {
      return 'auto';
    }
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

  void updateSettings() async {
    await _loadSettings();
    if (singStatus.value.state == 'CONNECTED') {
      singStatus.value = SingStatus(state: 'DISCONNECTED');
      bcoreDesktop.stopV2Ray();
      disableSystemProxy();
      getDomain();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      updateSettings();
    }
  }

  bool _isInitialized = false;
}
