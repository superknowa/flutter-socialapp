import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/modeller/kullanici.dart';

class YetkilendirmeServisi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String aktifKullaniciId;

  //Bunu private yaptım çünkü dışarıdan çağırılmayacak sadece sınıf elemanları kullanacak.
  Kullanici _kullaniciOlustur(FirebaseUser kullanici) {
    return kullanici == null ? null : Kullanici.firebasedenUret(kullanici);
  }

  Future<Kullanici> aktifKullanici() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return _kullaniciOlustur(user);
  }

  Future<Kullanici> mailIleGiris(String eposta, String sifre) async {
    final girisSonucu = await _firebaseAuth.signInWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(girisSonucu.user);
  }

  Future<Kullanici> mailIleKayit(String eposta, String sifre) async {
    final girisSonucu = await _firebaseAuth.createUserWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(girisSonucu.user);
  }

  Stream<Kullanici> get durumTakipcisi {
    return _firebaseAuth.onAuthStateChanged.map(_kullaniciOlustur);
  }

  Future<void> cikisYap() async {
    return _firebaseAuth.signOut();
  }

  Future<Kullanici> googleIleGiris() async {
    GoogleSignInAccount googleHesabi = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleYetkiKartim =
        await googleHesabi.authentication;

    AuthCredential authGirisKarti = GoogleAuthProvider.getCredential(
      accessToken: googleYetkiKartim.accessToken,
      idToken: googleYetkiKartim.idToken,
    );

    AuthResult girisSonucu =
        await FirebaseAuth.instance.signInWithCredential(authGirisKarti);

    return _kullaniciOlustur(girisSonucu.user);

  }


  Future<void> sifremiSifirla(String eposta) async {
    return await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }





}
