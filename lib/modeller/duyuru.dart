import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  final String id;
  final String aktiviteYapanId;
  final String aktiviteTipi;
  final String gonderiId;
  final String gonderiFoto;
  final String yorum;
  final Timestamp olusturulmaZamani;

  Duyuru({this.id, this.aktiviteYapanId, this.aktiviteTipi, this.gonderiId, this.gonderiFoto, this.yorum, this.olusturulmaZamani});

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Duyuru(
      id: doc.id, 
      aktiviteYapanId: docData['aktiviteYapanId'],
      aktiviteTipi: docData['aktiviteTipi'],
      gonderiId: docData['gonderiId'],
      gonderiFoto: docData['gonderiFoto'],
      yorum: docData['yorum'],
      olusturulmaZamani: docData['olusturulmaZamani'],
    );
  }
}