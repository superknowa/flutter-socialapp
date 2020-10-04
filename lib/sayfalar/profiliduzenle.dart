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

  const ProfiliDuzenle({Key key, this.profil}) : super(key: key);

  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String _kullaniciAdi;
  String _hakkinda;
  File _secilmisFoto;
  bool _yukleniyor = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text("Profili Düzenle", style: TextStyle(color: Colors.black),),
        leading: IconButton(icon: Icon(Icons.close, color: Colors.black,), onPressed: ()=>Navigator.pop(context)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.check, color: Colors.black,), onPressed: _kaydet),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0.0,),
          _profilFoto(),
          _kullaniciBilgileri()
        ],
      ),
    );
  }

  _kaydet() async {

    if(_formKey.currentState.validate()){

      setState(() {
        _yukleniyor = true;
      });
      
      _formKey.currentState.save();

      String profilFotoUrl;
      if(_secilmisFoto == null){
        profilFotoUrl = widget.profil.fotoUrl;
      } else {
        profilFotoUrl = await StorageServisi().profilResmiYukle(_secilmisFoto);
      }

      String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;

      FireStoreServisi().kullaniciGuncelle(
        kullaniciId: aktifKullaniciId,
        kullaniciAdi: _kullaniciAdi,
        hakkinda: _hakkinda,
        fotoUrl: profilFotoUrl
      );

      setState(() {
        _yukleniyor = false;
      });

      Navigator.pop(context);
    }

  }

  _profilFoto(){
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Center(
        child: InkWell(
          onTap: _galeridenSec,
                  child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: _secilmisFoto == null ? NetworkImage(widget.profil.fotoUrl) : FileImage(_secilmisFoto),
            radius: 55.0,
          ),
        ),
      ),
    );
  }

  _galeridenSec() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 600, imageQuality: 80);
    setState(() {
       _secilmisFoto = File(image.path);
    });
  }

  _kullaniciBilgileri(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
              validator: (girilenDeger){
                return girilenDeger.trim().length <= 3 ? "Kullanıcı adı en az 4 karakter olmalı" : null;
              },
              onSaved: (girilenDeger){
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil.hakkinda,
              decoration: InputDecoration(
                labelText: "Hakkında"
              ),
              validator: (girilenDeger){
                return girilenDeger.trim().length > 100 ? "100 Karakterden fazla olmamalı" : null;
              },
              onSaved: (girilenDeger){
                _hakkinda = girilenDeger;
              },
            ),
          ],
        ),
      ),
    );
  }
}