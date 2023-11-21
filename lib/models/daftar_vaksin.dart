/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
class DaftarVaksinModel {
  int? id;
  int? umurmulai;
  int? umurselesai;
  String? namavaksin;
  String? keterangan;

  DaftarVaksinModel(
      {this.id,
      this.umurmulai,
      this.umurselesai,
      this.namavaksin,
      this.keterangan});

  DaftarVaksinModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    umurmulai = json['umur_mulai'];
    umurselesai = json['umur_selesai'];
    namavaksin = json['nama_vaksin'];
    keterangan = json['keterangan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['umur_mulai'] = umurmulai;
    data['umur_selesai'] = umurselesai;
    data['nama_vaksin'] = namavaksin;
    data['keterangan'] = keterangan;
    return data;
  }
}
