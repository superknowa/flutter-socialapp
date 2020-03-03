import 'package:flutter/material.dart';
import 'package:socialapp/modeller/gonderi.dart';

class GonderiKart extends StatefulWidget {

  final Gonderi gonderi;

  const GonderiKart({this.gonderi});

  @override
  _GonderiKartState createState() => _GonderiKartState();
}

class _GonderiKartState extends State<GonderiKart> {


  gonderiBasligi(){

   return ListTile(
     leading: CircleAvatar(backgroundColor: Colors.blue,),
     title: Text("Kullanıcı Adı",style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),),
     trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: (){}),
   );

  }

  gonderiResmi(){
    return Container(
      height: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.blue
      ),
    );
  }

  gonderiAlt(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,//Sonda ekle beğeni yazısının sola kaydığı görülsün.
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(icon: Icon(Icons.favorite_border,size: 35.0,), onPressed: null,),
            IconButton(icon: Icon(Icons.comment,size: 35.0,), onPressed: null,)
          ],
        ),
        Text("100 beğen,")

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        gonderiBasligi(),
        gonderiResmi(),
        gonderiAlt(),
        SizedBox(height: 10.0,)
      ],
    );
  }
}