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


  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc = await _firestore.collection("kullanicilar").document(id).get();
    Kullanici kullanici = Kullanici.dokumandanUret(doc);
    return kullanici;
  }


  Future<int> takipciSayisi(id) async {
   QuerySnapshot  snapshot = await _firestore.collection("takipciler").document(id).collection("kullanicininTakipcileri").getDocuments();
   return snapshot.documents.length;
  }

  Future<int> takipEdileniSayisi(id) async {
   QuerySnapshot  snapshot = await _firestore.collection("takipedilenler").document(id).collection("kullanicininTakipleri").getDocuments();
   return snapshot.documents.length;
  }



}
