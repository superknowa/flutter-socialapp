import 'package:flutter/material.dart';

class ProfiliDuzenle extends StatefulWidget {
  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {

final _formKey = GlobalKey<FormState>();
String _kullaniciAdi = "";
String _hakkinda = "";

  profilFoto(){
    return Column(
      children: <Widget>[
        SizedBox(height: 15.0,),
        CircleAvatar(backgroundColor: Colors.grey,radius: 55.0,),
        SizedBox(height: 20.0,),
        Text("Fotoğraf Ekle",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w400),)
      ],
    );
  }

  kullaniciBilgileri(){

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0,),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Kullanıcı Adı"
              ),
              onSaved: (girilenDeger){
                _kullaniciAdi = girilenDeger;
              },
              validator: (girilenDeger){
                return girilenDeger.trim().length <= 3 ? "Kullanıcı adı en az 4 karakter olmalı" : null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Hakkında"
              ),
              onSaved: (girilenDeger){
                _hakkinda = girilenDeger;
              },
              validator: (girilenDeger)=>girilenDeger.trim().length > 100 ? "100 karakterden az olmalı" : null //Şişman okluda return eklemen gerekmez
            )
          ],
        )
        ),
    );

  }

  kaydet(){

    if(_formKey.currentState.validate()){
      print("Girilen verilerde sorun yok");
      print("Kullanıcı adı: $_kullaniciAdi");
      print("Kullanıcı adı: $_hakkinda");
      _formKey.currentState.save();
      print("Kullanıcı adı: $_kullaniciAdi");
      print("Kullanıcı adı: $_hakkinda");
      
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profili Düzenle",style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.grey[100],
        leading: IconButton(icon: Icon(Icons.close,color: Colors.black,), onPressed: ()=>Navigator.pop(context)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.check,color: Colors.black,), onPressed: kaydet)
        ],
      ),
      body: ListView(
        children: <Widget>[
          profilFoto(),
          kullaniciBilgileri()
        ],
      ),
    );
  }
}