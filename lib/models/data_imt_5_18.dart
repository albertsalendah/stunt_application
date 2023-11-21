/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
class DataIMT {
  int? id;
  int? tahun;
  int? bulan;
  double? m3SD;
  double? m2SD;
  double? m1SD;
  double? median;
  double? p1SD;
  double? p2SD;
  double? p3SD;

  DataIMT(
      {this.id,
      this.tahun,
      this.bulan,
      this.m3SD,
      this.m2SD,
      this.m1SD,
      this.median,
      this.p1SD,
      this.p2SD,
      this.p3SD});

  DataIMT.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tahun = json['tahun'];
    bulan = json['bulan'];
    m3SD = double.tryParse(json['-3 SD'].toString());
    m2SD = double.tryParse(json['-2 SD'].toString());
    m1SD = double.tryParse(json['-1 SD'].toString());
    median = double.tryParse(json['median'].toString());
    p1SD = double.tryParse(json['1 SD'].toString());
    p2SD = double.tryParse(json['2 SD'].toString());
    p3SD = double.tryParse(json['3 SD'].toString());
  }
}
