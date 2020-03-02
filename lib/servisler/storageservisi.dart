import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {

final StorageReference _storage = FirebaseStorage.instance.ref();
String resimId;

Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    StorageUploadTask yuklemeTakibi = _storage.child("resimler/gonderiler/gonderi_$resimId.jpg").putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeTakibi.onComplete;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
}



}