import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yorumlar.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class GonderiKart extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKart({this.gonderi, this.yayinlayan});

  @override
  _GonderiKartState createState() => _GonderiKartState();
}

class _GonderiKartState extends State<GonderiKart> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false)
        .aktifKullaniciId;
    _begeniSayisi = widget.gonderi.begeniSayisi;
    begeniVarMi();
  }

  begeniVarMi() async {
    bool begeniVarMi = await FireStoreServisi().begeniVarmi(
        aktifKullaniciId: aktifKullaniciId, gonderi: widget.gonderi);
    if (begeniVarMi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  gonderiSecenekleri() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Seçiminiz nedir?"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Gönderiyi Sil"),
                onPressed: () {
                  FireStoreServisi().gonderiSil(
                      aktifKullaniciId: aktifKullaniciId,
                      gonderi: widget.gonderi);
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text("Vazgeç", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profil(
                          profilSahibiId: widget.gonderi.yayinlayanId,
                          aktifKullaniciId: aktifKullaniciId,
                        )));
          },
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage:
                NetworkImage(widget.yayinlayan.fotoUrl),
          ),
        ),
      ),
      title: GestureDetector(
        onTap: (){
          Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profil(
                          profilSahibiId: widget.gonderi.yayinlayanId,
                          aktifKullaniciId: aktifKullaniciId,
                        )));
        },
              child: Text(
          widget.yayinlayan.kullaniciAdi,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: aktifKullaniciId == widget.gonderi.yayinlayanId ? IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: gonderiSecenekleri,
      ):null,
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  gonderiResmi() {
    return GestureDetector(
      onDoubleTap: begeniDegistir,
      child: Image.network(widget.gonderi.gonderResimiUrl,height: MediaQuery.of(context).size.width,fit: BoxFit.cover,),
    );
  }

  gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment
          .start, //Sonda ekle beğeni yazısının sola kaydığı görülsün.
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: _begendin
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 35.0,
                    )
                  : Icon(
                      Icons.favorite_border,
                      size: 35.0,
                    ),
              onPressed: begeniDegistir,
            ),
            IconButton(
              icon: Icon(
                Icons.comment,
                size: 35.0,
              ),
              onPressed: yorumlaraGit,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begeniSayisi beğeni",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.gonderi.aciklama.isNotEmpty
            ? Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Text(
                      widget.yayinlayan.kullaniciAdi,
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Text(widget.gonderi.aciklama))
                ],
              )
            : SizedBox(
                height: 0.0,
              )
      ],
    );
  }

  yorumlaraGit() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Yorumlar(
                  gonderi: widget.gonderi,
                )));
  }

  begeniDegistir() {
    if (_begendin) {
      //Beğenmiş durumdasın, beğeniden çıkart
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });

      FireStoreServisi().gonderiBegeniKaldir(
          aktifKullaniciId: aktifKullaniciId, gonderi: widget.gonderi);
    } else {
      //Henüz beğenmemişsin, beğen
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FireStoreServisi().gonderiBegen(
          aktifKullaniciId: aktifKullaniciId, gonderi: widget.gonderi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        gonderiBasligi(),
        gonderiResmi(),
        gonderiAlt(),
        SizedBox(
          height: 10.0,
        )
      ],
    );
  }
}
