const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();



exports.takipGerceklesti  = functions.firestore
  .document("takipciler/{kullaniciId}/kullanicininTakipcileri/{takipciId}")
  .onCreate(async (snapshot, context) => {
    
    const kullaniciId = context.params.kullaniciId;
    const takipciId = context.params.takipciId;

    //Takip edilen kullanıcının gönderilerini getirelim
    const gonderilerSnapshot = await admin.firestore().collection("gonderiler").doc(kullaniciId).collection("kullaniciGonderileri").get();
    
    //Burda kullandığımız dil javascript olduğu için yazım farklılıkları var. Kafanızı karıştırmasın. 
    //foeach metodu ile her bir dökümana tek tek ulaşıcam ve takip edenin akış koleksiyonuna eklicem.
    gonderilerSnapshot.forEach(doc=>{

        if(doc.exists){
            admin.firestore().collection("akis").doc(takipciId).collection("kullaniciAkis").doc(doc.id).set(doc.data());
        }

    });

    
  });


  exports.takiptenCikildi  = functions.firestore
  .document("takipciler/{kullaniciId}/kullanicininTakipcileri/{takipciId}")
  .onDelete(async (snapshot, context) => {
    
    const kullaniciId = context.params.kullaniciId;
    const takipciId = context.params.takipciId;

    //
    const takiptEdilenGonderilerSnapshot = await admin.firestore().collection("akis").doc(takipciId).collection("kullaniciAkis").where("yayinlayanId", "==", kullaniciId).get();
     
    //foeach metodu ile her bir dökümana tek tek ulaşıcam ve takip edenin akış koleksiyonuna eklicem.
    takiptEdilenGonderilerSnapshot.forEach(doc=>{

        if(doc.exists){
            doc.ref.delete();
        }

    });

    
  });

