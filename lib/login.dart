import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gitlab_app/main.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialog.dart';
class Login extends StatefulWidget {
  @override
  createState() => new LoginState();
}
class LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _obscureTextLogin = true;
  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();
  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  @override
  void initState(){
    super.initState();
    loginout();
  }
  @override
  Widget build(BuildContext context) {
    var color=Color(0xFF54b6fb);
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false
        ),
        body: SingleChildScrollView(
          physics: new NeverScrollableScrollPhysics(),
          child:Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Padding(
                padding: EdgeInsets.only(
                    top: 100, bottom: 20.0, left: 50.0, right: 50.0),
                child: Text(
                  "登  录",
                  style: TextStyle(
                      color: color,
                      fontSize: 25.0,
                      fontFamily: "WorkSansBold",
                      fontWeight:FontWeight.w900
                  ),

                ),
              ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 20.0, bottom:5.0, left: 50.0, right: 50.0),
                  child: TextField(
                    controller: loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "WorkSansSemiBold",
                        fontSize: 15.0,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelText: '账号',
                      labelStyle:TextStyle(
                          color: color,
                          fontWeight:FontWeight.w900),
                      enabledBorder: OutlineInputBorder(
                        /*边角*/
                        borderRadius: BorderRadius.all(
                          Radius.circular(30), //边角为30
                        ),
                        borderSide: BorderSide(
                          color: color, //边线颜色为黄色
                          width: 2, //边线宽度为2
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30), //边角为30
                          ),
                          borderSide: BorderSide(
                            color: color, //边框颜色为绿色
                            width: 2, //宽度为5
                          )),

                      prefixIcon: Icon(
                        Icons.local_phone,
                        color: color,
                        size: 22.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 50.0, right: 50.0),
                  child: TextField(
                    controller: loginPasswordController,
                    obscureText: _obscureTextLogin,
                    style: TextStyle(
                        fontFamily: "WorkSansSemiBold",
                        fontSize: 15.0,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelText: '密码',
                      labelStyle:TextStyle(
                          color: color,
                          fontWeight:FontWeight.w900),
                      enabledBorder: OutlineInputBorder(
                        /*边角*/
                        borderRadius: BorderRadius.all(
                          Radius.circular(30), //边角为30
                        ),
                        borderSide: BorderSide(
                          color: color, //边线颜色为obscureText黄色
                          width: 2, //边线宽度为2
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30), //边角为30
                          ),
                          borderSide: BorderSide(
                            color: color, //边框颜色为绿色
                            width: 2, //宽度为5
                          )),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: 22.0,
                        color: color,
                      ),
                       suffixIcon: new IconButton(icon: new Icon(
                          Icons.remove_red_eye, color: Colors.black,),
                            onPressed: showPassWord)
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 50.0, right: 50.0),
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.deepOrange,
                      minWidth: MediaQuery.of(context).size.width,
                      color: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50.0))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal:42),
                        child: Text(
                          "登  录",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontFamily: "WorkSansBold"),
                        ),
                      ),
                      onPressed: () =>{
                      MessageHUD.showHUD(context,'请稍后...'),
                      _login()
                      }
//                      showInSnackBar("Login button pressed")
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
  void _login() {
    print({'phone': loginEmailController.text, 'password': loginPasswordController.text});
    loginPost(loginEmailController.text, loginPasswordController.text);
  }
  void loginout() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('myToken', null);
    String User = prefs.get('username');
    loginEmailController.text=User;
  }
  void showPassWord() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }
  void loginPost(String Email,String password) async{
    var body = json.encode({'grant_type':'password','username':Email,'password':password});
    final response = await http.post('http://test.com/oauth/token',headers: {HttpHeaders.contentTypeHeader:'application/json'},body: body);
    final data = json.decode(response.body);
    Navigator.pop(context,"");
    if(data['access_token']!=null){
      myToken="Bearer "+data['access_token'];
      username=Email;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('myToken', myToken);
      prefs.setString('username', username);

      Navigator.maybePop(context);
    }
    else{
      showDialog(
          context: context,
          builder: (context) {
            String alertText = '登录失败!';
            return AlertDialog(
              content: Text(alertText),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context,"");
                    },
                    child: Text("确定",
                        style:
                        TextStyle(color: Theme.of(context).accentColor)))
              ],
            );

          });
    }
  }
}