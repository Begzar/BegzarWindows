import 'dart:convert';
import 'dart:io';
import 'package:bcore/utils/utils.dart';
import 'package:path/path.dart' as path;
import '../v2ray_parser.dart';

typedef JsonObject = Map<String, dynamic>;

class V2raySingParser {
  final List<JsonObject> outbounds = [];
  final List<JsonObject> inbounds = [];
  final JsonObject ntp = {};
  final JsonObject log = {};
  final JsonObject route = {};
  final JsonObject experimental = {};
  final JsonObject dns = {};
  final JsonObject tunnel = {};

  String remark = "dart_v2ray_parser";
  String server = "127.0.0.1";

  V2raySingParser();

  Future<Map<String, dynamic>> linkToOutbound(String link) async {
    final p = await getSingPath();
    if (p == null) {
      throw V2rayParserError;
    }
    final res = await Process.run(path.join(p, "sing-parser"), ['-link',link]);
    if (res.exitCode != 0) {
      throw V2rayParserError;
    }
    final raw = (res.stdout as String);
    final json = jsonDecode(raw);
    return Map<String, dynamic>.from(json);
  }

  Future<void> parse(
      List<String> link, String confType, bool isProxyShareEnabled, bool isAdBlockEnabled, String selectedDNS) async {
    if (isProxyShareEnabled) {
      server = "0.0.0.0";
    } else {
      server = "127.0.0.1";
    }

    print("server started at: $server:7828");

    dns.addAll({
      "servers": [
        {
          "address": selectedDNS == "Google"
              ? "tcp://8.8.8.8"
              : selectedDNS == "Cloudflare"
                  ? "tcp://1.1.1.1"
                  : "tcp://8.8.8.8",
          "address_resolver": "dns-direct",
          "strategy": "prefer_ipv4",
          "detour": "proxy",
          "tag": "dns-remote"
        },
        {
      "address": "223.5.5.5",
          "detour": "direct",
          "tag": "dns-direct"
        },
        {"address": "rcode://success", "tag": "dns-block"}
      ],
      "rules": [
        {"outbound": "any", "server": "dns-direct"},
        {
          "disable_cache": true,
          "rule_set": [
            isAdBlockEnabled ? "geosite-category-ads-all" : "geosite-malware-fake",
            "geosite-malware",
            "geosite-phishing",
            "geosite-cryptominers"
          ],
          "server": "dns-block"
        }
      ],
      "independent_cache": true
    });

    if (confType == 'vpn') {
      inbounds.add({
        "type": "direct",
        "tag": "dns-in",
        "listen": "0.0.0.0",
        "listen_port": 6450,
        "override_address": selectedDNS == "Google"
              ? "8.8.8.8"
              : selectedDNS == "Cloudflare"
                  ? "1.1.1.1"
                  : "8.8.8.8",
        "override_port": 53
      });
      inbounds.add({
        "type": "tun",
        "tag": "tun-in",
        "inet4_address": "172.15.0.1/28",
        "inet6_address": "fdfe:dcba:9876::2/126",
        "interface_name": "begzar",
        "mtu": 9000,
        "auto_route": true,
        "strict_route": true,
        "stack": "mixed",
        "sniff": true,
        "sniff_override_destination": true
      });
      inbounds.add({
        "type": "mixed",
        "tag": "mixed-in",
        "listen": server,
        "listen_port": 7828,
        "sniff": true,
        "sniff_override_destination": false
      });
    } else if (confType == 'systemProxy') {
      inbounds.add({
        "type": "mixed",
        "tag": "mixed-in",
        "listen": server,
        "listen_port": 7828,
        "sniff": true,
        "sniff_override_destination": true,
        "set_system_proxy": true
      });
    } else if (confType == 'proxyOnly') {
      inbounds.add({
        "type": "mixed",
        "tag": "mixed-in",
        "listen": server,
        "listen_port": 7828,
        "sniff": true,
        "sniff_override_destination": true,
        "set_system_proxy": false
      });
    }

    List urlTestOut = [];
    int x = 0;
    for (String outTag in link) {
      x++;

      outTag = '${outTag.split('#')[0]}#$x';

      if (outTag.contains('splithttp') || outTag.contains('splitHttp') || x > 6) {
        print('skip');
      }else{
        
        final tag = await linkToOutbound(outTag);
        urlTestOut.add(tag['tag']);
      }
    }
    addOutbound({
      "type": "selector",
      "tag": "proxy",
      "outbounds": ["url_test_out", ...urlTestOut]
    });

    addOutbound({
      "type": "urltest",
      "tag": "url_test_out",
      "outbounds": [...urlTestOut],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "8s"
    });

    // cleaning configs for singbox
    int i = 0;
    for (String singleLink in link) {
      i++;
      singleLink = "${singleLink.split('#')[0]}#$i";
      if (singleLink.contains('splithttp') || singleLink.contains('splitHttp') || i > 6) {
        print('skip');
      }else{
        final outbound = await linkToOutbound(singleLink);
        print(singleLink);
        addOutbound(outbound);
      }

    }

    addOutbound({"type": "direct", "tag": "direct"});
    addOutbound({"type": "block", "tag": "block"});
    addOutbound({"type": "dns", "tag": "dns-out"});
    route.addAll({
      "rules": [
        {"inbound": "dns-in", "outbound": "dns-out"},
        {"network": "udp", "port": 53, "outbound": "dns-out"},
        {
          "rule_set": [
            isAdBlockEnabled ? "geosite-category-ads-all" : "geosite-malware-fake",
            "geosite-malware",
            "geosite-phishing",
            "geosite-cryptominers",
            "geoip-malware",
            "geoip-phishing"
          ],
          "outbound": "block"
        },
        {
          "ip_cidr": ["224.0.0.0/3", "ff00::/8"],
          "source_ip_cidr": ["224.0.0.0/3", "ff00::/8"],
          "outbound": "block"
        }
      ],
      "rule_set": [
        isAdBlockEnabled
            ? {
                "type": "remote",
                "tag": "geosite-category-ads-all",
                "format": "binary",
                "url":
                    "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geosite-category-ads-all.srs",
                "download_detour": "direct"
              }
            : {
                "type": "remote",
                "tag": "geosite-malware-fake",
                "format": "binary",
                "url":
                    "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geosite-malware.srs",
                "download_detour": "direct"
              },
        {
          "type": "remote",
          "tag": "geosite-malware",
          "format": "binary",
          "url":
              "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geosite-malware.srs",
          "download_detour": "direct"
        },
        {
          "type": "remote",
          "tag": "geosite-phishing",
          "format": "binary",
          "url":
              "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geosite-phishing.srs",
          "download_detour": "direct"
        },
        {
          "type": "remote",
          "tag": "geosite-cryptominers",
          "format": "binary",
          "url":
              "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geosite-cryptominers.srs",
          "download_detour": "direct"
        },
        {
          "type": "remote",
          "tag": "geoip-malware",
          "format": "binary",
          "url":
              "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geoip-malware.srs",
          "download_detour": "direct"
        },
        {
          "type": "remote",
          "tag": "geoip-phishing",
          "format": "binary",
          "url":
              "https://raw.githubusercontent.com/Chocolate4U/Iran-sing-box-rules/rule-set/geoip-phishing.srs",
          "download_detour": "direct"
        }
      ],
      "auto_detect_interface": true,
      "override_android_vpn": true,
      "final": "proxy"
    });

    ntp.addAll({
      "enabled": true,
      "server": "time.apple.com",
      "server_port": 123,
      "detour": "direct",
      "interval": "30m"
    });
    experimental.addAll({
      "cache_file": {"enabled": true, "store_fakeip": true},
      "clash_api": {
        "external_controller": "0.0.0.0:9090",
        "default_mode": "rule"
      }
    });
  }

  void addOutbound(JsonObject config) {
    if (getTagIndex(config['tag']) == null) {
      outbounds.add(config);
    } else {
      throw V2rayParserError(V2rayParserErrorType.tagIsExist);
    }
  }

  void removeOutbound(String tag) {
    final index = getTagIndex(tag);
    if (index == null) {
      throw V2rayParserError(V2rayParserErrorType.tagNotFounded);
    }
    outbounds.removeAt(index);
  }

  int? getTagIndex(String? tag) {
    int index = outbounds.indexWhere((element) => element['tag'] == tag);
    return index == -1 ? null : index;
  }

  JsonObject get config {
    return {
      'log': log,
      'dns': dns,
      'ntp': ntp,
      'inbounds': inbounds,
      'outbounds': outbounds,
      'route': route,
      'experimental': experimental,
    };
  }

  String json({String indent = ' ', int indentCount = 2}) {
    return JsonEncoder.withIndent(indent * indentCount).convert(config);
  }
}
