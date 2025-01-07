import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bcore/utils/utils.dart';
import 'package:path/path.dart' as path;

export 'v2ray_parser.dart';

class BcoreStatus {
  final Duration duration;
  final String state;
  final int download;
  final int upload;
  final int totalDownload;
  final int totalUpload;

  const BcoreStatus({
    this.duration = const Duration(),
    this.state = 'DISCONNECTED',
    this.download = 0,
    this.upload = 0,
    this.totalDownload = 0,
    this.totalUpload = 0,
  });

  @override
  String toString() => 
    'BcoreStatus(duration: $duration, state: $state, download: $download, upload: $upload, totalDownload: $totalDownload, totalUpload: $totalUpload)';
}

class BcoreDesktop {
  final void Function(String log) logListner;
  final void Function(BcoreStatus status) statusListner;
  Process? _sing;
  bool _isShuttingDown = false;
  WebSocketChannel? _trafficChannel;

  BcoreDesktop({required this.logListner, required this.statusListner});

  void _handleError(String message, [Object? error]) {
    logListner.call('[begzar] Error: $message ${error ?? ''}');
    statusListner.call(const BcoreStatus(state: 'DISCONNECTED'));
    _cleanupResources();
  }

  void _cleanupResources() {
    _sing = null;
    _trafficChannel?.sink.close();
    _trafficChannel = null;
    _isShuttingDown = false;
  }

  Future<void> _runXRay(String config) async {
    try {
      if (_sing != null) {
        logListner.call('[begzar] sing-box is already running');
        return;
      }

      _isShuttingDown = false;
      final xpath = await getSingPath();
      if (xpath == null) {
        throw Exception('sing-box path not found');
      }

      final configFile = File(path.join(xpath, 'config.json'));
      await configFile.writeAsString(config);

      _sing = await Process.start(
        path.join(xpath, 'begzar_box'),
        ['run', '-c', configFile.path, '--disable-color'],
      );

      logListner.call('[begzar] Started with PID: ${_sing?.pid}');

      _setupProcessListeners();
    } catch (e) {
      _handleError('Failed to start sing-box', e);
      rethrow;
    }
  }

  void _setupProcessListeners() {
    _sing?.stdout.listen(
      (event) => logListner.call('[sing-box] ${utf8.decode(event)}'),
      onError: (error) => _handleError('stdout error', error),
      onDone: () {
        logListner.call('[begzar] stdout stream closed');
        if (!_isShuttingDown) _handleError('Process terminated unexpectedly');
      },
    );

    _sing?.stderr.listen(
      (event) => logListner.call('[begzar] ${utf8.decode(event)}'),
      onError: (error) => _handleError('stderr error', error),
      onDone: () {
        logListner.call('[begzar] stderr stream closed');
        if (!_isShuttingDown) _handleError('Process terminated unexpectedly');
      },
    );

    _sing?.exitCode.then((code) {
      if (!_isShuttingDown) {
        _handleError('Process exited unexpectedly with code: $code');
      }
    });
  }

  Future<void> _getTraffic() async {
    int previousDown = 0;
    int previousUp = 0;
    int totalUpload = 0;
    int totalDownload = 0;
    
    try {
      _trafficChannel = WebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:9090/traffic'),
      );

      _trafficChannel?.stream.listen(
        (message) {
          try {
            final trafficData = jsonDecode(message);
            final currentUp = trafficData['up'] as int;
            final currentDown = trafficData['down'] as int;
            
            if (currentDown != 0 || currentUp != 0) {
              totalUpload += currentUp;
              totalDownload += currentDown;

              statusListner.call(BcoreStatus(
                upload: totalUpload - previousUp,
                download: totalDownload - previousDown,
                totalUpload: totalUpload,
                totalDownload: totalDownload,
                state: 'CONNECTED',
                duration: const Duration(seconds: 1),
              ));

              previousUp = totalUpload;
              previousDown = totalDownload;
            }
          } catch (e) {
            _handleError('Failed to process traffic data', e);
          }
        },
        onError: (error) => _handleError('Traffic API error', error),
        onDone: () => logListner.call('[begzar] Traffic API connection closed'),
      );
    } catch (e) {
      _handleError('Failed to connect to Traffic API', e);
    }
  }

  Future<void> _forceKillAllSingBox() async {
    try {
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/F', '/IM', 'begzar_box.exe']);
      } else {
        final result = await Process.run('pkill', ['-9', 'begzar_box']);
        if (result.exitCode != 0) {
          throw Exception(result.stderr);
        }
      }
      logListner.call('[begzar] Process killed successfully');
    } catch (e) {
      _handleError('Failed to kill process', e);
    }
  }

  Future<void> _stopXRay() async {
    _isShuttingDown = true;
    await _forceKillAllSingBox();
    _cleanupResources();
  }

  Future<void> _startStatusTimer() async {
    if (!isXrayRunning()) {
      _handleError('Process is not running');
      return;
    }
    
    await Future.delayed(const Duration(seconds: 3));
    logListner.call('[begzar] Connection established, loading traffic info...');
    await _getTraffic();
  }

  Future<void> startV2Ray({required String config}) async {
    await _runXRay(config);
    await _startStatusTimer();
  }

  Future<void> stopV2Ray() async {
    await _stopXRay();
    statusListner.call(const BcoreStatus(state: 'DISCONNECTED'));
  }

  bool isXrayRunning() {
    if (_sing == null) return false;
    try {
      return _sing!.pid != 0;
    } catch (e) {
      _handleError('Failed to check process status', e);
      return false;
    }
  }
}
