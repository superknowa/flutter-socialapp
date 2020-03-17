const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();



exports.takipGerceklesti = functions.firestore
  .document("takipciler/{kullaniciId}/kullanicininTakipcileri/{takipciId}")
  .onCreate(async (snapshot, context) => {

    const kullaniciId = context.params.kullaniciId;
    const takipciId = context.params.takipciId;

    //Takip edilen kullanıcının gönderilerini getirelim
    const gonderilerSnapshot = await admin.firestore().collection("gonderiler").doc(kullaniciId).collection("kullaniciGonderileri").get();

    //Burda kullandığımız dil javascript olduğu için yazım farklılıkları var. Kafanızı karıştırmasın. 
    //foeach metodu ile her bir dökümana tek tek ulaşıcam ve takip edenin akış koleksiyonuna eklicem.
    gonderilerSnapshot.forEach(doc => {

      if (doc.exists) {
        const gonderiId = doc.id;
        const gonderiData = doc.data();
        admin.firestore().collection("akis").doc(takipciId).collection("kullaniciAkis").doc(gonderiId).set(gonderiData);
      }

    });


  });


exports.takiptenCikildi = functions.firestore
  .document("takipciler/{kullaniciId}/kullanicininTakipcileri/{takipciId}")
  .onDelete(async (snapshot, context) => {

    const kullaniciId = context.params.kullaniciId;
    const takipciId = context.params.takipciId;

    //
    const takiptEdilenGonderilerSnapshot = await admin.firestore().collection("akis").doc(takipciId).collection("kullaniciAkis").where("yayinlayanId", "==", kullaniciId).get();

    //foeach metodu ile her bir dökümana tek tek ulaşıcam ve takip edenin akış koleksiyonuna eklicem.
    takiptEdilenGonderilerSnapshot.forEach(doc => {

      if (doc.exists) {
        doc.ref.delete();
      }

    });


  });


  exports.yeniGonderiEklendi = functions.firestore
  .document("gonderiler/{kullaniciId}/kullaniciGonderileri/{gonderiId}")
  .onCreate(async (snapshot, context) => {

    //Adresteki bilgileri değişkenlere aldık.
    const kullaniciId = context.params.kullaniciId;
    const gonderiId = context.params.gonderiId;
    const eklenenKayit = snapshot.data();
    
    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(kullaniciId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(doc=>{
      const takipciId = doc.id;
      admin.firestore().collection("akis").doc(takipciId).collection("kullaniciAkis").doc(gonderiId).set(eklenenKayit);

    });


  });


  exports.gonderiGuncellendi = functions.firestore
  .document("gonderiler/{kullaniciId}/kullaniciGonderileri/{gonderiId}")
  .onUpdate(async (snapshot, context) => {

    //Adresteki bilgileri değişkenlere aldık.
    const kullaniciId = context.params.kullaniciId;
    const gonderiId = context.params.gonderiId;
    const guncellenmisGonderi = snapshot.after.data();
    

    //console.log("Açıklama: " + guncellenmisGonderi.aciklama);
    //const guncellenmemisGonderi = snapshot.before.data();
    
    
    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(kullaniciId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(async takipciDoc=>{
      const takipciId = takipciDoc.id;
      const akisDoc = await admin.firestore().collection("akis").doc(takipciId).collection("kullaniciAkis").doc(gonderiId).get();
      if(akisDoc.exists){
        akisDoc.ref.update(guncellenmisGonderi);
      }

    });


  });


  exports.gonderiSilindi= functions.firestore
  .document("gonderiler/{kullaniciId}/kullaniciGonderileri/{gonderiId}")
  .onDelete(async (snapshot, context) => {

    
    const kullaniciId = context.params.kullaniciId;
    const gonderiId = context.params.gonderiId;
    
    
    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(kullaniciId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(async takipciDoc=>{
      const takipciId = takipciDoc.id;
      const akisDoc = await admin.firestore().collection("akis").doc(takipciId).collection("kullaniciAkis").doc(gonderiId).get();
      if(akisDoc.exists){
        akisDoc.ref.delete();
      }

    });


  });

