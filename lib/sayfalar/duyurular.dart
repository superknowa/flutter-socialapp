import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/duyurular.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/tekligonderi.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    duyurulariGetir();
  }

  Future<void> duyurulariGetir() async {
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
            leading: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>Profil(aktifKullaniciId: _aktifKullaniciId,profilSahibiId: duyuru.aktiviteYapanId,)
                        ));
              },
                          child: CircleAvatar(
                backgroundImage:
                    NetworkImage(aktiviteYapan.fotoUrl,),
              ),
            ),
            title: RichText(
              maxLines: 3,
              overflow: TextOverflow.fade,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>Profil(aktifKullaniciId: _aktifKullaniciId,profilSahibiId: duyuru.aktiviteYapanId,)
                        ));
                    },
                    text: '${aktiviteYapan.kullaniciAdi}',
                    style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                  TextSpan(
                    text: duyuru.yorum == null ? ' $mesaj' : ' $mesaj ${duyuru.yorum}',
                    style: TextStyle(fontWeight: FontWeight.normal)
                    ),
                ],
              ),
            ),
            subtitle: Text(timeago.format(duyuru.olusturulmaZamani.toDate(), locale: 'tr')),
            trailing: gonderiGorsel(duyuru.aktiviteTipi, duyuru.gonderiFoto, duyuru.gonderiId),
          );
        });
  }


  gonderiGorsel(String aktiviteTipi, String gonderiFoto, String gonderiId) {
    if (aktiviteTipi == "takip") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>TekliGonderi(gonderiId:gonderiId ,gonderiSahibiId: _aktifKullaniciId,)));
        },
              child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(gonderiFoto),
                  fit: BoxFit.cover)),
        ),
      );
    }
  }

  Widget duyuruVar() {
    return RefreshIndicator(
      onRefresh: duyurulariGetir,
          child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: ListView.builder(
        itemCount: _duyurular.length,
        itemBuilder: (context, index) {
          Duyuru duyuru = _duyurular[index];
          return duyuruSatiri(duyuru);
        }),
        ),
    );
  }

  Widget duyuruYok() {
    return Center(child: Text("Hiç duyurunuz yok."));
  }

  Widget kontrol() {
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
        body: kontrol()
          );
  }
}
