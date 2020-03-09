import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profiliduzenle.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/widgetlar/gonderikarti.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;
  final String aktifKullaniciId;

  Profil({this.profilSahibiId, this.aktifKullaniciId});

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0; //Tüm global değişkenleri alt çizgili yapalım.
  int _takipci = 0;
  int _takipEdilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  Kullanici _profilSahibi;
  bool _takipEdildi = false;

  _takipciSayisiGetir() async {
    final takipciSayisi =
        await FireStoreServisi().takipciSayisi(widget.profilSahibiId);

    if (mounted) {    
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    final takipEdilenSayisi =
        await FireStoreServisi().takipEdileniSayisi(widget.profilSahibiId);

    if (mounted) {     
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FireStoreServisi().gonderileriGetir(widget.profilSahibiId);
    print("Gönderi sayısı: ${gonderiler.length}");

    if (mounted) { 
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = _gonderiler.length;
      });
    }
  }

  _takipKontrol() async {
    bool takipVarMi = await FireStoreServisi().takipKontrol(aktifKullaniciId: widget.aktifKullaniciId,profilSahibiId: widget.profilSahibiId);
    setState(() {
      _takipEdildi = takipVarMi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
    _takipKontrol();
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 50.0,
                  backgroundImage: profilData.fotoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(profilData.fotoUrl)
                      : AssetImage("assets/male.png")),
              Expanded(
                  child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _profilSayac(baslik: "Gönderiler", sayi: _gonderiSayisi),
                      _profilSayac(baslik: "Takipçi", sayi: _takipci),
                      _profilSayac(baslik: "Takip", sayi: _takipEdilen),
                    ],
                  )
                ],
              ))
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                profilData.kullaniciAdi,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 5.0,
          ),
          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                profilData.hakkinda,
              )),
          SizedBox(
            height: 25.0,
          ),
          _profilButon()
        ],
      ),
    );
  }

  Widget _profilButon() {
    return widget.profilSahibiId == widget.aktifKullaniciId ? _profiliDuzenleButon() : _takipEtButon();
  }



  Widget _takipEtButon() { 
    
    return _takipEdildi ? takiptenCikButon() : takipEtButon();

  }

  takiptenCikButon(){
    return GestureDetector(
      onTap: (){
        FireStoreServisi().takiptenCik(profilSahibiId: widget.profilSahibiId,aktifKullaniciId: widget.aktifKullaniciId);
        setState(() {
          _takipci = _takipci - 1;
          _takipEdildi = false;
        });
      },
          child: Container(
        alignment: Alignment.center,
        height: 34.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(width: 1.0, color: Colors.grey[300]),
          color: Colors.white54,
        ),
        child: Text(
          "Takipten Çık",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
  ),
    );
  }

  takipEtButon(){
    return GestureDetector(
      onTap: (){
        setState(() {
          _takipEdildi = true;
          _takipci = _takipci + 1;
        });
        FireStoreServisi().takipEt(profilSahibiId: widget.profilSahibiId,aktifKullaniciId: widget.aktifKullaniciId);
      },
          child: Container(
        alignment: Alignment.center,
        height: 34.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(width: 1.0, color: Colors.grey[300]),
          color: Theme.of(context).primaryColor,
        ),
        child: Text(
          "Takip Et",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
  ),
    );
  }

  Widget _profiliDuzenleButon() {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfiliDuzenle(profil: _profilSahibi,)));
      },
          child: Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 34.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(width: 1.0, color: Colors.grey[300]),
        color: Colors.white54,
      ),
      child: Text(
        "Profili Düzenle",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
  ),
    );
  }

  Widget _profilSayac({String baslik, int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.0),
        Text(
          baslik,
          style: TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {

    if(gonderiStili == "liste"){

      return ListView.builder(
        shrinkWrap: true, //Anlat
        primary: false, //Primary anlat
        itemCount: _gonderiler.length,
        itemBuilder: (context, index){
          return GonderiKart(yayinlayan: profilData ,gonderi:_gonderiler[index]);
        }
        );

    } else {


      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi){

        fayanslar.add(_fayansOlustur(gonderi));

      });
      
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        childAspectRatio: 1.0,
        physics: NeverScrollableScrollPhysics(),
        children: fayanslar,
      );


  }


  }

  GridTile _fayansOlustur(gonderi){
    
    return GridTile(
            child: Image(
          image: CachedNetworkImageProvider(gonderi.gonderResimiUrl),
          fit: BoxFit.cover,
        ),
    );
  
  }

  cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profil",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,), onPressed: ()=>Navigator.pop(context)),
          backgroundColor: Colors.grey[100],
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.black,
                ),
                onPressed: cikisYap)
          ],
        ),
        body: FutureBuilder<Kullanici>(
            //Editör tamamlama yapabilsin diye Kullanici tipini tanımladım.
            future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
            builder: (context, snapshot) {
              
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              _profilSahibi = snapshot.data;
              
              return ListView(
                children: <Widget>[
                  _profilDetaylari(snapshot.data),
                  _gonderileriGoster(snapshot.data),
                ],
              );
            }));
  }
}
