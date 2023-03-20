import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gitlab_app/main.dart';
import 'package:http/http.dart' as http;

import 'date_format.dart';
import 'dialog.dart';
import 'issues_details.dart';
import 'issues_row.dart';

class IssuesListPage extends StatefulWidget {
  Map<String, dynamic> Issues = new Map();
  String title;
  int _counter = 0;
  String project_web_url='';
  IssuesListPage(this.title,this._counter,this.project_web_url);
  @override
  createState() => new IssuesListSate();
}

class IssuesListSate extends State<IssuesListPage> {


  bool isInit=false;
  BuildContext mycontext;
  List<Map<String, dynamic>> IssuesList = new List();
  Map<String,String> labelsColorList=new Map();
  int tabIndex=0;
  List<String> tabs = <String>[
    'Open',
    'Closed',
  ];

  Map<String,int> boardList = Map<String,int>();
  void getIssuesLabel() async {
    var ProList;
    int id = widget._counter;
    Utf8Decoder utf8decoder = new Utf8Decoder();
    int closed_issues=0;
    int open_issues=0;

    Map<String,int> boards = Map<String,int>();
    final boardsApi =
    await http.get(API + 'projects/$id/boards/', headers: {
      'Authorization':myToken
    });
    final boardData = json.decode(utf8decoder.convert(boardsApi.bodyBytes));
    if (boardData != null&&(boardData as List).length!=0) {
      for (var value in boardData[0]["lists"]) {
        String name=value["label"]["name"];
        int position=value["position"];
        boards[name]=position;
      }
    }

    List<String> tablist = List(boards.length+2);
    Map<String,String> labelsColor= Map<String,String>();
    final labels =
    await http.get(API + 'projects/$id/labels/', headers: {
      'Authorization':myToken
    });
    final lab = json.decode(utf8decoder.convert(labels.bodyBytes));
    print('lab:$lab');
    if (lab != null) {
      for (var value in lab) {
        String name=value["name"];

        int open_issues_count=value["open_issues_count"];
//        labelLsit[name]=open_issues_count;
        closed_issues=closed_issues+value["closed_issues_count"];
        open_issues=open_issues+open_issues_count;
        int position=boards[name];
        labelsColor[name]=value["color"];
        if(position!=null){
          tablist[position+1]=name+" ($open_issues_count)";
//          open_issues=open_issues-open_issues_count;
        }
      }
    }
    ProList= await getIssuesList(this.tabIndex);
    if (this.tabIndex == 0){
      tablist[0]=("Open (${ProList.length})");
    }

    tablist[boards.length+1]=("Closed ($closed_issues)");

    List<String> tabNotNullList=List();

    tablist.forEach((f){
      if(f!=null)
        tabNotNullList.add(f);
    });

    setState(() {
      IssuesList = ProList;
      labelsColorList=labelsColor;
      if(tablist!=0){
        tabs=tabNotNullList;
        boardList=boards;
      }
    });

    var closeList= await getIssuesList(tabs.length-1);
    tabs[boards.length+1]=("Closed (${closeList.length})");



  }
  getIssuesList(int n) async {
    List<Map<String, dynamic>> ProList = new List();
    Utf8Decoder utf8decoder = new Utf8Decoder();
    int id = widget._counter;
    String att="";
    if(n==0){
      att="state=opened&";
    }else if(tabs.length-1 == n){
      att="state=closed&";
    }
    else{
      String tab=tabs[n].split("(")[0];
//      tab=tab.substring(0,tab.length-1);
      att="labels=$tab&state=opened&";
    }

    final response =
    await http.get(API + 'projects/$id/issues/?'+att+'per_page=100', headers: {
      'Authorization':myToken
    });

    final data = json.decode(utf8decoder.convert(response.bodyBytes));
    if(IssuesList.length==0 && isInit == false){
      isInit = true;
      Navigator.maybePop(context);
    }
    //print(data);
    if (data != null) {
      for (var value in data) {
        Map<String, dynamic> project = new Map();
        project['iid'] = value['iid'].toString();
        project['title'] = value['title'].toString();
        project['description'] = value['description'].toString();
        project['state'] = value['state'].toString();
        project['created_at'] = value['created_at'].toString();


        project['updated_at'] = value['updated_at'].toString();
        project['labels'] = value['labels'];
        project['author'] = value['author']['name'];
        if(value['assignee']==null){
          project['assignee']="No assignee";
        }else{
          project['assignee'] = value['assignee']['name'];
        }
        if(value['due_date']==null){
          project['due_date'] = "No due date";
        }else{
          project['due_date'] = value['due_date'];
        }
        project['projectsId'] = widget._counter;
        ProList.add(project);

      }
    }
    return ProList;
  }
  @override
  Widget build(BuildContext context) {
    mycontext=context;
    if(IssuesList.length==0){
      if(isInit==false) {
//        isInit = true;
        Future.delayed(const Duration(seconds: 0), () =>
        {
        MessageHUD.showHUD(context, '请稍后...')
        });
        getIssuesLabel();
      }
    }
    DefaultTabController defaultTabController=new DefaultTabController(
      //length表示一个有几个标签栏
        length: tabs.length,
        //返回一个包含了appBar和body内容区域的脚手架
        child: Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
                title: Text(widget.title),
                bottom: new TabBar(
                  tabs: tabs.map<Widget>((String tab) => Tab(text: tab)).toList(),
                  //这表示当标签栏内容超过屏幕宽度时是否滚动，因为我们有8个标签栏所以这里设置是
                  isScrollable: true,
                  //标签颜色
                  labelColor: Colors.orange,
                  //未被选中的标签的颜色
                  unselectedLabelColor: Colors.white,
                  labelStyle: new TextStyle(fontSize: 18.0),
                  onTap: (index) async {

                    var ProList;
                    ProList = await getIssuesList(index);
                    Future.delayed(Duration(milliseconds: 300), (){
                      setState(() {
                        tabIndex=index;
                        IssuesList = ProList;
                      });
                    });

                  },
                )),
            body: new TabBarView(
                children: tabs.map((String tab) {
//                  tab=tab.split("(")[0];
                  List<Map<String, dynamic>> tablist = new List();
                  if(tabs[tabIndex]==tab){
                    IssuesList.forEach((item){
                      tablist.add(item);
                    });
                  }
                  return Center(
                    // Center is a layout widget. It takes a single child and positions it
                    // in the middle of the parent.
                    child:  Container(
                      child:  RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                            itemCount: tablist.length,
                            itemBuilder: (BuildContext context, int index) {
                              Map<String, dynamic> item=tablist[index];
                              item['web_url']=widget.project_web_url;
                              item['labelcolor']=labelsColorList;
                              return IssuesListRow(item);
                            }),
                      ),
                    ),
                  );
                }).toList()), // This trailing comma makes auto-formatting nicer for build methods.
));
//    defaultTabController.=tabs.length;
    return defaultTabController;
  }
  Future<Null> _onRefresh() async {
    if(widget._counter!=0){
      getIssuesLabel();
    }
  }

}