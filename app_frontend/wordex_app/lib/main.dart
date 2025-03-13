import 'package:flutter/material.dart';
import 'package:wordex_app/ds.dart';
import 'package:wordex_app/lj.dart';
import 'package:wordex_app/login.dart';
import 'package:wordex_app/logoloading.dart';
import 'package:wordex_app/quiz.dart';
import 'package:wordex_app/quizhistory.dart';
import 'package:wordex_app/rac.dart';
import 'package:wordex_app/signup.dart';
import 'package:wordex_app/home.dart';
import 'package:wordex_app/summary.dart';
import 'package:wordex_app/test.dart';
import 'package:wordex_app/wj.dart';



void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'test',
    routes: {
      'login': (context) => MyLogin(),
      'test': (context) => LetterRecognitionPage(),

      'signup': (context) => MySignup(),
      'loading': (context) => LoadingScreen(userDetails: ModalRoute.of(context)!.settings.arguments as Map<String, String>),

    'home': (context) => MyHome(userDetails: ModalRoute.of(context)!.settings.arguments as Map<String, String>),

    'quiz': (context) => Quiz(userDetails: ModalRoute.of(context)!.settings.arguments as Map<String, String>),

        'quizhistory': (context) => QuizHistory(userDetails: ModalRoute.of(context)!.settings.arguments as Map<String, String>),

'rac': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
  return Rac(
    userDetails: args,
    summaryDetails: args,
  );
},

'lj': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
  return Lj(
    userDetails: args,
    summaryDetails: args,
    racSummaryDetails: args,
  );
},    


'wj': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
  return Wj(
    userDetails: args,
    summaryDetails: args,
    racSummaryDetails: args,
    ljSummaryDetails: args,


  );
},

'ds': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
  return Ds(
    userDetails: args,
    summaryDetails: args,
    racSummaryDetails: args,
    ljSummaryDetails: args,
    wjSummaryDetails: args,
  );
},


'summary': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
  return Summary(
    userDetails: args,
    summaryDetails: args,
    racSummaryDetails: args,
    ljSummaryDetails: args,
    wjSummaryDetails: args,
    dsSummaryDetails: args,

  );
},


    },
  ));
}
