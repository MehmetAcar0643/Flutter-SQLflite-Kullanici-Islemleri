class Kullanici {
  int _id;
  String _ad;
  String _soyad;
  int _durum;

  Kullanici.withID(this._id, this._ad, this._soyad, this._durum);

  Kullanici(this._ad, this._soyad, this._durum);

  int get durum => _durum;

  set durum(int value) {
    _durum = value;
  }

  String get soyad => _soyad;

  set soyad(String value) {
    _soyad = value;
  }

  String get ad => _ad;

  set ad(String value) {
    _ad = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  Map<String, dynamic> dbyeYazmakIcinMapeDonustur() {
    var map = Map<String, dynamic>();
    map['id'] = _id;
    map['ad'] = _ad;
    map['soyad'] = _soyad;
    map['durum'] = _durum;
    return map;
  }

  Kullanici.dbdenOkudugunMapiObjeyeDonustur(Map<String, dynamic>map){
    this._id = map['id'];
    this._ad = map['ad'];
    this._soyad = map['soyad'];
    this._durum = map['durum'];
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Kullanici.(_id: $_id, _ad: $ad, _soyad: $soyad, _durum: $durum)';
  }
}