import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gitlab_app/main.dart';
import 'package:http/http.dart' as http;

import 'date_format.dart';

class IssuesDetails extends StatefulWidget {
  Map<String, dynamic> Issues = new Map();
  IssuesDetails(this.Issues);
  @override
  createState() => new IssuesDetailsSate(Issues);
}

class IssuesDetailsSate extends State<IssuesDetails> {
  Map<String, dynamic> Issues = new Map();
  bool isInit=false;

  List<Map<String, dynamic>> DiscussionsList = new List();
  List<Map<String, dynamic>> ParticipantsList = new List();

  IssuesDetailsSate(this.Issues);
  void getIssuesList() async {
    final response = await http.get(
        API +
            'projects/' +
            Issues['projectsId'].toString() +
            '/issues/' +
            Issues['iid'].toString() +
            '/discussions',
        headers: {'Authorization': myToken});
    Utf8Decoder utf8decoder = new Utf8Decoder();
    final data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    if (data != null) {
      List<Map<String, dynamic>> ProList = new List();
      for (var value in data) {
        Map<String, dynamic> project = new Map();
        project['id'] = value['id'].toString();
        project['body'] = value['notes'][0]['body'];
        project['author'] = value['notes'][0]['author']['name'];
        project['created_at'] = value['notes'][0]['created_at'];
        project['system'] = value['notes'][0]['system'];
        ProList.add(project);
      }
      setState(() {
        DiscussionsList = ProList;
      });
    }
  }
  void getParticipantsList() async {
    final response = await http.get(
        API +
            'projects/' +
            Issues['projectsId'].toString() +
            '/issues/' +
            Issues['iid'].toString() +
            '/participants',
        headers: {'Authorization': myToken});
    Utf8Decoder utf8decoder = new Utf8Decoder();
    final data = json.decode(utf8decoder.convert(response.bodyBytes));
    print(data);
    if (data != null) {
      List<Map<String, dynamic>> ProList = new List();
      for (var value in data) {
        Map<String, dynamic> project = new Map();
        project['name'] = value['name'];
        ProList.add(project);
      }
      setState(() {
        ParticipantsList = ProList;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (DiscussionsList.length == 0) {
      if(isInit==false){
        isInit=true;
        getIssuesList();
        getParticipantsList();
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("问题详情"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: buildlist(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildlist() {
    List<Widget> WidgetList = List();
    WidgetList.add(buildDetails());
    DiscussionsList.forEach((project) {
      if (project['system']) {
        WidgetList.add(ListTile(
          leading: Icon(Icons.label),
          title: Text(project['body']),
          subtitle: Text(project['author'] + "   " + DateFormat.format(project['created_at'])),
        ));
      } else {
        WidgetList.add(Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 5.0),
                      child: Text(project['author'],
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 5.0),
                      child: Text(" 评论于 " + DateFormat.format(project['created_at']),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),

              bulidText(project['body']),
            ],
          ),
        ));
      }
    });
    return WidgetList;
  }

  Widget buildDetails() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 5.0),
                      child: Text(Issues['state'],
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: Text(Issues['author'],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: Text(" 创建于 " + DateFormat.format(Issues['created_at']),
                      style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
            child: Text(Issues['title'],
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          bulidText(Issues['description']),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: Text("Assignee:",
                      style: TextStyle(fontSize: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: Text(Issues['assignee'],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: Text("Due date:",
                      style: TextStyle(fontSize: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: Text(Issues['due_date'],
                      style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: bulidParticipantsList()
            ),
          ),
          ListTile(
            title: Text("修改于", style: TextStyle(fontSize: 14)),
            subtitle: Text(DateFormat.format(Issues['updated_at'])),
          )
        ],
      ),
    );
  }

  Widget bulidText(String desText) {
    RegExp mobile = new RegExp(r"(!\[.*?\]\(.*?\))");
    List<Widget> widgets = new List();
    Iterable<Match> mobiles = mobile.allMatches(desText);
    for (Match m in mobiles) {
      String match = m.group(0);
      print(match);
      var urlnumber = desText.indexOf(match);
      String text = desText.substring(0, urlnumber);

      widgets.add(ListTile(
        title: Text(text, style: TextStyle(fontSize: 18)),
      ));
      widgets.add(ListTile(
        title: Container(
          margin: const EdgeInsets.all(20.0),
          child: FadeInImage.assetNetwork(placeholder: Issues['web_url']+ match.split('(')[1].split(')')[0], image: Issues['web_url']+ match.split('(')[1].split(')')[0]),
        ),
      ));
      desText=desText.substring(text.length+match.length);
    }
    if(widgets.length==0){
      widgets.add(ListTile(
        title: Text(desText, style: TextStyle(fontSize: 18)),
      ));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets);
  }
  List<Widget> bulidParticipantsList() {
    List<Widget> WidgetList = List();
    WidgetList.add(Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 5.0, horizontal: 5.0),
      child: Text(ParticipantsList.length.toString()+" participant:",
          style: TextStyle(fontSize: 14)),
    ));
    ParticipantsList.forEach((project) {
        WidgetList.add(Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 5.0, horizontal: 5.0),
          child: Text(project['name'],
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ));

    });
    return WidgetList;
  }
}
