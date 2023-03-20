import 'package:flutter/material.dart';

class DateFormat  {
  static String format(String date){
    DateTime now = DateTime.now();
    DateTime time = DateTime.parse(date);
    var zone = int.parse(DateTime.now().timeZoneOffset.toString().split(":")[0]);
    var newdate=DateTime(time.year,time.month,time.day,time.hour+zone,time.minute,time.second);

    Duration duration = now.difference(newdate);
    if(duration.inDays!=0){
      return duration.inDays.toString()+"天前";
    }
    if(duration.inHours!=0){
      return duration.inHours.toString()+"小时前";
    }
    if(duration.inMinutes!=0){
      return duration.inMinutes.toString()+"分钟前";
    }
    if(duration.inSeconds!=0){
      return duration.inSeconds.toString()+"秒前";
    }
  }
}