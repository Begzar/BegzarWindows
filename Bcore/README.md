# bcore

## Examples

### URL Parser

```dart
import 'package:bcore/bcore.dart';

// v2ray share link like vmess://, vless://, ...
final link = "link_here";


// create quick parser
final parser = V2raySingParser();

await parser.parse(link);

// sing-box config has log, dns, ntp, inbounds, outbounds, route, experimental
// more details in https://sing-box.sagernet.org/configuration/

// Edit sing-box configuartion
parser.log["disabled"] = true;
parser.log["level"] = "info";
parser.dns["servers"] = ['1.1.1.1', '8.8.8.8'];

// generate json configuration
final String configuration = parser.json()
```

### Making connection

#### Three Types of Connections Exist

```dart
ConnectionType { proxy, systemProxy, vpn }
```

* proxy: Only the sing-box is executed.

* systemProxy: The sing-box is executed and then the system proxy settings are set to the proxy created by the sing-box.

* vpn: The sing-box is executed and tun2socks creates a tun using the proxy created by the sing-box. Then, the entire system's settings pass through the created tun. (Requires Adminstrator on Windows and sudo on Linux and macOS)


```dart
final v2ray = BcoreDesktop(
    statusListner: (status) {
        // status of v2ray
        // During connection, it is called every second
        // Upload and download values are in bytes
        final totalDownloadMB = status.totalDownload / 1024 / 1024;
        final totalUploadMB = status.totalUpload / 1024 / 1024;

    },
    logListner: (log) {
        // sing-box logs are prefixed with [sing-box]
        // tun2socks logs are prefixed with [tun2socks]
    },
);


v2ray.startV2Ray(config: configuration, connectionType: ConnectionType.systemProxy);

// Disconnect
v2ray.stopV2Ray();
```
