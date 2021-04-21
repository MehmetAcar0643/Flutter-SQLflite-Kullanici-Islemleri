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
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var tiklanilanKullaniciIndexi;
  var tiklanilanKullaniciId;

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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
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
                        _kullaniciEkle(Kullanici(
                            _controllerAd.text, _controllerSoyAd.text, _kullaniciDurum == true ? 1 : 0));
                      }
                    },
                  ),
                  RaisedButton(
                    child: Text("Güncelle"),
                    color: Colors.green,
                    onPressed: tiklanilanKullaniciId == null
                        ? null
                        : () {
                            if (_formKey.currentState.validate()) {
                              _kullaniciGuncelle(Kullanici.withID(tiklanilanKullaniciId, _controllerAd.text,
                                  _controllerSoyAd.text, _kullaniciDurum == true ? 1 : 0));
                            }
                          },
                  ),
                  RaisedButton(
                    child: Text("Kullanıcıları Temizle"),
                    color: Colors.red,
                    onPressed: tumKullanicilar.length <= 0
                        ? null
                        : () {
                            _kullanicilariTemizle();
                          },
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
                        onTap: () {
                          setState(() {
                            _controllerAd.text = tumKullanicilar[index].ad;
                            _controllerSoyAd.text = tumKullanicilar[index].soyad;
                            _kullaniciDurum = tumKullanicilar[index].durum == 1 ? true : false;
                            tiklanilanKullaniciId = tumKullanicilar[index].id;
                            tiklanilanKullaniciIndexi = index;
                          });
                        },
                        title: Text(tumKullanicilar[index].ad + " " + tumKullanicilar[index].soyad),
                        subtitle: Text(tumKullanicilar[index].durum == 1 ? "AKTİF" : "PASİF"),
                        trailing: GestureDetector(
                          child: Icon(Icons.delete),
                          onTap: () {
                            _kullaniciSil(tumKullanicilar[index].id, index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _kullaniciEkle(Kullanici kullanici) async {
    var eklenenKullanici = await _databaseHelper.kullaniciEkle(kullanici);
    kullanici.id = eklenenKullanici;
    if (eklenenKullanici > 0) {
      setState(() {
        tumKullanicilar.insert(0, kullanici);
      });
      tiklanilanKullaniciId = null;
      _inputveDigerAlanlariTemizle();
      _klavyeKapat();
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text("Kullanıcı Ekleme Sırasında Bir Sorun Oluştu!!!"),
      ));
    }
  }

  void _kullanicilariTemizle() async {
    var silinenKullaniciSayisi = await _databaseHelper.tumKullanicilariSil();
    if (silinenKullaniciSayisi > 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text(silinenKullaniciSayisi.toString() + " Kullanıcı Silindi..."),
      ));
      setState(() {
        tumKullanicilar.clear();
      });
      _inputveDigerAlanlariTemizle();
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text("Kullanıcıları Silme Sırasında Bir Sorun Oluştu!!!"),
      ));
    }
  }

  void _kullaniciSil(int id, int index) async {
    var sonuc = await _databaseHelper.kullaniciSil(id);
    if (sonuc > 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text("Kullanıcı silindi..."),
      ));
      setState(() {
        tumKullanicilar.removeAt(index);
      });
      _inputveDigerAlanlariTemizle();
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text("Kayıt Silme Sırasında Bir Sorun Oluştu!!!"),
      ));
    }
  }

  void _kullaniciGuncelle(Kullanici kullanici) async {
    var sonuc = await _databaseHelper.kullaniciGuncelle(kullanici);
    if (sonuc == 1) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text("Kullanıcı Güncellendi"),
      ));
      setState(() {
        tumKullanicilar[tiklanilanKullaniciIndexi] = kullanici;
      });
      _inputveDigerAlanlariTemizle();
      _klavyeKapat();
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text("Güncelleme Sırasında Bir Sorun Oluştu!!!"),
      ));
    }
  }

  void _inputveDigerAlanlariTemizle() {
    _controllerAd.clear();
    _controllerSoyAd.clear();
    _kullaniciDurum = false;
    tiklanilanKullaniciId = null;
  }

  void _klavyeKapat() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
