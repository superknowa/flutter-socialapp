const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.takipGerceklesti = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onCreate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenId;
    const takipEdenId = context.params.takipEdenKullaniciId;

   const gonderilerSnapshot = await admin.firestore().collection("gonderiler").doc(takipEdilenId).collection("kullaniciGonderileri").get();

   gonderilerSnapshot.forEach((doc)=>{
        if(doc.exists){
            const gonderiId = doc.id;
            const gonderiData = doc.data();

            admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(gonderiData);
        }
   });
});

exports.takiptenCikildi = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onDelete(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenId;
    const takipEdenId = context.params.takipEdenKullaniciId;

   const gonderilerSnapshot = await admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").where("yayinlayanId", "==", takipEdilenId).get();

   gonderilerSnapshot.forEach((doc)=>{
        if(doc.exists){
            doc.ref.delete();
        }
   });
});

exports.yeniGonderiEklendi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri/{gonderiId}').onCreate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const yeniGonderiData = snapshot.data();

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(yeniGonderiData);
    });
});

exports.gonderiGuncellendi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri/{gonderiId}').onUpdate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const guncellenmisGonderiData = snapshot.after.data();

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).update(guncellenmisGonderiData);
    });
});

exports.gonderiSilindi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri/{gonderiId}').onDelete(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).delete();
    });
});

/*
exports.kayitSilindi = functions.firestore.document('deneme/{docId}').onDelete((snapshot, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonundan kayıt silindi."
    });
});

exports.kayitGuncellendi = functions.firestore.document('deneme/{docId}').onUpdate((change, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonunda kayıt güncellendi."
    });
});

exports.yazmaGerceklesti = functions.firestore.document('deneme/{docId}').onWrite((change, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonunda veri ekleme, silme, güncelleme işlemlerinden biri gerçekleşti."
    });
});
*/

