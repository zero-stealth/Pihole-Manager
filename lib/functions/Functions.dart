import 'dart:convert';

import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

checkClient(ip, requests) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      var myclients = await dbHelper.queryAllRows('clients');

      for (var i = 0; i < myclients.length; i++) {
        if (ip == myclients[i]['ip']) {
          print("[-] $ip already exists in db");
          return;
        }
      }

      Map<String, dynamic> row = {
        "name": "none",
        "ip": ip,
        "requests": requests
      };

      await dbHelper.insert(row, "clients");
      print("[+] Added $ip to clients db");
      return;
    } catch (e) {
      print('ERROR');
      print(e);
    }
  }

setClients() async {
    final dbHelper = DatabaseHelper.instance;
    var devices = await dbHelper.queryAllRows('devices');

    for (var i = 0; i < devices.length; i++) {
      final res = await http.Client().get(Uri.parse(
          'http://${devices[i]['ip']}/admin/api.php?topClients&auth=${devices[i]['apitoken']}'));
      if (res.statusCode == 200) {
        var pars = jsonDecode(res.body);
        // print('CLIENTS: $pars');
        // print(pars['top_sources'].keys.elementAt(2));

        // print(pars['top_sources'].length);

        for (var i = 0; i < pars['top_sources'].length; i++) {
          var key = pars['top_sources'].keys.elementAt(i);
          var value = pars['top_sources']['$key'];
          var data = [
            {'ip': key},
            {'requests': value}
          ];

          await checkClient(key, value);
        }
      }
    }
  }