import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

// checks if the client exists on the database
// updates requests count if they do
// creates the client if the do not
checkClient(ip, requests) async {
  try {
    final dbHelper = DatabaseHelper.instance;
    var myclients = await dbHelper.queryAllRows('clients');

    for (var i = 0; i < myclients.length; i++) {
      if (ip == myclients[i]['ip']) {
        print("[-] $ip already exists in db");
        print("[+] UPDATING REQUESTS COUNT INSTEAD");

        Map<String, dynamic> row = {
          "_id": myclients[i]['_id'],
          "requests": requests,
        };
        await dbHelper.update(row, "clients");

        return;
      }
    }

    Map<String, dynamic> row = {
      "name": "none",
      "ip": ip,
      "requests": requests,
    };

    await dbHelper.insert(row, "clients");
    print("[+] Added $ip to clients db");
    return;
  } catch (e) {
    print('ERROR');
    print(e);
  }
}

// search for clients name in the db
// if its not set return their ip
// if set, return the name
findClientName(ip) async {
  print("SENT $ip");
  final dbHelper = DatabaseHelper.instance;
  var clients = await dbHelper.queryAllRows('clients');

  for (var i = 0; i < clients.length; i++) {
    if (ip == clients[i]['ip']) {
      print("SENT $ip - FOUND IP ${clients[i]['ip']}");
      if (clients[i]['name'] == "none") {
        return ip.toString();
      } else {
        return clients[i]['name'].toString();
      }
    }
  }
}

// Get around formatting issue in pihole
// Everything before the | in the client ip
// will be considered as their ip
// to minimize confusion
parseClientIp(ip) {
  for (var i = 0; i < ip.length; i++) {
    if (ip[i] == "|") {
      return ip.substring(0, i);
    }
  }

  return ip;
}

// check if client ip in the db 
// has the | character and change it to
// whatever comes ahead of that character
// and discarding the rest
fixdb() async {
  final dbHelper = DatabaseHelper.instance;
  var clients = await dbHelper.queryAllRows('clients');

  for (var i = 0; i < clients.length; i++) {
    if (clients[i]['ip'].contains("|")) {
      var newip = parseClientIp(clients[i]['ip']);
      
      Map<String, dynamic> row = {
        "_id": clients[i]['_id'],
        "ip": newip,
      };
      await dbHelper.update(row, "clients");
      print("[+] IP FIXED");
    }
  }

  return;
}

// Get all clients data from the api
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
        var parsedip = parseClientIp(key);
        var data = [
          {'ip': parsedip},
          {'requests': value}
        ];

        await checkClient(parsedip, value);
      }
    }
  }
}
