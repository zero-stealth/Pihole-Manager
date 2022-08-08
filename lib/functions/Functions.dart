import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:piremote/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

final dbHelper = DatabaseHelper.instance;

// checks if the client exists on the database
// updates requests count if they do
// creates the client if the do not
checkClient(ip, requests) async {
  try {
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

// Nuke logs to prevent piling up of old logs
// Only 100 logs should be in the database at one time
deleteAllLogs() async {
  try {
    var logs = await dbHelper.queryAllRows("logs");

    for (var i = 0; i < logs.length; i++) {
      await dbHelper.delete(logs[i]['_id'], "logs");
    }
    print("[+] NUKED ALL LOGS");
  } catch (e) {
    print("[-] NO LOGS DELETED");
  }
}

// Nuke queries from the database before adding new ones
deleteAllQueries() async {
  try {
    var t1 = await dbHelper.queryAllRows("topQueries");
    var t2 = await dbHelper.queryAllRows("topAds");

    for (var i = 0; i < t1.length; i++) {
      await dbHelper.delete(t1[i]['_id'], "topQueries");
    }

    for (var n = 0; n < t2.length; n++) {
      await dbHelper.delete(t2[n]['_id'], "topAds");
    }

    print("[+] NUKED ALL QUERIES");
  } catch (e) {
    print("[-] NO QUERIES DELETED");
  }
}

// LOGS
// Fetch logs and add them to the db
fetchLogs() async {
  var devices = await dbHelper.queryAllRows('devices');

  for (var i = 0; i < devices.length; i++) {
    final res = await http.Client().get(Uri.parse(
        'http://${devices[i]['ip']}/admin/api.php?getAllQueries=100&auth=${devices[i]['apitoken']}'));
    if (res.statusCode == 200) {
      await deleteAllLogs();
      var pars = jsonDecode(res.body);
      // print(DateTime.parse(pars['data'][0][0].toDate().toString()));

      // var timestamp = DateTime.parse('1658126697');

      // // print(d);
      // var date = DateTime.fromMicrosecondsSinceEpoch(1658126697 * 1000, isUtc: false);
      // String formattedTime = DateFormat.jm().format(date);
      // print(date);

      try {
        for (var n = 0; n < pars['data'].length; n++) {
          var clientName = await findClientName(pars['data'][n][3]);

          Map<String, dynamic> row = {
            "timestamp": pars['data'][n][0],
            "requestType": pars['data'][n][1],
            "domain": pars['data'][n][2],
            "type": pars['data'][n][2],
            "client": clientName,
          };

          await dbHelper.insert(row, "logs");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

// Fetch query statistics and load them
// into the database

fetchTopQueries() async {
  var devices = await dbHelper.queryAllRows('devices');

  for (var i = 0; i < devices.length; i++) {
    final res = await http.Client().get(Uri.parse(
        'http://${devices[i]['ip']}/admin/api.php?topItems&auth=${devices[i]['apitoken']}'));
    if (res.statusCode == 200) {
      await deleteAllQueries();
      var pars = jsonDecode(res.body);
      // print('CLIENTS: $pars');
      // print(pars['top_sources'].keys.elementAt(2));

      // print(pars['top_sources'].length);

      for (var i = 0; i < pars['top_queries'].length; i++) {
        var key = pars['top_queries'].keys.elementAt(i);
        var value = pars['top_queries']['$key'];

        Map<String, dynamic> row = {
          "url": key,
          "requests": value,
        };

        await dbHelper.insert(row, "topQueries");
      }

      for (var i = 0; i < pars['top_ads'].length; i++) {
        var key = pars['top_ads'].keys.elementAt(i);
        var value = pars['top_ads']['$key'];
        var data = [
          {'url': key},
          {'requests': value}
        ];

        Map<String, dynamic> otherrow = {
          "url": key,
          "requests": value,
        };

        await dbHelper.insert(otherrow, "topAds");
      }
    } else {
      return;
    }
  }
}


test_ip() async {
    var devices = await dbHelper.queryAllRows('devices');

    try {
      // var prot = setprotocol();
      var url = '${devices[0]['protocol']}://${devices[0]['ip']}';
      // /admin/api.php?getAllQueries=100&auth=
      final response = await http.get(Uri.parse('$url/admin/api.php?summary'));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }