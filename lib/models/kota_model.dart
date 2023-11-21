/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
class KotaModel {
    String? id;
    String? provinceid;
    String? name;
    String? provincename;

    KotaModel({this.id, this.provinceid, this.name, this.provincename}); 

    KotaModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        provinceid = json['province_id'];
        name = json['name'];
        provincename = json['province_name'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data['id'] = id;
        data['province_id'] = provinceid;
        data['name'] = name;
        data['province_name'] = provincename;
        return data;
    }
}

