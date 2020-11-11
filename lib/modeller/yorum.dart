import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;

  Yorum({this.id, this.icerik, this.yayinlayanId, this.olusturulmaZamani});

  factory Yorum.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Yorum(
      id : doc.id,
      icerik: docData['icerik'],
      yayinlayanId: docData['yayinlayanId'],
      olusturulmaZamani: docData['olusturulmaZamani'],
    );
  }

}