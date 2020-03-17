import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class SifremiUnuttum extends StatefulWidget {
  @override
  _SifremiUnuttumState createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String email;
  bool yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        appBar: AppBar(
          title: Text(
            "Şifremi Sıfırla"),
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
                      height: 50.0,
                    ),
                    InkWell(
                      onTap: _sifreyiSifirla,
                      child: Container(
                        alignment: Alignment.center,
                        height: 40.0,
                        width: double.infinity,
                        color: Theme.of(context).primaryColorDark,
                        child: Text(
                          "Şifremi Sıfırla",
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

  _sifreyiSifirla() async {

    final _yetkilendirmeServisi = Provider.of<YetkilendirmeServisi>(context, listen: false);

    final _formState = _formAnahtari.currentState;

    if (_formState.validate()) {
      _formState.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        
        await _yetkilendirmeServisi.sifremiSifirla(email);
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
    } else if (hataKodu == "ERROR_USER_NOT_FOUND") {
      hataMesaji = "Bu mailde bir kullanıcı bulunmuyor";
    }

    final snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
