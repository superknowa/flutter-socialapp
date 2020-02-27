import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/hesapolustur.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        body: Stack(
          children: <Widget>[_sayfaElemanlari(), _yuklemeAnimasyonu()],
        ));
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
        children: <Widget>[
          FlutterLogo(size: 90.0),
          SizedBox(
            height: 80.0,
          ),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintText: "Email adresinizi girin",
                errorStyle: TextStyle(fontSize: 16.0),
                prefixIcon: Icon(Icons.mail)),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return 'Email alanı boş bırakılamaz!';
              } else if (!girilenDeger.contains("@")) {
                return 'Girilen değer mail formatında olmalı!';
              }
              return null;
            },
            onSaved: (girilenDeger) => email = girilenDeger,
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
                hintText: "Şifrenizi girin",
                errorStyle: TextStyle(fontSize: 16.0),
                prefixIcon: Icon(Icons.lock)),
            validator: (girilenDeger) {
              if (girilenDeger.isEmpty) {
                return 'Şifre alanı boş bırakılamaz!';
              } else if (girilenDeger.trim().length < 4) {
                return 'Şifre 4 karakterden az olamaz!';
              }
              return null;
            },
            onSaved: (girilenDeger) => sifre = girilenDeger,
          ),
          SizedBox(
            height: 40.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: _hesapOlustur,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40.0,
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      "Hesap Oluştur",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: InkWell(
                  onTap: _girisYap,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40.0,
                    color: Theme.of(context).primaryColorDark,
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Align(alignment: Alignment.center, child: Text("veya")),
          SizedBox(
            height: 20.0,
          ),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 40.0,
            color: Colors.white,
            child: GestureDetector(
              onTap: _googleIleGiris,
              child: Text(
                "Google İle Giriş Yap",
                style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Align(alignment: Alignment.center, child: Text("Şifremi Unuttum")),
        ],
      ),
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    if (_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        await _yetkilendirmeServisi.mailIleGiris(email, sifre);
      } catch (err) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: err?.code);
      }
    }
  }

  void _googleIleGiris() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    setState(() {
      yukleniyor = true;
    });

    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if(kullanici != null){
        FireStoreServisi().kullaniciOlustur(id: kullanici.id,kullaniciAdi: kullanici.kullaniciAdi, email: kullanici.email, fotoUrl: kullanici.fotoUrl );
      }
    } catch (err) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: err.code);
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "ERROR_USER_NOT_FOUND") {
      hataMesaji = "Böyle bir kullanıcı bulunmuyor";
    } else if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_WRONG_PASSWORD") {
      hataMesaji = "Girilen şifre hatalı";
    } else if (hataKodu == "ERROR_USER_DISABLED") {
      hataMesaji = "Kullanıcı engellenmiş";
    } else {
      hataMesaji = "Tanımlanamayan bir hata oluştu $hataKodu";
    }

    final snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }

  void _hesapOlustur() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HesapOlustur()));
  }
}
