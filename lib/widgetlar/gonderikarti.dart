import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
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

  @override
  void initState() { 
    super.initState();
    _begeniSayisi = widget.gonderi.begeniSayisi;
  }

  gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left:12.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: CachedNetworkImageProvider(widget.yayinlayan.fotoUrl),
        ),
      ),
      title: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {},
      ),
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  gonderiResmi() {
    return Container(
      height: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(widget.gonderi.gonderResimiUrl,
          ),fit: BoxFit.cover,)
      ),
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
              icon: _begendin ? Icon(
                Icons.favorite,
                color: Colors.red,
                size: 35.0,
              ) :  Icon(
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
              onPressed: null,
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
        widget.gonderi.aciklama.isNotEmpty ? Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Text(
                widget.yayinlayan.kullaniciAdi,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Text(widget.gonderi.aciklama))
          ],
        ) : SizedBox(height: 0.0,)
      ],
    );
  }


  begeniDegistir(){

    String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;

    if(_begendin){
      //Beğenmiş durumdasın, beğeniden çıkart
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi  - 1;
      });

      FireStoreServisi().gonderiBegeniKaldir(aktifKullaniciId:aktifKullaniciId , gonderi:widget.gonderi);
      

    } else {
      
      //Henüz beğenmemişsin, beğen
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi  + 1;
      });
      FireStoreServisi().gonderiBegen(aktifKullaniciId:aktifKullaniciId , gonderi:widget.gonderi);
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
