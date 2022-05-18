import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cron/cron.dart';
import 'dart:async';

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  //final VoidCallback onReadPressed;
  //final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;
  const CharacteristicTile(
      {Key key,
      this.characteristic,
      //this.onReadPressed,
      //this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);

  //characteristic內容
  @override
  Widget build(BuildContext context) {
    //..1為上一筆資料，..為當下這筆
    var state, state1 = 'null';
    var mode, mode1 = 'null';
    var power = 100;
    final cron = Cron();

// // 自動觸發characteristic 1504 1505 1514
//     if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
//         '0x1504') {
//       Future.delayed(new Duration(seconds: 1), () {
//         _onNotificationset();
//       });
//     }
//     if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
//         '0x1505') {
//       Future.delayed(new Duration(seconds: 2), () {
//         _onNotificationset();
//       });
//     }
//     if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
//         '0x1514') {
//       Future.delayed(new Duration(seconds: 3), () {
//         _onNotificationset();
//       });
//     }

    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        //characteristic 1504，負責處理狀態，隸屬service 1503
        if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
            '0x1504') {
          if (value.toString() == '[1]') {
            //狀態異常時
            state = '1';
            //當下與上一筆值不同時上傳資料庫
            if (state != state1) {
              FirebaseFirestore.instance
                  .collection('NTUTLab321')
                  .doc('${characteristic.deviceId.toString()}')
                  .update({'change': '1', 'alarm': '1'});
            }
            //顯示
            return ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 50,
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Chip(
                          label: Text(
                            '液體狀態',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          child: Text(
                            '  請更換',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (value.toString() == '[0]') {
            //狀態正常時
            state = '0';
            //當下與上一筆值不同時上傳資料庫
            if (state != state1) {
              FirebaseFirestore.instance
                  .collection('NTUTLab321')
                  .doc('${characteristic.deviceId.toString()}')
                  .update({
                'change': '0', 'alarm': '0'
                //'time':FieldValue.arrayUnion([DateTime.now()]),
              });
            }
            return ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 50,
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Chip(
                          label: Text(
                            '液體狀態',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          child: Text(
                            '  正常',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (value.toString() == '[2]' || value.toString() == '[3]') {
            //狀態不明時(感測器需求)
            return Container(
                height: 50,
                child: Card(
                    child: Text(
                  '準備資料中 請稍後...',
                  style: TextStyle(fontSize: 15),
                )));
          } else if (value.toString() == '[4]' || value.toString() == '[5]') {
            //感測器故障時
            FirebaseFirestore.instance
                .collection('NTUTLab321')
                .doc('${characteristic.deviceId.toString()}')
                .update({
              'change': 'E',
            });
            return Container(
                height: 50,
                child: Card(
                    child: Text(
                  '感測器故障',
                  style: TextStyle(fontSize: 15),
                )));
          }
          state1 = state; //儲存上一筆狀態值
        }

        //characteristic 1505，負責處理模式，隸屬service 1503
        if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
            '0x1505') {
          if (value.toString() == '[1]') {
            //點滴模式時
            mode = '1';
            if (mode != mode1) {
              FirebaseFirestore.instance
                  .collection('NTUTLab321')
                  .doc('${characteristic.deviceId.toString()}')
                  .update({
                'modedescription': '點滴',
              });
            }
            return ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 50,
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Chip(
                          label: Text(
                            '設備模式',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Icon(
                          Icons.water_damage_outlined,
                          color: Colors.lightBlueAccent,
                        ),
                        Container(
                          child: Text(
                            '  點滴模式',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (value.toString() == '[0]') {
            //尿袋模式時
            mode = '0';
            if (mode != mode1) {
              FirebaseFirestore.instance
                  .collection('NTUTLab321')
                  .doc('${characteristic.deviceId.toString()}')
                  .update({
                'modedescription': '尿袋',
              });
            }
            return ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 50,
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Chip(
                          label: Text(
                            '設備模式',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Icon(
                          Icons.whatshot_outlined,
                          color: Colors.yellow,
                        ),
                        Container(
                          child: Text(
                            '  尿袋模式',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          mode1 = mode; //儲存上一筆模式值
        }

        //characteristic 1514，負責處理電量，隸屬service 1513
        if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}' ==
            '0x1514') {
          //characteristic 1514，負責處理電量，隸屬service 1513
          power = value[0];
          //電量icon
          Icon getPowerIcon(value) {
            if (value.isNotEmpty && value[0] > 74) {
              return Icon(
                Icons.battery_full,
                color: Colors.green,
              );
            } else if (value.isNotEmpty && value[0] < 75 && value[0] > 24) {
              return Icon(
                Icons.battery_full_sharp,
                color: Colors.yellowAccent,
              );
            } else {
              return Icon(
                Icons.battery_alert,
                color: Colors.redAccent,
              );
            }
          }

          return Card(
            child: Row(
              children: <Widget>[
                Chip(
                  label: Text(
                    '剩餘電力',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                Container(
                  height: 20,
                  child: Row(
                    children: <Widget>[
                      getPowerIcon(value),
                      Text(value[0].toString() + "%",
                          style: TextStyle(fontSize: 15.0)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        //上傳電量一分鐘一次
        // cron.schedule(Schedule.parse('* */1 * * * *'), () async {
        //   FirebaseFirestore.instance
        //       .collection('NTUTLab321-1')
        //       .doc('${characteristic.deviceId.toString()}')
        //       .update({
        //     'power': power.toString(),
        //   });
        // });

        //characteristic 的ui
        return Container(
          height: 50,
          child: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).textTheme.caption.color),
                Row(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '若資料無顯示，請點選按鈕手動更新  (${characteristic.uuid.toString().toUpperCase().substring(4, 8)})',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    //手動觸發
                    IconButton(
                      icon: Icon(
                          characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              .withOpacity(0.5),
                          size: 15),
                      onPressed: () => onNotificationPressed(),
                    ),
                  ],
                ),
              ],
            ),
            // subtitle: Text(value.toString(),style:TextStyle(fontSize: 10,)),
            contentPadding: EdgeInsets.all(0.0),
          ),
        );
      },
    );
  }

  void _onNotificationset() async {
    await characteristic.setNotifyValue(!characteristic.isNotifying);
    await characteristic.read();
  }
}
