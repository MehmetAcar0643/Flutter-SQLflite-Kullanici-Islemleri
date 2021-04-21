import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflitekullanici/model/kullanici.dart';

class DatabaseHelper {
  // BU SINIFTAN HERHANGİ BİR NESNE ÜRETMEDEN OLUŞTURMAK İÇİN STATİC YAPTIK
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String _kullaniciTablo = "kullanici";
  String _columnID = "id";
  String _columnAd = "ad";
  String _columnSoyad = "soyad";
  String _columnDurum = "durum";

// BELLİ BAŞLI KONTROLLER YAPIP ONA GÖRE DEĞER YOLLAYACAĞIMIZ İÇİN FACTORY KULLANIYORUZ
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      print("DatabaseHelper yoktu. Oluşturuldu.");
      return _databaseHelper;
    } else {
      print("Varolan DatabaseHelper kullanılıyor.");
      return _databaseHelper;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      print("Database yoktu.Oluşturulacak");
      _database = await _initializeDatabase();
      return _database;
    } else {
      print("Varolan Database kullanılıyor.");
      return _database;
    }
  }

  _initializeDatabase() async {
    // KLASÖRÜ ÇEK
    //"c://users/mehmet/"
    Directory klasor = await getApplicationDocumentsDirectory();
    //ÇEKİLEN KLASÖRÜN SONUNA EKLENECEK DOSYAYI KOY
    //"c://users/mehmet/ogrenci.db"
    String dbYol = join(klasor.path, "kullanici.db");
    print("Veritabanı Yolu: " + dbYol);

    //AÇILACAK VERİTABANI OLUŞTUR.
    var kullaniciDB = openDatabase(dbYol, version: 1, onCreate: _createDB);
    return kullaniciDB;
  }

//O AN OKUNMUŞ YERİ,YOLU BELLİ OLAN VERİTABANI ÜZERİNDEN TABLO OLUŞTURUYOR.
  FutureOr<void> _createDB(Database db, int version) async {
    print("Create db çalıştı,db tablosu oluşturulacak.");
    await db.execute("CREATE TABLE $_kullaniciTablo "
        "($_columnID INTEGER PRIMARY KEY AUTOINCREMENT,$_columnAd TEXT,$_columnSoyad TEXT,$_columnDurum INTEGER)");
  }

// VERİTABANI HAZIRLIĞI BİTTİ ARTIK VERİ EKLEMEDE
  Future<int> kullaniciEkle(Kullanici kullanici) async {
    var db = await _getDatabase();
    var sonuc = await db.insert(_kullaniciTablo, kullanici.dbyeYazmakIcinMapeDonustur(),
        nullColumnHack: "$_columnID");
    print("Kullanıcı EKLENDİ...");
    return sonuc;
  }

  Future<List<Map<String, dynamic>>> kullanicilariListele() async {
    var db = await _getDatabase();
    var sonuc = await db.query(_kullaniciTablo, orderBy: "$_columnID DESC");
    return sonuc;
  }

  Future<int> kullaniciGuncelle(Kullanici kullanici) async {
    var db = await _getDatabase();
    var sonuc = await db.update(_kullaniciTablo, kullanici.dbyeYazmakIcinMapeDonustur(),
        where: '$_columnID=?', whereArgs: [kullanici.id]);
    print(kullanici.id.toString() + " ID'li Kullanıcı GÜNCELLENDİ...");
    return sonuc;
  }

  Future<int> kullaniciSil(int id) async {
    var db = await _getDatabase();
    var sonuc = db.delete(_kullaniciTablo, where: '$_columnID=?', whereArgs: [id]);
    print(id.toString() + " ID'li Kullanıcı SİLİNDİ...");
    return sonuc;
  }

  tumKullanicilariSil() async {
    var db = await _getDatabase();
    var sonuc = await db.delete(_kullaniciTablo);
    print("Tüm Kullanıcılar SİLİNDİ...");
    return sonuc;
  }
}
