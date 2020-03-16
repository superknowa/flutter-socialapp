import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/modeller/duyurular.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/storageservisi.dart';

class FireStoreServisi {
  final Firestore _firestore = Firestore.instance;
  final DateTime timestamp = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "username": kullaniciAdi,
      "photoUrl": fotoUrl,
      "email": email,
      "bio": "",
      "timestamp": timestamp
    });
  }

  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").document(id).get();

    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }

    return null;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .document(kullaniciId)
        .collection("kullanicininTakipcileri")
        .getDocuments();
    return snapshot.documents.length;
  }

  Future<int> takipEdileniSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipedilenler")
        .document(kullaniciId)
        .collection("kullanicininTakipleri")
        .getDocuments();
    return snapshot.documents.length;
  }

  Future<void> gonderiOlustur(
      {gonderResimiUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore
        .collection("gonderiler")
        .document(yayinlayanId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderResimiUrl": gonderResimiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
    });
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .document(kullaniciId)
        .collection("kullaniciGonderileri")
        .getDocuments();

    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiBegen({String aktifKullaniciId, Gonderi gonderi}) async {
    //Beğeni sayısını artır

    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yenibegeniSayisi = gonderi.begeniSayisi + 1;
      docRef.updateData({"begeniSayisi": yenibegeniSayisi});

      //begeniler koleksiyonuna ekle
      _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .setData({});

      //Beğeni haberini gönderi sahibine iletiyoruz.
      duyuruEkle(
          aktiviteTipi: "begeni",
          aktiviteYapanId: aktifKullaniciId,
          gonderi: gonderi,
          profilSahibiId: gonderi.yayinlayanId);
    }
  }

  Future<void> gonderiBegeniKaldir(
      {String aktifKullaniciId, Gonderi gonderi}) async {
    //Beğeni sayısını azalt

    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yenibegeniSayisi = gonderi.begeniSayisi - 1;
      docRef.updateData({"begeniSayisi": yenibegeniSayisi});

      DocumentSnapshot docBegeni = await _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .get();

      if (docBegeni.exists) {
        //Önce böyle bir kayıt olduğundan emin olduk. Sonra sildik.
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarmi({String aktifKullaniciId, Gonderi gonderi}) async {
    DocumentSnapshot doc = await _firestore
        .collection("begeniler")
        .document(gonderi.id)
        .collection("gonderiBegenileri")
        .document(aktifKullaniciId)
        .get();

    if (doc.exists) {
      //doc varsa beğeni var
      return true;
    }
    //Tek satırda da yazılabilir
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .document(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void yorumEkle({String aktifKullaniciId, Gonderi gonderi, String icerik}) {
    _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "timestamp": timestamp,
    });

    //Yorum duyurusunu gönderi sahibine iletiyoruz.
    duyuruEkle(
        aktiviteTipi: "yorum",
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId,
        yorum: icerik);
  }

  void kullaniciGuncelle(
      {String kullaniciId,
      String kullaniciAdi,
      String fotoUrl = "",
      String hakkinda}) {
    _firestore.collection("kullanicilar").document(kullaniciId).updateData({
      "username": kullaniciAdi,
      "photoUrl": fotoUrl,
      "bio": hakkinda,
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanicilar")
        .where("username", isGreaterThanOrEqualTo: kelime)
        .getDocuments();

    List<Kullanici> kullanicilar =
        snapshot.documents.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  void takipEt({String aktifKullaniciId, String profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .document(aktifKullaniciId)
        .setData({});

    _firestore
        .collection("takipedilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .setData({});

    //Takip edilen kullanıcıya duyuru gönder
    duyuruEkle(
        aktiviteTipi: "takip",
        aktiviteYapanId: aktifKullaniciId,
        profilSahibiId: profilSahibiId);
  }

  void takiptenCik({String aktifKullaniciId, String profilSahibiId}) {
    //Takipçi Sil
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .document(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Takip edilen Sil
    _firestore
        .collection("takipedilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> takipKontrol(
      {String aktifKullaniciId, String profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipedilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .get();

    if (doc.exists) {
      return true;
    }

    return false;
  }

  void duyuruEkle(
      {String aktiviteYapanId,
      String profilSahibiId,
      String aktiviteTipi,
      String yorum,
      Gonderi gonderi}) async {
    if (aktiviteYapanId == profilSahibiId) {
      return;
    }

    _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderResimiUrl,
      "yorum": yorum,
      "timestamp": timestamp
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("duyurular")
        .document(kullaniciId)
        .collection("kullanicininDuyurulari")
        .orderBy('timestamp', descending: true)
        .limit(20) //Son 20 duyuruyu getirdi
        .getDocuments();

    List<Duyuru> duyurular = [];
    //Farklılık olsun map yerine forEach kullanalım
    snapshot.documents.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });

    return duyurular;
  }

  Future<Gonderi> tekliGonderiGetir(
      String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection("gonderiler")
        .document(gonderiSahibiId)
        .collection("kullaniciGonderileri")
        .document(gonderiId)
        .get();

    Gonderi gonderi = Gonderi.dokumandanUret(doc);

    return gonderi;
  }

  Future<void> gonderiSil({String aktifKullaniciId, Gonderi gonderi}) async {
    //Gönderiyi siliyoruz
    _firestore
        .collection("gonderiler")
        .document(aktifKullaniciId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Gönderiye ait yorumları siliyoruz
    QuerySnapshot yorumlarSnapshot = await _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .getDocuments();

    //Çekilen tüm gönderileri forEach döngüsü kullanarak tek tek sildirelim
    yorumlarSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });


    //Silinen gönderiyle ilgili tüm duyuruları silelim
    QuerySnapshot duyurularSnapshot = await _firestore
        .collection("duyurular")
        .document(gonderi.yayinlayanId)
        .collection("kullanicininDuyurulari")
        .where("gonderiId", isEqualTo: gonderi.id)
        .getDocuments();

    duyurularSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Storage servisinden gönderi resmini sil
    StorageServisi().gonderiResmiSil(gonderi.gonderResimiUrl);


  }


  Future<List<Gonderi>> akislariGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("akis")
        .document(kullaniciId)
        .collection("kullaniciAkis")
        .getDocuments();

    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }


}
