// ignore_for_file: non_constant_identifier_names

/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
class DataAnakModel {
  String? id_anak;
  String? userID;
  String? namaanak;
  String? jeniskelamin;
  String? tanggallahir;
  String? beratbadan;
  String? tinggibadan;
  String? lingkarkepala;
  String? pengukuranTerakhir;

  DataAnakModel(
      {this.id_anak,
      this.userID,
      this.namaanak,
      this.jeniskelamin,
      this.tanggallahir,
      this.beratbadan,
      this.tinggibadan,
      this.lingkarkepala,
      this.pengukuranTerakhir});

  DataAnakModel.fromJson(Map<String, dynamic> json) {
    id_anak = json['id_anak'];
    userID = json['userID'];
    namaanak = json['nama_anak'];
    jeniskelamin = json['jenis_kelamin'];
    tanggallahir = json['tanggal_lahir'];
    beratbadan = json['berat_badan'].toString();
    tinggibadan = json['tinggi_badan'].toString();
    lingkarkepala = json['lingkar_kepala'].toString();
    pengukuranTerakhir = json['pengukuran_terakhir'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_anak'] = id_anak;
    data['userID'] = userID;
    data['nama_anak'] = namaanak;
    data['jenis_kelamin'] = jeniskelamin;
    data['tanggal_lahir'] = tanggallahir;
    data['berat_badan'] = beratbadan;
    data['tinggi_badan'] = tinggibadan;
    data['lingkar_kepala'] = lingkarkepala;
    data['pengukuran_terakhir'] = pengukuranTerakhir;
    return data;
  }
}
