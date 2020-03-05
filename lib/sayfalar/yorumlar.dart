import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/yorum.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Yorumlar extends StatefulWidget {

final Gonderi gonderi;
Yorumlar({this.gonderi});

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {

  TextEditingController _yorumKontrolcusu = TextEditingController();

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
                  return Text(yorum.icerik);
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
      body: Column(
        children: <Widget>[
          yorumlariGoster(),
          yorumEkle()
        ],
      )
    );
  }
}