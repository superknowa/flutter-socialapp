import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/modeller/duyuru.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/storageservisi.dart';

class FireStoreServisi {
  final Firestore _firestore = Firestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl=""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulmaZamani": zaman
    });
  }

  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc = await _firestore.collection("kullanicilar").document(id).get();
    if(doc.exists){
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void kullaniciGuncelle({String kullaniciId, String kullaniciAdi, String fotoUrl = "", String hakkinda}){
    _firestore.collection("kullanicilar").document(kullaniciId).updateData({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore.collection("kullanicilar").where("kullaniciAdi",isGreaterThanOrEqualTo: kelime).getDocuments();

    List<Kullanici> kullanicilar = snapshot.documents.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  void takipEt({String aktifKullaniciId, String profilSahibiId}){
    _firestore.collection("takipciler").document(profilSahibiId).collection("kullanicininTakipcileri").document(aktifKullaniciId).setData({});
    _firestore.collection("takipedilenler").document(aktifKullaniciId).collection("kullanicininTakipleri").document(profilSahibiId).setData({});

    //Takip edilen kullanıcıya duyuru gönder
    duyuruEkle(
      aktiviteTipi: "takip",
      aktiviteYapanId: aktifKullaniciId,
      profilSahibiId: profilSahibiId
    );
  }

  void takiptenCik({String aktifKullaniciId, String profilSahibiId}){
    _firestore.collection("takipciler").document(profilSahibiId).collection("kullanicininTakipcileri").document(aktifKullaniciId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    _firestore.collection("takipedilenler").document(aktifKullaniciId).collection("kullanicininTakipleri").document(profilSahibiId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

  }

  Future<bool> takipKontrol({String aktifKullaniciId, String profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore.collection("takipedilenler").document(aktifKullaniciId).collection("kullanicininTakipleri").document(profilSahibiId).get();
    if(doc.exists){
      return true;
    }
    return false;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore.collection("takipciler").document(kullaniciId).collection("kullanicininTakipcileri").getDocuments();
    return snapshot.documents.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore.collection("takipedilenler").document(kullaniciId).collection("kullanicininTakipleri").getDocuments();
    return snapshot.documents.length;
  }

  void duyuruEkle({String aktiviteYapanId, String profilSahibiId, String aktiviteTipi, String yorum, Gonderi gonderi}){

    if(aktiviteYapanId == profilSahibiId){
      return;
    }

    _firestore.collection("duyurular").document(profilSahibiId).collection("kullanicininDuyurulari").add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderiResmiUrl,
      "yorum": yorum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String profilSahibiId) async {
    QuerySnapshot snapshot = await _firestore.collection("duyurular").document(profilSahibiId).collection("kullanicininDuyurulari").orderBy("olusturulmaZamani", descending: true).limit(20).getDocuments();
    
    List<Duyuru> duyurular = [];

    snapshot.documents.forEach((DocumentSnapshot doc) { 
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });

    return duyurular;
  
  }

  Future<void> gonderiOlustur({gonderiResmiUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore.collection("gonderiler").document(yayinlayanId).collection("kullaniciGonderileri").add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore.collection("gonderiler").document(kullaniciId).collection("kullaniciGonderileri").orderBy("olusturulmaZamani", descending: true).getDocuments();
    List<Gonderi> gonderiler = snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<List<Gonderi>> akisGonderileriniGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore.collection("akislar").document(kullaniciId).collection("kullaniciAkisGonderileri").orderBy("olusturulmaZamani", descending: true).getDocuments();
    List<Gonderi> gonderiler = snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiSil({String aktifKullaniciId, Gonderi gonderi}) async {
    _firestore.collection("gonderiler").document(aktifKullaniciId).collection("kullaniciGonderileri").document(gonderi.id).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    //Gönderiye ait yorumları siliyoruz
    QuerySnapshot yorumlarSnapshot = await _firestore.collection("yorumlar").document(gonderi.id).collection("gonderiYorumlari").getDocuments();
    yorumlarSnapshot.documents.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
     });

     //Silinen gönderiyle ilgili duyuruları silelim
     QuerySnapshot duyurularSnapshot = await _firestore.collection("duyurular").document(gonderi.yayinlayanId).collection("kullanicininDuyurulari").where("gonderiId", isEqualTo: gonderi.id).getDocuments();
     duyurularSnapshot.documents.forEach((DocumentSnapshot doc) {
      if(doc.exists){
        doc.reference.delete();
      }
     }); 

     //Storage servisinden gönderi resmini sil
     StorageServisi().gonderiResmiSil(gonderi.gonderiResmiUrl);
     
  }

  Future<Gonderi> tekliGonderiGetir(String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore.collection("gonderiler").document(gonderiSahibiId).collection("kullaniciGonderileri").document(gonderiId).get();
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore.collection("gonderiler").document(gonderi.yayinlayanId).collection("kullaniciGonderileri").document(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    if(doc.exists){
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;
      docRef.updateData({
        "begeniSayisi": yeniBegeniSayisi
      });

      //Kullanıcı-Gönderi İlişkisini Beğeniler Koleksiyonuna Ekle
      _firestore.collection("begeniler").document(gonderi.id).collection("gonderiBegenileri").document(aktifKullaniciId).setData({});

      //Beğeni haberini gönderi sahibine iletiyoruz.
      duyuruEkle(
        aktiviteTipi: "begeni",
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId
      );
    }
  }

  Future<void> gonderiBegeniKaldir(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore.collection("gonderiler").document(gonderi.yayinlayanId).collection("kullaniciGonderileri").document(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    if(doc.exists){
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;
      docRef.updateData({
        "begeniSayisi": yeniBegeniSayisi
      });

      //Kullanıcı-Gönderi İlişkisini Beğeniler Koleksiyonundan Sil
      DocumentSnapshot docBegeni = await _firestore.collection("begeniler").document(gonderi.id).collection("gonderiBegenileri").document(aktifKullaniciId).get();

      if(docBegeni.exists){
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarmi(Gonderi gonderi, String aktifKullaniciId) async {

    DocumentSnapshot docBegeni = await _firestore.collection("begeniler").document(gonderi.id).collection("gonderiBegenileri").document(aktifKullaniciId).get();

    if(docBegeni.exists){
      return true;
    }

    return false;

  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId){
    return _firestore.collection("yorumlar").document(gonderiId).collection("gonderiYorumlari").orderBy("olusturulmaZamani", descending: true).snapshots();
  }

  void yorumEkle({String aktifKullaniciId, Gonderi gonderi, String icerik}){
    _firestore.collection("yorumlar").document(gonderi.id).collection("gonderiYorumlari").add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });

    //Yorum duyurusunu gönderi sahibine iletiyoruz.
    duyuruEkle(
      aktiviteTipi: "yorum",
      aktiviteYapanId: aktifKullaniciId,
      gonderi: gonderi,
      profilSahibiId: gonderi.yayinlayanId,
      yorum: icerik
    );

  }

}