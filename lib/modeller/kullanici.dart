import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Kullanici {
  
  final String id;
  final String kullaniciAdi;
  final String fotoUrl;
  final String email;
  final String hakkinda;

  Kullanici({@required this.id, this.kullaniciAdi, this.fotoUrl, this.email,  this.hakkinda});


  factory Kullanici.firebasedenUret(FirebaseUser kullanici) {
    return Kullanici(
      id: kullanici.uid,
      kullaniciAdi: kullanici.displayName,
      fotoUrl: kullanici.photoUrl,
      email: kullanici.email,
    );
  }


  factory Kullanici.dokumandanUret(DocumentSnapshot doc) {
    return Kullanici(
      id : doc.documentID,
      kullaniciAdi: doc['kullaniciAdi'],
      email: doc['email'],
      fotoUrl: doc['fotoUrl'],
      hakkinda: doc['hakkinda'],
    );
  }


}