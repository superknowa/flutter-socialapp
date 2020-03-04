import 'package:flutter/material.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';

class GonderiKart extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKart({this.gonderi, this.yayinlayan});


  @override
  _GonderiKartState createState() => _GonderiKartState();
}

class _GonderiKartState extends State<GonderiKart> {
  gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left:12.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
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
      decoration: BoxDecoration(color: Colors.blue),
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
              icon: Icon(
                Icons.favorite_border,
                size: 35.0,
              ),
              onPressed: null,
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
            "100 beğenİ,",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Text(
                "Kullanıcı Adı",
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Text("Gonderi açıklaması buraya gelecek"))
          ],
        )
      ],
    );
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
