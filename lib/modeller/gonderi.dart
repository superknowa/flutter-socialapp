import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {

  final String id;
  final String gonderResimiUrl;
  final String aciklama;
  final String yayinlayanId;
  final String kullaniciAdi;
  final int begeniSayisi;
  final String konum;
  final Timestamp timestamp;

  Gonderi({this.id, this.gonderResimiUrl, this.aciklama, this.yayinlayanId, this.kullaniciAdi, this.begeniSayisi, this.konum, this.timestamp});

  factory Gonderi.dokumandanUret(DocumentSnapshot doc) {
    return Gonderi(
      id : doc['id'],
      gonderResimiUrl: doc['gonderResimiUrl'],
      aciklama: doc['aciklama'],
      yayinlayanId: doc['yayinlayanId'],
      kullaniciAdi: doc['kullaniciAdi'],
      begeniSayisi: doc['begeniSayisi'],
      konum: doc['konum'],
      timestamp: doc['timestamp'],
    );
  }


}