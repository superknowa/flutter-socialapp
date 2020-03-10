import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/duyurular.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Duyurular extends StatefulWidget {
  @override
  _DuyurularState createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  String _aktifKullaniciId;
  List<Duyuru> _duyurular = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    duyurulariGetir();
  }

  duyurulariGetir() async {
    List<Duyuru> duyurular =
        await FireStoreServisi().duyurulariGetir(_aktifKullaniciId);
    if(mounted){ //Widget'ın hala orada olduğundan emin olalım.
      setState(() {
        _duyurular = duyurular;
        _yukleniyor = false;
      });
    }
  }

  mesajOlustur(String aktiviteTipi) {
    if (aktiviteTipi == "begeni") {
      return "gönderini beğendi.";
    } else if (aktiviteTipi == "takip") {
      return "seni takip etti.";
    } else if (aktiviteTipi == "yorum") {
      return "gönderine yorum yaptı.";
    }

    return null;
  }

  duyuruSatiri(Duyuru duyuru) {
    String mesaj = mesajOlustur(duyuru.aktiviteTipi);

    return FutureBuilder(
        future: FireStoreServisi().kullaniciGetir(duyuru.aktiviteYapanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }

          Kullanici aktiviteYapan = snapshot.data;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(aktiviteYapan.fotoUrl),
            ),
            title: RichText(
              maxLines: 3,
              overflow: TextOverflow.fade,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = (){
                      print("Kullanıcı adına tıkladın.");
                    },
                    text: '${aktiviteYapan.kullaniciAdi}',
                    style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                  TextSpan(
                    text: ' $mesaj',
                    style: TextStyle(fontWeight: FontWeight.normal)
                    ),
                ],
              ),
            ),
            trailing: gonderiGorsel(duyuru.aktiviteTipi, duyuru.gonderiFoto),
          );
        });
  }

  printo(){
    print("sdsdfds usernme");
  }

  gonderiGorsel(String aktiviteTipi, String gonderiFoto) {
    if (aktiviteTipi == "takip") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: CachedNetworkImageProvider(gonderiFoto),
                fit: BoxFit.cover)),
      );
    }
  }

  Widget duyuruVar() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ListView.builder(
          itemCount: _duyurular.length,
          itemBuilder: (context, index) {
            Duyuru duyuru = _duyurular[index];
            return duyuruSatiri(duyuru);
          }),
    );
  }

  Widget duyuruYok() {
    return Center(child: Text("Hiç duyurunuz yok."));
  }

  kontrol() {
    if (_yukleniyor) {
      return Center(child: CircularProgressIndicator());
    }

    if (_duyurular.isNotEmpty) {
      return duyuruVar();
    } else {
      return duyuruYok();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Duyurular",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[100],
        ),
        body: kontrol());
  }
}
