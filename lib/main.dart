import 'package:flutter/material.dart';
import 'package:gitlab_app/issues_details.dart';
import 'package:gitlab_app/login.dart';
import 'package:gitlab_app/side_drawer.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'issues_list.dart';

void main() => runApp(MyApp());

String API = 'http://test.com/api/v4/';
String myToken = '';
String username = '';

String name='';
String avatar_url='';
List<Map<String, String>> ProjectList = new List();
bool Loginpage = false;
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool changeProject = false;
  void getProjectList() async {
    final response = await http.get(API + 'projects?membership=true&per_page=100', headers: {
      'Authorization':myToken
    });
    Utf8Decoder utf8decoder = new Utf8Decoder();
    final data = json.decode(utf8decoder.convert(response.bodyBytes));

    print(data);
    if (data != null) {
      List<Map<String, String>> ProList = new List();
      for (var value in data) {
        Map<String, String> project = new Map();
        project['id'] = value['id'].toString();
        project['name'] = value['name'].toString();
        project['web_url']=value['web_url'].toString();
        project['open_issues_count']=value['open_issues_count'].toString();
        project['last_activity_at']=value['last_activity_at'].toString();
        ProList.add(project);
      }
      setState(() {
        ProjectList=ProList;
      });
    }
  }



  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Token = prefs.get('myToken');
    String User = prefs.get('username');
    if (Token == null) {
      new Future.delayed(
          const Duration(seconds: 1),
          () => {
                Navigator.push(
                  context,
                  MaterialPageRoute<bool>(builder: (context) => Login()),
                ).then((value) {
                  setState(() {
                    Loginpage = false;
                  });
                })
              });
    } else {
      setState(() {
        myToken = Token;
        username=User;
      });
    }
  }

  void getUser() async {
    final response = await http.get(API + 'users?username=$username', headers: {
      'Authorization':myToken
    });
    Utf8Decoder utf8decoder = new Utf8Decoder();
    final data = json.decode(utf8decoder.convert(response.bodyBytes));

    print(data);
    if (data != null) {
      setState(() {
        name = data[0]['name'];
        avatar_url = data[0]['avatar_url'];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (myToken == '' && Loginpage == false) {
      getToken();
      Loginpage = true;
    }
    if (myToken != '') {
      if (ProjectList.length == 0) {
        getUser();
        getProjectList();
      }
    }
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: buildlist(),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        drawer: SideDrawer());
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

  }

  List<Widget> buildlist() {
    List<Widget> WidgetList = List();
    ProjectList.forEach((project) {
      WidgetList.add(ListTile(
          leading: Icon(Icons.brightness_high),
          title: Text(project['name']),
          subtitle: Text('Open Issues :'+project['open_issues_count']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<bool>(builder: (context) => IssuesListPage(project['name'],int.parse(project['id']),project['web_url'])),
            );
          }));
    });
    return WidgetList;
  }



}
