import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireuser/page_bluetooth/detail.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireuser/page_bluetooth/descriptor.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fireuser/page_bluetooth/scanresult.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
final service = FlutterBackgroundService();


Future<void> initializeService() async {
  // WidgetsFlutterBinding.ensureInitialized();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

void onIosBackground() {
  // WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');
}

void onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  // service.onDataReceived.listen((event) {
    //   if (event["action"] == "setAsForeground") {
    //     service.setForegroundMode(true);
    //     return;
    //   }

    //   if (event["action"] == "setAsBackground") {
    //     service.setForegroundMode(false);
    //   }

  //   if (event["action"] == "stopService") {
  //     service.stopBackgroundService();
  //   }
  // });

  // bring to foreground
  // service.setForegroundMode(true);
  Scan();
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    Scan();

    if (!(await service.isServiceRunning())) timer.cancel();
    // service.setNotificationInfo(
    //   title: "My App Service",
    //   content: "Updated at ${DateTime.now()}",
    // );
    // test using external plugin

    // service.sendData(
    //   {
    //     "current_date": DateTime.now().toIso8601String(),

    //   },
    // );
  });
}
class PageBluetooth extends StatelessWidget {
  static const sName = "/Blue";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: StreamBuilder<BluetoothState>(
        //偵測藍芽狀態
        stream: flutterBlue.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return FindDevicesScreen(); //開啟藍芽顯示清單頁面
          }
          return BluetoothOffScreen(); //沒開啟時顯示藍芽未開啟頁面
        },
      ),
    );
  }
}

//藍芽未開啟跳頁面
class BluetoothOffScreen extends StatefulWidget {
  @override
  _BluetoothOffScreen createState() => _BluetoothOffScreen();
}

class _BluetoothOffScreen extends State<BluetoothOffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, //將背景設為藍色
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 100.0,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

//藍芽顯示清單頁面
class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesScreen createState() => _FindDevicesScreen();
}

//藍牙開啟後進入到搜尋畫面，按下左下角搜尋，可以在四秒內搜尋附近可用藍芽裝置
class _FindDevicesScreen extends State<FindDevicesScreen> {
  CollectionReference _collection;
  

  @override
  void initState() {
    super.initState();
    _collection = FirebaseFirestore.instance.collection('NTUTLab321-5');
    //螢幕恆亮
    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    Timer _timer;
    CollectionReference data =
        FirebaseFirestore.instance.collection('NTUTLab321-5');
    return WillPopScope(
      //防跳出頁面，副程式_onWillPop()
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'NTUTLab321點滴、尿袋智慧監控系統-中繼器',
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await initializeService();
                  service.start();
                },
                icon: Icon(Icons.play_arrow)),
            IconButton(
                onPressed: () async {
                  service.sendData(
                    {"action": "stopService"},
                  );
                },
                icon: Icon(Icons.stop)),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => flutterBlue.startScan(
            timeout: Duration(seconds: 2),
          ), //下拉可scan
          child: SingleChildScrollView(
            //建立一個能捲動的Widget
            child: Column(
              children: <Widget>[
                // 已連線藍芽裝置tile
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(
                    Duration(seconds: 2),
                  ).asyncMap((_) => flutterBlue.connectedDevices),
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data
                        .map(
                          (d) => Padding(
                            padding: EdgeInsets.all(20.5),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 520.0,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.greenAccent,
                                            blurRadius: 20.0,
                                            offset: Offset(0, 10))
                                      ]),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      ExpansionTile(
                                        leading: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.devices,
                                              color: Colors.greenAccent,
                                            ),
                                          
                                          ],
                                        ),
                                        title: Text(
                                          "裝置編號",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          d.id.toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: ElevatedButton(
                                            child: Text(
                                              '設定完成',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.redAccent[100],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.lightBlue[50],
                                            ),
                                            onPressed: () {
                                              return showDialog(
                                                context: context, //警示對話框
                                                builder: (context) => SafeArea(
                                                  child: AlertDialog(
                                                    title: Text('設置院床號'),
                                                    content: Text('確定已完成設定' +
                                                        d.id.toString() +
                                                        '的所屬院床號?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text(
                                                          '是',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        onPressed: () {
                                                        
                                                          d.disconnect();
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          '否',
                                                          style: TextStyle(
                                                              fontSize: 30),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),

                                      //descriptor內容
                                      Builder(
                                        builder: (BuildContext context) =>
                                            DeviceScreen(
                                          device: d,
                                        ),
                                      ),
                                     
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                //未連線藍芽裝置tile
                StreamBuilder<List<ScanResult>>(
                  stream: flutterBlue.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data
                        .map(
                          (r) =>
                              //tile ui ScanResultTile()
                              ScanResultTile(
                            result: r,
                            onTap: () async {
                              // await r.device.connect(
                              //     autoConnect: false,
                              //     timeout: Duration(seconds: 10));
                              //await r.device.connect(autoConnect: false);

                              // _collection.doc('${r.device.id.toString()}').set({
                              //   'alarm': '0',
                              //   'change': '0',
                              //   'modedescription': '初始資料',
                              //   'power': '100',
                              //   'time': DateTime.now(),
                              //   'area': 'unused',
                              //   'judge': '請設定'
                              // });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          //scan紐
          //右下角按搜尋及停止的按鈕
          stream: flutterBlue.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () {
                  showMySnackBar(c, "已結束掃描");
                  flutterBlue.stopScan();
                  _timer.cancel();
                },
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                child: Icon(Icons.play_arrow),
                onPressed: () async {
                  showMySnackBar(c, "於5秒後開始");
                  WidgetsFlutterBinding.ensureInitialized();

                  Scan();
                  

                  // _timer = Timer.periodic(Duration(seconds: 60), (timer) {
                  //   Scan();
                  // });
                },
              );
            }
          },
        ),
      ),
    );
  }

  //如果要退出整個程式會跳出視窗再次確認，防止程式意外被關閉
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => SafeArea(
        child: AlertDialog(
          title: Text(
            '請勿退出',
            style: TextStyle(
              fontSize: 30,
            ),
          ),
          content: Row(children: <Widget>[
            Text(
              '若真要退出請按(是)後點選 ',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            Icon(Icons.home),
            Text(
              ' 鍵',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ]),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text(
                  '是',
                  style: TextStyle(fontSize: 25, color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
void Scan() {
  int a = 0;
  List<ScanResult> l = [];
  l.clear();
  flutterBlue.startScan(timeout: Duration(seconds: 3));

  flutterBlue.scanResults.listen((results) async {
    // List<ScanResult> l = results
    //     .where((e) => e.device.name == 'NTUT_LAB321_Product');
    results.map((e) {
      if (e.device.name == 'NTUT_LAB321_Product' ||
          e.device.name == "Nordic_HRM") {
        if (!l.contains(e.device.id)) {
          l.add(e);
        }

        // update(e.device.id.toString(),
        //     e.advertisementData.manufacturerData.toString());
      }
    }).toList();
    // print(l);
    // _timer.cancel();
    // print(a);
    // print(l.length);
    print("$a START");
    if (a == 0) {
      for (ScanResult s in l) {
        String alarm, change, modedescription, power;
        List<String> data = s.advertisementData.manufacturerData
            .toString()
            .split(":")[1]
            .replaceAll(" ", "")
            .replaceAll("}", "")
            .replaceAll("[", "")
            .replaceAll("]", "")
            .split(",");
        switch (data[0]) {
          case "0":
            modedescription = "尿袋";
            break;
          case "1":
            modedescription = "點滴";
            break;
          default:
            "未使用";
        }
        switch (data[1]) {
          case "0":
            alarm = "0";
            change = "0";
            break;
          case "1":
            alarm = "1";
            change = "1";
            break;
          case "4":
            alarm = "E";
            change = "1";
            break;
          case "5":
            alarm = "E";
            change = "1";
            break;
          default:
            "未使用";
        }
        if (int.parse(data[2]) >= 100) {
          power = "100";
        } else {
          power = data[2];
        }
        print("ppppp" +
            s.device.id.toString() +
            'alarm:' +
            alarm +
            'change:' +
            change +
            'modedescription+' +
            modedescription +
            'power:' +
            power +
            'time:' +
            DateTime.now().toString());
        update(
          s.device.id.toString(),
          alarm,
          change,
          modedescription,
          power,
        );

        print("id:" +
            s.device.id.toString() +
            "data:" +
            s.advertisementData.manufacturerData.toString());
      }
      a++;
    }
    print("$a END");
  });
}

Future update(String MAC, String alarm, String change, String modedescription,
    String power) async {
  await Firebase.initializeApp();

  CollectionReference _data =
      FirebaseFirestore.instance.collection('NTUTLab321-6');
  // await _data.doc(MAC).set({'data': sensorData, 'time': DateTime.now()});
  await _data.doc(MAC).set({
    'alarm': alarm,
    'change': change,
    'modedescription': modedescription,
    'power': power,
    'time': DateTime.now(),
  });
  print("$MAC updated at ${DateTime.now()}");
}

void showMySnackBar(BuildContext context, String mes) {
  final snackBar = new SnackBar(
    content: Text(mes),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
