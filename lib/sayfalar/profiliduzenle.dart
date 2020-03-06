import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialapp/modeller/kullanici.dart';

class ProfiliDuzenle extends StatefulWidget {

  final Kullanici profil;
  ProfiliDuzenle({this.profil});

  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {

final _formKey = GlobalKey<FormState>();
String _kullaniciAdi = "";
String _hakkinda = "";
File _secilmisFoto;
  
  fotoSec() async {

    File resimDosyasi = await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 80);
    if(resimDosyasi!=null){
      setState(() {
        _secilmisFoto = resimDosyasi;
      });
    }
  }

  profilFoto(){
    return Column(
        children: <Widget>[
    SizedBox(height: 15.0,),
    GestureDetector(
      onTap: fotoSec,
          child: CircleAvatar(
        backgroundImage: _secilmisFoto == null ?  CachedNetworkImageProvider(widget.profil.fotoUrl) : FileImage(_secilmisFoto),
        radius: 55.0,
      ),
    ),
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
              initialValue: widget.profil.kullaniciAdi,
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
              initialValue: widget.profil.hakkinda,
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