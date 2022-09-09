import 'package:mongo_dart/mongo_dart.dart';
import 'package:intl/intl.dart';

class Event {
  ObjectId? mongoId;
  String? id;
  String name;
  String description;
  String address;
  DateTime? dateStart;
  DateTime? dateEnd;
  List<dynamic>? attendances;

  Event({
    this.mongoId,
    this.id,
    this.description='',
    this.dateStart,
    this.dateEnd,
    this.name='',
    this.address='',
    this.attendances,
  });

  factory Event.fromJson(Map<dynamic, dynamic> data){
    return Event(
      mongoId: data['_id'],
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      dateStart: data['date_start'],
      dateEnd: data['date_end'],
      attendances: data['attendances'] ?? []
    );
  }

  String get dateStartFormatted {
    return DateFormat.yMMMd('en_US').add_jm().format(dateStart!);
  }

  String get dateEndFormatted {
    return DateFormat.yMMMd('en_US').add_jm().format(dateEnd!);
  }
}


