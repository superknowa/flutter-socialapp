import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File dosya;
  bool yukleniyor = false;

  TextEditingController aciklamaTextKumandasi  = TextEditingController();
  TextEditingController konumTextKumandasi  = TextEditingController();

  @override
  Widget build(BuildContext contextaaa) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
        icon: Icon(
          Icons.file_upload,
          size: 50.0,
        ),
        onPressed: () {
          fotografSec(context);
        });
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                dosya = null;
              });
            }),
        actions: <Widget>[IconButton(icon: Icon(Icons.send,color: Colors.black,), onPressed: gonderiOlustur)],
      ),
      body: ListView(
        children: <Widget>[
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(dosya), fit: BoxFit.fill)),
            ),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: aciklamaTextKumandasi,
            decoration: InputDecoration(
              hintText: "Açıklama ekle",
              contentPadding: EdgeInsets.only(left:15.0,right: 15.0),
            ),
          ),
          TextFormField(
            controller: konumTextKumandasi,
            decoration: InputDecoration(
              hintText: "Fotoğraf nerede çekildi?",
              contentPadding: EdgeInsets.only(left:15.0,right: 15.0),
            ),
          ),
        ],
      ),
    );
  }

  gonderiOlustur(){

    print(aciklamaTextKumandasi.text);
    print(konumTextKumandasi.text);
  }


  fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 800, maxHeight: 600);
    setState(() {
      dosya = image;
    });
  }

  galeridenSec() async {
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, maxHeight: 600);
    setState(() {
      dosya = image;
    });
  }

  fotografSec(ustContext) {
    showDialog(
        context: ustContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Gönderi Oluştur"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Fotoğraf Çek"),
                onPressed: fotoCek,
              ),
              SimpleDialogOption(
                  child: Text("Galeriden Yükle"), onPressed: galeridenSec),
              SimpleDialogOption(
                child: Text("İptal"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }
}
