import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;

  Yorum({this.id, this.icerik, this.yayinlayanId, this.olusturulmaZamani});

  factory Yorum.dokumandanUret(DocumentSnapshot doc) {
    return Yorum(
      id: doc.documentID, //Bu kısmı anlat
      icerik: doc['icerik'],
      yayinlayanId: doc['yayinlayanId'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }
}
