import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/storageservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

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
bool _yukleniyor = false;
  
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
            backgroundColor: Colors.grey[300],
        backgroundImage: _secilmisFoto == null ?  (widget.profil.fotoUrl.isNotEmpty
                      ? NetworkImage(widget.profil.fotoUrl)
                      : AssetImage("assets/male.png")) : FileImage(_secilmisFoto),
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

  kaydet() async{

    if(_formKey.currentState.validate()){
    
      setState(() {
        _yukleniyor = true;
      });

      _formKey.currentState.save();
      

      String profiResmilUrl;

      if(_secilmisFoto == null){
        profiResmilUrl = widget.profil.fotoUrl;
      } else {
        profiResmilUrl = await  StorageServisi().profiliResmiYukle(_secilmisFoto);
      }

      

      String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;
      FireStoreServisi().kullaniciGuncelle(kullaniciId: aktifKullaniciId, kullaniciAdi: _kullaniciAdi, fotoUrl: profiResmilUrl, hakkinda: _hakkinda);

      setState(() {
        _yukleniyor = false;
      });

      Navigator.pop(context);

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
          _yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0.0,),
          profilFoto(),
          kullaniciBilgileri()
        ],
      ),
    );
  }
}