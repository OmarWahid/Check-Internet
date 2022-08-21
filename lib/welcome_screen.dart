import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'check_internet/customfun.dart';
import 'check_internet/locator.dart';


class FirstScreen extends StatefulWidget {
  const FirstScreen({
    Key? key,
  }) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  var funcFile = locator<CustomFunction>();
  bool sendMe = false;
  bool connected = false;
  int amAlreadyConnected = 0;
  Timer? timer;
  @override
  void initState() {
    checkMyInternet();
    internetCheck();
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => internetCheck());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  checkMyInternet() {
    funcFile.isInternet().then((value) =>
        funcFile.checkInternetAccess().then((value2) => value && value2
            ? setState(() {
                sendMe = true;
              })
            : setState(() {
                sendMe = false;
              })));
  }

  internetCheck() async {
    var theInternet = await funcFile.isInternet();
    var theInternet2 = await funcFile.checkInternetAccess();

    if (theInternet && theInternet2) {
      setState(() {
        connected = true;
      });
      if (amAlreadyConnected == 0 && connected == true) {
        setState(() {
          amAlreadyConnected = 1;
        });
      }
    } else {
      setState(() {
        connected = false;
        amAlreadyConnected = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white60,
      body: SingleChildScrollView(
        child: (connected == false
            ? SizedBox(
                height: height,
                child: Image.asset(
                  "assets/disconnect.jpeg",
                  fit: BoxFit.cover,
                ))
            : Center(
                child: SizedBox(
                  height: height,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 40),
                        child: Text(
                          'VIS',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 34),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                        child: Text(
                          'ONE OF THE BEST WAYS TO CHECK WHEATHER THERE IS AN INTERNET CONNECTION AVAILABLE ON A FLUTTER APP',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        child: SizedBox(
                            height: 250,
                            width: 800,
                            // width: MediaQuery.of(context).size.width,
                            child: Image.network(
                                "https://drive.google.com/uc?export=view&id=1L-HeExXJVZMiNPD2CxqBn3Wprrjjz8te")),
                      ),
                      SizedBox(
                        width: 300,
                        child: MaterialButton(
                          onPressed: () {
                            checkMyInternet();
                            if (sendMe) {
                              toast("YEA YOU CONNECTED",
                                  gravity: ToastGravity.CENTER,
                                  bgColor: Colors.greenAccent);
                            } else {
                              toast("No Internet",
                                  gravity: ToastGravity.CENTER,
                                  bgColor: Colors.red);
                            }
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: const Text(
                            'DASHBOARD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                            ),
                          ),
                          color: Colors.red,
                          height: 45,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ),
    );
  }
}
