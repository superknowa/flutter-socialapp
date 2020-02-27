import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/modeller/kullanici.dart';

class FireStoreServisi {
  final Firestore _firestore = Firestore.instance;
  final DateTime timestamp = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl=""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "id": id,
      "username": kullaniciAdi,
      "photoUrl": fotoUrl,
      "email": email,
      "bio": "",
      "timestamp": timestamp
    });
  }


  Future<void> kullaniciGetir({id}) async {
    DocumentSnapshot doc = await _firestore.collection("kullanicilar").document(id).get();
    Kullanici kullanici = Kullanici.dokumandanUret(doc);
    return kullanici;
  }



}
