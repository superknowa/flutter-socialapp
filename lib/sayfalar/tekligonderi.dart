import 'package:flutter/material.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/widgetlar/gonderikarti.dart';

class TekliGonderi extends StatefulWidget {

  final String gonderiId;
  final String gonderiSahibiId;

  TekliGonderi({this.gonderiId, this.gonderiSahibiId});

 
  
  @override
  _TekliGonderiState createState() => _TekliGonderiState();
}

class _TekliGonderiState extends State<TekliGonderi> {

  Gonderi _gonderi;

  @override
  void initState() { 
    super.initState();
    gonderiGetir();
    
  }


  gonderiGetir() async {
    Gonderi gonderi = await FireStoreServisi().tekliGonderiGetir(widget.gonderiId, widget.gonderiSahibiId);
    setState(() {
      _gonderi = gonderi;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Gönderi",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,), onPressed: ()=>Navigator.pop(context)),
          backgroundColor: Colors.grey[100],
        ),
        body: FutureBuilder<Kullanici>(
          future: FireStoreServisi().kullaniciGetir(_gonderi.yayinlayanId),
          builder: (context, snapshot){

            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }

            Kullanici gonderiSahibi = snapshot.data;
            return GonderiKart(gonderi: _gonderi, yayinlayan: gonderiSahibi,);

          }
          ),
    );
  }
}