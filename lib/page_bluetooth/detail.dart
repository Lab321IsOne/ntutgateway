import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  const DetailScreen({@required this.device, Key key}) : super(key: key);
  final BluetoothDevice device;
  @override
  _DetailScreenState createState() => _DetailScreenState(device: device);
}

class _DetailScreenState extends State<DetailScreen> {
  final myController = TextEditingController();
  _DetailScreenState({@required this.device, Key key});
  String text1504 = '';
  final BluetoothDevice device;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ExpansionTile(
          title: TextField(
            decoration: InputDecoration(
                labelText: "WiFi SSID", labelStyle: TextStyle(fontSize: 12)),
          ),
          trailing: ElevatedButton(
              child: Text(
                '送出',
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                print(device.name);
              }),
        ),
        ExpansionTile(
          title: TextField(
            decoration: InputDecoration(
                labelText: "WiFi PASSWORD",
                labelStyle: TextStyle(fontSize: 12)),
          ),
          trailing: ElevatedButton(
              child: Text(
                '送出',
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                print(device.id);
              }),
        ),
        ExpansionTile(
          title: TextField(
            controller: myController,
            decoration: InputDecoration(
                labelText: "院別", labelStyle: TextStyle(fontSize: 12)),
          ),
          trailing: ElevatedButton(
              child: Text(
                '送出',
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                print('fffff=${myController.text}');
                writeData(myController.text);
              }),
        ),
        Text('1504: $text1504'),
      ],
    );
  }

  Future<String> writeData(String data) async {
    List<int> value = [];
    List characteristics;
    String decoded;
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      print('bbbbbbbbbbb=${service.characteristics}');
      characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print('cccccc=${c.uuid.toString().substring(4, 8)}');

        if (c.uuid.toString().substring(4, 8) == '1504') {
          await c.write(utf8.encode('$data'));
          value = await c.read();
          decoded = utf8.decode(value);
          print('cccccc$decoded');
          setState(() {
            text1504 = decoded;
          });
        }

        // List<int> value = [];
        // if (c.uuid.toString().substring(4, 8) == '2a00') {
        //   value = await c.read();
        //   decoded = utf8.decode(value);
        //   print('eeeee${value}');
        //   print('eeeee${decoded}');
        // }

        // List<int> value = await c.read();
        // decoded = utf8.decode(value);
        // print('aaaaaaaa=$decoded');
        // print('aaaaaaaa=${value}');
      }
    });
    print('dddd=${characteristics.length}');

    print('mmmmmmmmm=$value');
    return decoded;
  }
}
