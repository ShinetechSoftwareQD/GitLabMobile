import 'package:flutter/material.dart';

import 'issues_details.dart';
import 'package:gitlab_app/main.dart';

import 'login.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
        child: new ListView(
          children: buildlist(context),
        ));
  }
  List<Widget> buildlist(BuildContext context) {
    List<Widget> WidgetList = List();
    WidgetList.add(UserAccountsDrawerHeader(
        accountName: Text(name),
        accountEmail: Text(''),
        otherAccountsPictures: <Widget>[
          IconButton(
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.red,
                size: 36.0,
              ),
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute<bool>(
                      builder: (context) => Login()),
                ).then((value) {

                  myToken = '';
                  Loginpage = false;
                  ProjectList.clear();

                });
              })
        ],
        currentAccountPicture: CircleAvatar(
          radius: 36.0,
          backgroundImage: Image.network(
            avatar_url,
          ).image,
        )
    ));
      WidgetList.add(ListTile(
          leading: Icon(Icons.inbox),
          title: Text('Your projects'),
          onTap: () {
            Navigator.maybePop(context);
          }
          ));
    return WidgetList;
  }
}