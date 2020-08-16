import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/yonlendirme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<YetkilendirmeServisi>(
          create: (_) => YetkilendirmeServisi(),
          child: MaterialApp(
        title: 'Flutter Demo1',
        home: Yonlendirme(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


