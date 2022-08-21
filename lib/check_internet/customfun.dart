import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CustomFunction {
  void showInSnackBar({bool? networkState, scaffoldKey}) {
    var networkStateTxt = "Null";
    if (networkState == true) {
      networkStateTxt = "Connected";
    } else {
      networkStateTxt = "No Connection";
    }
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          networkStateTxt,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        duration: (const Duration(seconds: 3)),
        elevation: 10,
        backgroundColor:
            (networkState == true ? Colors.greenAccent : Colors.redAccent),
      ),
    );
  }

  void showError(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('INTERNET ERROR?',
            style: TextStyle(color: Colors.black, fontSize: 20.0)),
        content: const Text(
            'Please Connect to an internet, or check your internet connection'),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context), // this line dismisses the dialog
            child: const Text('OK', style: TextStyle(fontSize: 18.0)),
          )
        ],
      ),
    );
  }

  Future<bool> checkInternetAccess() {
    final List<InternetAddress> dnss = [
      InternetAddress('8.8.8.8', type: InternetAddressType.IPv4),
      // Google
      InternetAddress('8.8.4.4', type: InternetAddressType.IPv4),
      // Google
      InternetAddress('2001:4860:4860::8888', type: InternetAddressType.IPv6),
      // Google
      InternetAddress('1.1.1.1', type: InternetAddressType.IPv4),
      // CloudFlare
      InternetAddress('1.0.0.1', type: InternetAddressType.IPv4),
      // CloudFlare
      InternetAddress('2606:4700:4700::1111', type: InternetAddressType.IPv6),
      // CloudFlare
      InternetAddress('208.67.222.222', type: InternetAddressType.IPv4),
      // OpenDNS
      InternetAddress('208.67.220.220', type: InternetAddressType.IPv4),
      // OpenDNS
      InternetAddress('2620:0:ccc::2', type: InternetAddressType.IPv6),
      // OpenDNS
      InternetAddress('180.76.76.76', type: InternetAddressType.IPv4),
      // Baidu
      InternetAddress('2400:da00::6666', type: InternetAddressType.IPv6),
      // Baidu
    ];

    final Completer<bool> completer = Completer<bool>();

    int callsReturned = 0;
    void onCallReturned(bool isAlive) {
      if (completer.isCompleted) return;

      if (isAlive) {
        completer.complete(true);
      } else {
        callsReturned++;
        if (callsReturned >= dnss.length) {
          completer.complete(false);
        }
      }
    }

    for (var dns in dnss) {
      _pingDns(dns).then(onCallReturned);
    }

    return completer.future;
  }

  Future<bool> _pingDns(InternetAddress dnsAddress) async {
    const int dnsPort = 53;
    const Duration timeout = Duration(seconds: 2);

    late Socket? socket;
    try {
      socket = await Socket.connect(dnsAddress, dnsPort, timeout: timeout);
      socket.destroy();
      return true;
    } on SocketException {}
    return false;
  }

  Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      if (await InternetConnectionChecker().hasConnection) {
        // Mobile data detected & internet connection confirmed.
        return true;
      } else {
        // Mobile data detected but no internet connection found.
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a WIFI network, make sure there is actually a net connection.
      if (await InternetConnectionChecker().hasConnection) {
        // Wifi detected & internet connection confirmed.
        return true;
      } else {
        // Wifi detected but no internet connection found.
        return false;
      }
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }
}
