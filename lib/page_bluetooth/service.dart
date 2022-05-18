import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fireuser/page_bluetooth/characteristic.dart';

//每個不同的UUID對應到不同的frame設定
class ServiceTile extends StatefulWidget {
  ServiceTile({@required this.service, this.characteristicTiles, Key key});
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  @override
  _ServiceTile createState() =>
      _ServiceTile(service: service, characteristicTiles: characteristicTiles);
}

class _ServiceTile extends State<ServiceTile> {
  _ServiceTile({@required this.service, this.characteristicTiles, Key key});
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;
  var selectItemValue, selectItemValue1;
  CollectionReference _collection;

  @override
  void initState() {
    super.initState();
    _collection = FirebaseFirestore.instance.collection('NTUTLab321');
  }

  //service內容
  @override
  Widget build(BuildContext context) {
    //startServiceInPlatform(); //開啟背景執行
    //用不到的service將它遮蔽備用
    if ('0x${service.uuid.toString().toUpperCase().substring(4, 8)}' ==
        '0x1523') {
      return Container(
        width: 0,
        height: 0,
      );
    }

    if ('0x${service.uuid.toString().toUpperCase().substring(4, 8)}' ==
        '0x1801') {
      return Container(
        height: 0.0,
      );
    }

    //service 1800 ，可下拉選擇室與床號
    if ('0x${service.uuid.toString().toUpperCase().substring(4, 8)}' ==
        '0x1800') {
      return ListView(
        shrinkWrap: true,
        children: <Widget>[
          Card(
            child: Card(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.airline_seat_individual_suite_rounded,
                    color: Colors.blue,
                  ),
                  Text(
                    ' 請點選編輯擇床-室號 ',
                    style: TextStyle(fontSize: 15.0),
                  ),
                  Builder(
                    //設定室
                    builder: (BuildContext context) {
                      return DropdownButtonHideUnderline(
                        child: new DropdownButton(
                          hint: new Text(
                            '房',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.grey[400],
                            ),
                          ),
                          //設置這個value之後，選中對應位置的item,
                          //再次呼出下拉菜單，會自動定位item位置在當前按鈕顯示的位置處
                          value: selectItemValue,
                          items: <DropdownMenuItem<int>>[
                            new DropdownMenuItem(
                              child: new Text(
                                '一病房',
                                style: TextStyle(fontSize: 10.0),
                              ),
                              value: 01,
                            ),
                            new DropdownMenuItem(
                              child: new Text(
                                '三病房',
                                style: TextStyle(fontSize: 10.0),
                              ),
                              value: 03,
                            ),
                            new DropdownMenuItem(
                              child: new Text(
                                '五病房',
                                style: TextStyle(fontSize: 10.0),
                              ),
                              value: 05,
                            ),
                          ], //選單的副程式在底下
                          onChanged: (value) {
                            setState(
                              () {
                                selectItemValue = value;
                                //依照deviceID上傳對應firebase的documentID
                                if (selectItemValue != null &&
                                    selectItemValue1 != null) {
                                  _collection
                                      .doc('${service.deviceId.toString()}')
                                      .update(
                                    {
                                      'judge': selectItemValue.toString() +
                                          '-' +
                                          selectItemValue1,
                                    },
                                  );
                                }
                                if (selectItemValue != null) {
                                  _collection
                                      .doc('${service.deviceId.toString()}')
                                      .update(
                                    {'area': selectItemValue.toString()},
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Builder(
                    //設定床號
                    builder: (BuildContext context) {
                      return DropdownButtonHideUnderline(
                        child: new DropdownButton(
                          hint: new Text(
                            '床',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.grey[400],
                            ),
                          ),
                          value: selectItemValue1,
                          items: generateItemList1(),
                          onChanged: (T) {
                            setState(
                              () {
                                selectItemValue1 = T;
                                if (selectItemValue != null &&
                                    selectItemValue1 != null) {
                                  //記錄在全域變數並傳送至firebase
                                  _collection
                                      .doc('${service.deviceId.toString()}')
                                      .update(
                                    {
                                      'judge': selectItemValue.toString() +
                                          '-' +
                                          selectItemValue1,
                                    },
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    //service 的ui
    if (characteristicTiles.length > 0) {
      return SizedBox(
        height: 160,
        child: ExpansionTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  '感測器資訊由此請點選展開 (${service.uuid.toString().toUpperCase().substring(4, 8)}+${service.deviceId.toString()})',
                  style: TextStyle(
                    fontSize: 10,
                  )),
              // style:Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).textTheme.caption.color),
            ],
          ),
          children:
              characteristicTiles, // 裡面包characteristic的內容，由characteristic.dart注入
          initiallyExpanded: true,
          //trailing: Icon(Icons.info_outline),
        ),
      );
    } 
    else {
      return ListTile(
          title: Text('Service',
              style: TextStyle(
                fontSize: 10,
              )),
          subtitle:
              Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                  style: TextStyle(
                    fontSize: 10,
                  )));
    }
  }
}

//其他版面設定，未用到
// class AdapterStateTile extends StatelessWidget {
//   const AdapterStateTile({Key key, @required this.state}) : super(key: key);
//   final BluetoothState state;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.red,
//       child: ListTile(
//         title: Text('Bluetooth adapter is ${state.toString().substring(15)}', style: Theme.of(context).primaryTextTheme.subtitle1,),
//         trailing: Icon(Icons.error, color: Theme.of(context).primaryTextTheme.subtitle1.color,),
//       ),
//     );
//   }
// }

//設定下拉式選單相關副程式
List<DropdownMenuItem> generateItemList() {
  List<DropdownMenuItem> items = new List();
  for (int i = 1, j = 1; i < 10; i++, j + 2) {
    DropdownMenuItem i = new DropdownMenuItem(
      child: new Text(
        j.toString() + '室',
        style: TextStyle(
          fontSize: 10.0,
        ),
      ),
      value: '0' + j.toString(),
    );
    items.add(i);
  }
  for (int i = 10, j = 10; i < 60; i++, j++) {
    DropdownMenuItem i = new DropdownMenuItem(
      child: new Text(
        j.toString() + '室',
        style: TextStyle(
          fontSize: 10.0,
        ),
      ),
      value: j.toString(),
    );
    items.add(i);
  }
  return items;
}

List<DropdownMenuItem> generateItemList1() {
  List<DropdownMenuItem> items1 = new List();
  for (int k = 1, m = 1; k < 10; k++, m++) {
    DropdownMenuItem k = new DropdownMenuItem(
      child: new Text(
        m.toString() + '床',
        style: TextStyle(
          fontSize: 10.0,
        ),
      ),
      value: '0' + m.toString(),
    );
    items1.add(k);
  }
  for (int k = 10, m = 10; k < 60; k++, m++) {
    DropdownMenuItem k = new DropdownMenuItem(
      child: new Text(
        m.toString() + '床',
        style: TextStyle(
          fontSize: 10.0,
        ),
      ),
      value: m.toString(),
    );
    items1.add(k);
  }
  return items1;
}
