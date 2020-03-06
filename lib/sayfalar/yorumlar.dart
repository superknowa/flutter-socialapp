import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yorum.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {

final Gonderi gonderi;
Yorumlar({this.gonderi});

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {

  TextEditingController _yorumKontrolcusu = TextEditingController();


  yorumSatiri(Yorum yorum){
    return FutureBuilder<Kullanici>(
      future: FireStoreServisi().kullaniciGetir(yorum.yayinlayanId),
      builder: (context, snapshot) {

        Kullanici yayinlayan = snapshot.data;

        if(!snapshot.hasData){
          return SizedBox(height: 0.0,);
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(yayinlayan.fotoUrl),
          ),
          title: Row(
            children: <Widget>[
              Text("${yayinlayan.kullaniciAdi}}:",style: TextStyle(fontWeight: FontWeight.bold),),
              Text(yorum.icerik)
            ],
          ),
          subtitle: Text(timeago.format(yorum.timestamp.toDate(), locale: 'tr'))
        );
      }
    );
  }

  yorumlariGoster(){
    
    return Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FireStoreServisi().yorumlariGetir(widget.gonderi.id),
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return Center(child: CircularProgressIndicator());
              }
              
              return ListView.builder(
                itemCount: snapshot.data.documents.length, //QuerySnapShot olduğunu bilmediği için tamamlamaz ama çalışır
                itemBuilder: (context, index){
                  Yorum yorum= Yorum.dokumandanUret(snapshot.data.documents[index]);
                  return yorumSatiri(yorum);
                }
                );
            }
            ),
    );
  }

  yorumEkle(){
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrolcusu,
        decoration: InputDecoration(
          hintText: "Yorumu buraya yazın.",
          hintStyle: TextStyle(color: Colors.black)
        ),
      ),
      trailing: IconButton(icon: Icon(Icons.send), onPressed: ()=>yorumGonder()), //farklı kullandım
    );
  }

  yorumGonder(){
    String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;
    FireStoreServisi().yorumEkle(aktifKullaniciId: aktifKullaniciId, gonderiId: widget.gonderi.id, icerik: _yorumKontrolcusu.text);
    _yorumKontrolcusu.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        title: Text("Yorumlar",style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.grey[100],
      ),
      body: Column( // Neden column kaydırmak gerekmeyecekmi diyebilirsiniz. Doğru gerekecek ama sayfanın bütününü kaydırmicaz sadece yorumlar kısmı kayacak. Alt kısım sabit kalacak. Yorumları listview.builder içine alıcaz
        children: <Widget>[
          yorumlariGoster(),
          yorumEkle()
        ],
      )
    );
  }
}