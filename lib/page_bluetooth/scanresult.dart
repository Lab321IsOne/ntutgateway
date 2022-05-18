import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//設定背景執行相關
// void startServiceInPlatform() async {
//   if (Platform.isAndroid) {
//     var methodChannel = MethodChannel("decide background");
//     String data = await methodChannel.invokeMethod("startService");
//     debugPrint(data);
//   }
// }

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap, }) : super(key: key);

  
  final ScanResult result;
  final VoidCallback onTap;

  




  //未連線tile的ui  
  
  Widget _buildTitle(BuildContext context) {
    //get a specific deviceScanResultTile
    if (result.device.name == 'NTUT_LAB321_Product' ||
        result.device.name == "Nordic_HRM") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "序號:" + result.device.id.toString(),
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow
                  .ellipsis, //style: Theme.of(context).textTheme.caption,
            ),
          ),
        ],
      );
    } else {
      return Text(
        "上傳時間: " + DateTime.now().toString().substring(0, 19),
      );
    }
  }

  //讀取設備相關參數包含ManufacturerData
  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.caption,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach(
      (id, bytes) {
        res.add(
            '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
      },
    );
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach(
      (id, bytes) {
        res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
      },
    );
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference data =
        FirebaseFirestore.instance.collection('NTUTLab321');
    if (result.device.name == 'NTUT_LAB321_Product' ||
        result.device.name == "Nordic_HRM") {
      //只顯現固定裝置
      return Padding(
        padding: EdgeInsets.all(20.5),
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.redAccent,
                          blurRadius: 20.0,
                          offset: Offset(0, 10))
                    ]),
                child: ExpansionTile(
                  title: _buildTitle(context),
                  //backgroundColor: Colors.redAccent,
                  subtitle: Center(
                      child: Text(
                    "上傳時間: " + DateTime.now().toString().substring(11, 19),
                    style: TextStyle(fontSize: 14),
                  )),
                  // leading: Text(
                  //   result.rssi.toString(),
                  // ),
                  trailing: ElevatedButton(
                   

                    
                    child: Text('設定院床號' ,  style: TextStyle(
                                                  color: Colors.redAccent[100],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.lightBlue[50],
                                            ),
                                            
                    onPressed:
                        (result.advertisementData.connectable) ? onTap : null,
                  ),
                  children: <Widget>[
                    _buildAdvRow(context, 'Complete Local Name',
                        result.advertisementData.localName),
                    _buildAdvRow(context, 'Tx Power Level',
                        '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
                    _buildAdvRow(
                        context,
                        'Manufacturer Data',
                        getNiceManufacturerData(
                                result.advertisementData.manufacturerData) ??
                            'N/A'),
                    _buildAdvRow(
                        context,
                        'Service UUIDs',
                        (result.advertisementData.serviceUuids.isNotEmpty)
                            ? result.advertisementData.serviceUuids
                                .join(', ')
                                .toUpperCase()
                            : 'N/A'),
                    _buildAdvRow(
                        context,
                        'Service Data',
                        getNiceServiceData(
                                result.advertisementData.serviceData) ??
                            'N/A'),
                          
                    // ElevatedButton(
                    //     child: Text('update'),
                    //     onPressed: () async {
                    //       await data.doc(result.device.id.toString()).set({
                    //         'data': getNiceManufacturerData(
                    //             result.advertisementData.manufacturerData),
                    //         'time': DateTime.now()
                    //       });
                    //     }),
                  ],
                )),
          ],
        ),
      );
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }
}
