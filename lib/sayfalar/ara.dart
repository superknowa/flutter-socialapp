import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {

  TextEditingController _aramaController = TextEditingController();
  Future <List<Kullanici>> _aramaSonucu;

  Widget _appbarOlustur(){
    return AppBar(
      titleSpacing: 0.0,
        backgroundColor: Colors.grey[100],
        title: TextFormField(
          onFieldSubmitted: (girilenKelime){
           
           
            setState(() {
              _aramaSonucu = FireStoreServisi().kullaniciAra(girilenKelime);
            });
            

          },
          controller: _aramaController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search,size: 30.0,),
            suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: (){
              _aramaController.clear();
              setState(() {
                _aramaSonucu = null;
              });
              }),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            hintText: "Kullanıcı ara...",
            contentPadding: EdgeInsets.only(top:16.0)
          ),
        ),
      );
  }

  sonuclariGetir(){

    return FutureBuilder<List<Kullanici>>(//Veritipini sonradan ekle. Farkı göster. Eklemezsen editör tamamlamaz.
      future: _aramaSonucu,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator());
        }

        if(snapshot.data.length == 0){
          return Center(child: Text("Bu arama için sonuç bulunamadı!"));
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context,index){

            Kullanici kullanici = snapshot.data[index];
            return kullaniciSatiri(kullanici);

          }
          );

      }
      );

  }

  kullaniciSatiri(Kullanici kullanici){

    return GestureDetector(
          onTap: (){

            String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Profil(aktifKullaniciId: aktifKullaniciId, profilSahibiId: kullanici.id, )));

          },
          child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(kullanici.kullaniciAdi,style: TextStyle(fontWeight: FontWeight.w500),),
      ),
    );

  }
  

  aramaYok(){
    return Center(child: Text("Kullanıcı ara"));
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }
}