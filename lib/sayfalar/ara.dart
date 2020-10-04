import 'package:flutter/material.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaController = TextEditingController();
  Future<List<Kullanici>> _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur(){
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        onFieldSubmitted: (girilenDeger){
          setState(() {
            _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _aramaController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, size: 30.0,),
          suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: (){
            _aramaController.clear();
            setState(() {
              _aramaSonucu = null;
            });
            }),
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          hintText: "Kullanıcı Ara...",
          contentPadding: EdgeInsets.only(top: 16.0)
        ),
      ),
    );
  }

  aramaYok(){
    return Center(child: Text("Kullanıcı Ara"));
  }

  sonuclariGetir(){
    return FutureBuilder<List<Kullanici>>(
      future: _aramaSonucu ,
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator());
        }

        if(snapshot.data.length == 0){
          return Center(child: Text("Bu arama için sonuç bulunamadı!"));
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index){
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Profil(profilSahibiId: kullanici.id,)));
      },
          child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(kullanici.kullaniciAdi, style: TextStyle(fontWeight: FontWeight.bold),),
      ),
    );
  }
}