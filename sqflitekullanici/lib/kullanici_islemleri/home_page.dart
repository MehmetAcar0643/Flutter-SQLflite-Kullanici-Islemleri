import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflitekullanici/model/kullanici.dart';
import 'package:sqflitekullanici/util/database_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper _databaseHelper;
  List<Kullanici> tumKullanicilar;
  bool _kullaniciDurum = false;
  var _formKey = GlobalKey<FormState>();
  var _controllerAd = TextEditingController();
  var _controllerSoyAd = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKullanicilar = List<Kullanici>();
    _databaseHelper = DatabaseHelper();
    _databaseHelper.kullanicilariListele().then((tumKullanicilarMapListesi) {
      for (Map okunanKullaniciMapi in tumKullanicilarMapListesi) {
        tumKullanicilar.add(Kullanici.dbdenOkudugunMapiObjeyeDonustur(okunanKullaniciMapi));
      }
    }).catchError((hata) => print("hata:" + hata));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kullanıcılar"),
      ),
      body: Container(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controllerAd,
                      validator: (kontrolEdilecekAdDegeri) {
                        if (kontrolEdilecekAdDegeri.length < 3) {
                          return "En az 3 Karakter";
                        } else
                          return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Kullanıcı adı giriniz...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _controllerSoyAd,
                      validator: (kontrolEdilecekSoyAdDegeri) {
                        if (kontrolEdilecekSoyAdDegeri.length < 2) {
                          return "En az 2 Karakter";
                        } else
                          return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Kullanıcı soyadı giriniz...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      title: Text("Durumu? Aktif/Pasif"),
                      value: _kullaniciDurum,
                      onChanged: (aktifMi) {
                        setState(() {
                          _kullaniciDurum = aktifMi;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  child: Text("Ekle"),
                  color: Colors.blueAccent,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _kullaniciEkle(
                          Kullanici(_controllerAd.text, _controllerSoyAd.text, _kullaniciDurum == true ? 1 : 0));
                    }
                  },
                ),
                RaisedButton(
                  child: Text("Güncelle"),
                  color: Colors.green,
                  onPressed: () {},
                ),
                RaisedButton(
                  child: Text("Kullanıcıları Temizle"),
                  color: Colors.red,
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tumKullanicilar.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: tumKullanicilar[index].durum == 1 ? Colors.blue.shade500 : Colors.red.shade500,
                    child: ListTile(
                      title: Text(tumKullanicilar[index].ad + " " + tumKullanicilar[index].soyad),
                      subtitle: Text(tumKullanicilar[index].durum == 1 ? "AKTİF" : "PASİF"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _kullaniciEkle(Kullanici kullanici)async {
    var eklenenKullanici=await _databaseHelper.kullaniciEkle(kullanici);
    kullanici.id=eklenenKullanici;
    if(eklenenKullanici>0){
      setState(() {
        tumKullanicilar.insert(0, kullanici);
      });
    }
  }
}
