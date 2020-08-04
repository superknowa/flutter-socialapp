import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {

final StorageReference _storage = FirebaseStorage.instance.ref();
String resimId;

Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage.child("resimler/gonderiler/gonderi_$resimId.jpg").putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
}


Future<String> profiliResmiYukle(File resimDosyasi) async {

    resimId = Uuid().v4();
    StorageUploadTask yuklemeTakibi = _storage.child("resimler/profil/gonderi_$resimId.jpg").putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeTakibi.onComplete;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
    
}


void gonderiResmiSil(String gonderiResmiUrl){

     RegExp kural = RegExp(r'gonderi_.+\.jpg');
     
     var eslesme = kural.firstMatch(gonderiResmiUrl);
     String dosyaAdi = eslesme[0];
     
      if(dosyaAdi!= null){
        _storage.child("resimler/gonderiler/$dosyaAdi").delete();
      }
}



}