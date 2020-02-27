import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String kullaniciAdi, email, sifre;
  bool yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        appBar: AppBar(
          title: Text(
            "Hesap Oluştur"),
        ),
        body: ListView(
          children: <Widget>[
            yukleniyor
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formAnahtari,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: "Kullanıcı adınızı girin",
                          labelText: "Kullanıcı Adı:",
                          errorStyle: TextStyle(fontSize: 16.0),
                          prefixIcon: Icon(Icons.person)),
                      validator: (girilenDeger) {
                        if (girilenDeger.isEmpty) {
                          return 'Kullanıcı adı boş bırakılamaz!';
                        } else if (girilenDeger.trim().length < 4 ||
                            girilenDeger.trim().length > 10) {
                          return 'En az 4 en fazla 10 karakter olabilir!';
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => kullaniciAdi = girilenDeger,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            hintText: "Mail adresinizi girin",
                            labelText: "E-Posta:",
                            errorStyle: TextStyle(fontSize: 16.0),
                            prefixIcon: Icon(Icons.lock)),
                        validator: (girilenDeger) {
                          if (girilenDeger.isEmpty) {
                            return 'Mail adresi boş bırakılamaz!';
                          } else if (!girilenDeger.contains("@")) {
                            return 'Girilen değer mail formatında olmalı!';
                          }
                          return null;
                        },
                        onSaved: (girilenDeger) => email = girilenDeger),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "Şifrenizi girin",
                            labelText: "Şifre",
                            errorStyle: TextStyle(fontSize: 16.0),
                            prefixIcon: Icon(Icons.lock)),
                        validator: (girilenDeger) {
                          if (girilenDeger.isEmpty) {
                            return 'Şifre alanı boş bırakılamaz!';
                          } else if (girilenDeger.length < 4) {
                            return 'Şifre 4 karakterden az olamaz!';
                          }
                          return null;
                        },
                        onSaved: (girilenDeger) => sifre = girilenDeger),
                    SizedBox(
                      height: 50.0,
                    ),
                    InkWell(
                      onTap: _kullaniciOlustur,
                      child: Container(
                        alignment: Alignment.center,
                        height: 40.0,
                        width: double.infinity,
                        color: Theme.of(context).primaryColorDark,
                        child: Text(
                          "Hesap Oluştur",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  _kullaniciOlustur() async {

    final _yetkilendirmeServisi = Provider.of<YetkilendirmeServisi>(context, listen: false);

    final _formState = _formAnahtari.currentState;

    if (_formState.validate()) {
      _formState.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        Kullanici kullanici = await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        if(kullanici != null){
          FireStoreServisi().kullaniciOlustur(id: kullanici.id,kullaniciAdi: kullaniciAdi, email: email );
        }
        Navigator.pop(context);
      } catch (err) {
        setState(() {
        yukleniyor = false;
      });
        uyariGoster(hataKodu: err.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hataMesaji = "Girdiğiniz mail kayıtlıdır";
    } else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaji = "Daha zor bir şifre tercih edin";
    }

    final snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
