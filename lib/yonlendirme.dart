import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/anasayfa.dart';
import 'package:socialapp/sayfalar/girissayfasi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final _yetkilendirmeServisi = Provider.of<YetkilendirmeServisi>(context, listen: false);

    return StreamBuilder(
        stream: _yetkilendirmeServisi.durumTakipcisi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            Kullanici kullanici = snapshot.data;
            
            //Kullanıcı idsine program içinde heryerden ulaşabilmemi sağlar.
            _yetkilendirmeServisi.aktifKullaniciId = kullanici.id;

            return AnaSayfa(aktifKullanici: kullanici,);
          } else {
            return GirisSayfasi();
          }
        });
  }
}
