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
  Kullanici _gonderiSahibi;
  bool _yukleniyor = true;
 

  @override
  void initState() { 
    super.initState();
    gonderiGetir();
    
  }


  gonderiGetir() async {



    Gonderi gonderi = await FireStoreServisi().tekliGonderiGetir(widget.gonderiId, widget.gonderiSahibiId);
    if(gonderi != null){


      Kullanici gonderiSahibi = await FireStoreServisi().kullaniciGetir(gonderi.yayinlayanId);
      
      setState(() {
        _gonderi = gonderi;
        _gonderiSahibi = gonderiSahibi;
        _yukleniyor = false;
      });

    }
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
        body: _yukleniyor == false ? GonderiKart(gonderi: _gonderi, yayinlayan: _gonderiSahibi,) : Center(child: CircularProgressIndicator()),
    );
  }
}