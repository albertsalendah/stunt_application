/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
class DataTabelStatusGizi {
  int? id;
  double? umur_panjang_tinggi;
  double? m3SD;
  double? m2SD;
  double? m1SD;
  double? median;
  double? p1SD;
  double? p2SD;
  double? p3SD;

  DataTabelStatusGizi(
      {this.id,
      this.umur_panjang_tinggi,
      this.m3SD,
      this.m2SD,
      this.m1SD,
      this.median,
      this.p1SD,
      this.p2SD,
      this.p3SD});

  DataTabelStatusGizi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    umur_panjang_tinggi = double.tryParse(json['panjang_badan'].toString()) ??
        double.tryParse(json['tinggi_badan'].toString()) ??
        double.tryParse(json['umur'].toString());
    m3SD = double.tryParse(json['-3 SD'].toString());
    m2SD = double.tryParse(json['-2 SD'].toString());
    m1SD = double.tryParse(json['-1 SD'].toString());
    median = double.tryParse(json['Median'].toString());
    p1SD = double.tryParse(json['1 SD'].toString());
    p2SD = double.tryParse(json['2 SD'].toString());
    p3SD = double.tryParse(json['3 SD'].toString());
  }
}
