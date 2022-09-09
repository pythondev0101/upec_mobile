import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId? mongoId;
  String? username;
  String? fname;
  String? lname;
  String? mname;
  String? email;
  String? phone;
  String? tfoeNo;
  String? address;
  String? batch;
  String? type;

  User({
    this.mongoId,
    this.username,
    this.fname,
    this.lname,
    this.mname,
    this.email,
    this.phone,
    this.tfoeNo,
    this.address,
    this.batch,
    this.type='member'
  });

  factory User.fromJson(Map<String, dynamic> data) {
    var userId = data['_id'];
    ObjectId? mongoId;
    if(userId != null){
      if(userId is String){
        mongoId = ObjectId.fromHexString(userId);
      } else{
        mongoId = ObjectId.fromHexString(userId.toHexString());
      }
    }

    return User(
      mongoId: mongoId,
      username: data['username'] ?? '',
      fname: data['fname'] ?? '',
      lname: data['lname'] ?? '',
      mname: data['mname'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      tfoeNo: data['tfoe_no'] ?? '',
      address: data['address'] ?? '',
      batch: data['batch'] ?? '',
      type: data['type'] ?? 'member'
    );
  }

  String get userId => mongoId!.toHexString();
}
