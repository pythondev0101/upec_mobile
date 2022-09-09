
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upec_mobile/models/user_model.dart';

class UserService {
  static void saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(user.userId);
    prefs.setString('userID', user.userId.toString());
    prefs.setString('username', user.username!);
    prefs.setString('fname', user.fname!);
    prefs.setString('lname', user.lname!);
    prefs.setString('email', user.email!);
    prefs.setString('type', user.type!);
  }

  static Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var storedUserId = prefs.getString('userID');
    var mongoId;
    if(storedUserId != null){
      mongoId = ObjectId.fromHexString(storedUserId);
    }

    return User(
      mongoId: mongoId,
      username: prefs.getString('username'),
      fname: prefs.getString('fname'),
      lname: prefs.getString('name'),
      email: prefs.getString('email'),
      phone: prefs.getString('phone'),
      type: prefs.getString('type'),
    );
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('userID');
    prefs.remove('username');
    prefs.remove('fname');
    prefs.remove('lname');
    prefs.remove('email');
    prefs.remove('phone');
    prefs.remove('type');
  }
}