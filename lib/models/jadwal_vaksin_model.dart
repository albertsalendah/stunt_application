// ignore_for_file: non_constant_identifier_names

/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
class JadwalVaksinModel {
  int? id;
  String? id_anak;
  String? userID;
  String? lokasi;
  String? tanggalvaksin;
  String? tipevaksin;

  JadwalVaksinModel(
      {this.id,
      this.id_anak,
      this.userID,
      this.lokasi,
      this.tanggalvaksin,
      this.tipevaksin});

  JadwalVaksinModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    id_anak = json['id_anak'];
    userID = json['userID'];
    lokasi = json['lokasi'];
    tanggalvaksin = json['tanggal_vaksin'];
    tipevaksin = json['tipe_vaksin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_anak'] = id_anak;
    data['userID'] = userID;
    data['lokasi'] = lokasi;
    data['tanggal_vaksin'] = tanggalvaksin;
    data['tipe_vaksin'] = tipevaksin;
    return data;
  }
}
