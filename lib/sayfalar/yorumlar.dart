import 'package:flutter/material.dart';
import 'package:socialapp/modeller/gonderi.dart';

class Yorumlar extends StatefulWidget {

final Gonderi gonderi;
Yorumlar({this.gonderi});

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {

  yorumlariGoster(){
    return Expanded(
          child: Container(
        color: Colors.red,
        height: 50.0,
      ),
    );
  }

  yorumEkle(){
    return ListTile(
      title: TextFormField(
        decoration: InputDecoration(
          hintText: "Yorumu buraya yazın.",
          hintStyle: TextStyle(color: Colors.black)
        ),
      ),
      trailing: IconButton(icon: Icon(Icons.send), onPressed: null),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yorumlar"),
        backgroundColor: Colors.grey[100],
      ),
      body: Column(
        children: <Widget>[
          yorumlariGoster(),
          yorumEkle()
        ],
      )
    );
  }
}