import 'package:flutter/material.dart';

class Profil extends StatefulWidget {

  final String profilSahibi;
  final String aktifKullanici;

  Profil({this.profilSahibi, this.aktifKullanici});


  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {

  Widget _profilDetaylari(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 50.0,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                      _profilSayac(baslik: "Gönderiler",sayi:35),
                      _profilSayac(baslik: "Takipçi",sayi:958),
                      _profilSayac(baslik: "Takip",sayi:125),
                    ],)
                  ],
                )
                )
            ],
          ),
          SizedBox(height: 10.0,),
          Container(
            alignment: Alignment.centerLeft,
            child: Text("Hamdi Genco",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),)
            ),
            SizedBox(height: 5.0,),
          Container(
            alignment: Alignment.centerLeft,
            child: Text("Reklam ve iş birlikleri için dm atmanız yeter de artar.",)
            ),
            SizedBox(height: 25.0,),
            _profilButon()
            
        ],
      ),
    );
  }

  Widget _profilButon(){
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 34.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(width: 1.0,color: Colors.grey[300]),
        color: Colors.white54,
      ),
      child: Text("Profili Düzenle",style: TextStyle(fontWeight: FontWeight.bold),),

    );
  }

  Widget _profilSayac({String baslik,int sayi}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(sayi.toString(),style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
        SizedBox(height:2.0),
        Text(baslik,style: TextStyle(fontSize: 15.0),),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil",style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.grey[100],
        actions: <Widget>[
          IconButton(icon: Icon(Icons.exit_to_app), onPressed: null)
        ],
        ),
        body:ListView(
          children: <Widget>[
            _profilDetaylari()
          ],
        )
    );
  }
}