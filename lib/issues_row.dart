import 'dart:convert';
import 'package:flutter/material.dart';

import 'date_format.dart';
import 'issues_details.dart';

class IssuesListRow extends StatelessWidget {
  Map<String, dynamic> item;

  Map<String, String> labelColor;
  IssuesListRow(this.item);
  @override
  Widget build(BuildContext context) {
    return buildrow(item,context);
  }
  Widget buildrow(Map<String, dynamic> item,BuildContext context) {
    labelColor=item['labelcolor'];
    return GestureDetector(
        onTap: () {
          //TODO to click something
          Navigator.push(
            context,
            MaterialPageRoute<bool>(builder: (context) => IssuesDetails(item)),
          );
        },
        onLongPress:(){
          showDialog(
              context: context,
              builder: (context) {
                String alertText = '长按!';
                return AlertDialog(
                  content: Text(alertText),
                );
              });
        },
        child: Card(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('#'+item['iid']+' '+item['title'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                               getLabels(item['labels']),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                            '由 ' + item['author'] + ' 创建'+'\n'+'执行人: '+item['assignee'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text('最后更新时间：' + DateFormat.format(item['updated_at']),
                                          style: TextStyle(fontSize: 12)),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        width: 8.0,
                                        height: 8.0,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                        color: Colors.grey,
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
  List<Widget> getLabels(List<dynamic> labelList) {

    List<Widget> WidgetList = List();

    if (!labelList.isEmpty) {
      labelList.forEach((label){

        String color=labelColor[label];
        if(color==null){
          color='#0000000';
        }
        print(color);
        int cnumber=int.parse(color.substring(1, 7), radix: 16) + 0xFF000000;

        Color textColor=Colors.white;
        if(cnumber==0xFFFFFFFF){
          textColor=Colors.black;
        }
        Color c=new Color(cnumber);
        WidgetList.add(Container(
            decoration: new BoxDecoration(
              color: c,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 5.0, horizontal: 5.0),
              child: Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            )),);

      });
    }
    
    return WidgetList;
  }
}