import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/akis.dart';
import 'package:socialapp/sayfalar/duyurular.dart';
import 'package:socialapp/sayfalar/kesfet.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yukle.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class AnaSayfa extends StatefulWidget {


  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _aktifSayfaNo = 0;
  PageController pageViewController;

  @override
  void initState() {
    super.initState();

    pageViewController = PageController();
    
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {

    String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;

    return Scaffold(
      body: PageView(
        controller: pageViewController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (sayfa){
          setState(() {
            _aktifSayfaNo = sayfa;
          });
        },
        children: <Widget>[
        Akis(),
        Kesfet(),
        Yukle(),
        Duyurular(),
        Profil(profilSahibiId: aktifKullaniciId,aktifKullaniciId: aktifKullaniciId)
        ],
      ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aktifSayfaNo,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
              title: Text("Akış"), 
              icon: Icon(Icons.home)
          ),

          BottomNavigationBarItem(
              title: Text("Keşfet"), 
              icon: Icon(Icons.explore)
          ),

          BottomNavigationBarItem(
              title: Text("Yükle"), 
              icon: Icon(Icons.file_upload)
          ),

          BottomNavigationBarItem(
              title: Text("Duyurular"), 
              icon: Icon(Icons.notifications)
          ),

          BottomNavigationBarItem(
              title: Text("Profil"), 
              icon: Icon(Icons.person)
          ),       
              
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
           pageViewController.jumpToPage(secilenSayfaNo);
        });
        },
      ),
    );
  }
}
