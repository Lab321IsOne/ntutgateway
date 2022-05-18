import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'service.dart';
import 'package:fireuser/page_bluetooth/service.dart';
import 'package:fireuser/page_bluetooth/characteristic.dart';

class DeviceScreen extends StatefulWidget {
  DeviceScreen({@required this.device, Key key}); //使用該字段的類型並初始化
  final BluetoothDevice device;
  @override
  _DeviceScreen createState() => _DeviceScreen(device: device);
}

class _DeviceScreen extends State<DeviceScreen> {
  _DeviceScreen({@required this.device, Key key}); //使用該字段的類型並初始化
  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 10), () {
      //自動discover service
      _discoverServices();
    });

    return Column(
      children: <Widget>[
        StreamBuilder<BluetoothDeviceState>(
          //顯示感測器連線狀態對話框
          stream: device.state,
          initialData: BluetoothDeviceState.disconnected,
          builder: (c, snapshot) {
            if (snapshot.data == BluetoothDeviceState.connected) {
              // Future.delayed(Duration(seconds: 10), () {  //自動discover service
              //   //_discoverServices();
              //   device.discoverServices();
              // });
              return Container(
                  height: 20,
                  width: 200,
                  color: Colors.tealAccent,
                  child: Center(
                    child: Text(
                      '感測器已連線',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ));
            } else {
              return Container(
                  height: 20,
                  width: 200,
                  color: Colors.grey,
                  child: Center(
                    child: Text(
                      '感測器已斷開',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ));
            }
          },
        ),
        StreamBuilder<List<BluetoothService>>(
          // service內容
          stream: device.services,
          initialData: [],
          builder: (c, snapshot) {
            return Column(
              //內容副程式
              children: _buildServiceTiles(snapshot.data),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) =>
              //service內容 ServiceTile()
              ServiceTile(
            service: s,
            characteristicTiles: s.characteristics.map((c) {
              //Characteristic內容 CharacteristicTile()
              return CharacteristicTile(
                characteristic: c,
                //觸發characteristic
                onNotificationPressed: () async {
                  // await c.setNotifyValue(!c.isNotifying);
                  await c.read();
                },
              );
            }).toList(),
          ),
        )
        .toList();
  }

  void _discoverServices() async {
    await device.discoverServices();
  }
}
