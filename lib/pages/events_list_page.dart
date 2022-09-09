import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:upec_mobile/global_variables.dart';
import 'package:upec_mobile/models/event_model.dart';
import 'package:upec_mobile/pages/event_detail_page.dart';
import 'package:upec_mobile/pages/qr_scanner_page.dart';
import 'package:upec_mobile/services/user_service.dart';
import 'package:upec_mobile/utilities/color_utility.dart';
import 'package:upec_mobile/utilities/url_utility.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    var currentUser = UserService.getUser();

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const TabBar(
              labelColor: AppColors.primary,
              tabs: [
                Tab(
                  text: "Ongoing",
                ),
                Tab(
                  text: "Upcoming",
                ),
                Tab(
                  text: "Past",
                ),
              ],
            ),
            backgroundColor: Colors.white,
          ),
          body: const TabBarView(children: [
            OngoingEventsList(),
            UpcomingEventsList(),
            PastEventsList(),
          ]),
          floatingActionButton: globalCurrentUser.value.type == 'member' ? FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const QRScannerPage(scanType: 'for_member',),
              ));
              // showDialog(context: context, builder: (context) => AddRouteModal());
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.qr_code_scanner,),
          )
          : const SizedBox(),
        ),
      );
  }
}

class OngoingEventsList extends StatefulWidget {
  const OngoingEventsList({Key? key}) : super(key: key);

  @override
  State<OngoingEventsList> createState() => _OngoingEventsListState();
}

class _OngoingEventsListState extends State<OngoingEventsList> {
  final Dio _dio = Dio();
  List<Event> eventsList = [];
  final mongo.DbCollection eventCollection =
      globalMongoDB!.collection('events');

  @override
  void initState() {
    _getOngoingEvents();
    super.initState();
  }

  void _getOngoingEvents() async {
    var now = DateTime.now();
    var nowStart = DateTime(now.year, now.month, now.day);
    var nowEnd = DateTime(now.year, now.month, now.day + 1);

    final query = await eventCollection.find({
      'date_start': {'\$gte': nowStart, '\$lt': nowEnd}
    }).toList();

    for (int i = 0; i < query.length; i++) {
      var data = query[i];
      eventsList.add(Event.fromJson(data));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return eventsList.isNotEmpty
        ? ListView.builder(
            itemCount: eventsList.length,
            itemBuilder: ((context, index) {
              final event = eventsList[index];

              return EventTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => EventDetailPage(
                                event: event, eventType: 'ongoing',
                              ))));
                },
                ratings: 0,
                photo: "trail.photo",
                userId: "trail.userID",
                id: event.id,
                title: event.name,
                subtitle: event.address,
                subtitle2: event.description,
                subtitle3: "",
                subtitle4:
                    "${event.dateStartFormatted}   -   ${event.dateEndFormatted}",
                subtitle5: "trail.ratings.toStringAsFixed(1)",
              );
            }))
        : Center(
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: const Text("No events yet"),
            ),
          );
  }
}

class UpcomingEventsList extends StatefulWidget {
  const UpcomingEventsList({Key? key}) : super(key: key);

  @override
  State<UpcomingEventsList> createState() => _UpcomingEventsListState();
}

class _UpcomingEventsListState extends State<UpcomingEventsList> {
  final Dio _dio = Dio();
  List<Event> eventsList = [];
  final mongo.DbCollection eventCollection =
      globalMongoDB!.collection('events');

  @override
  void initState() {
    _getUpcomingEvents();
    super.initState();
  }

  void _getUpcomingEvents() async {
    var now = DateTime.now();
    var nowStart = DateTime(now.year, now.month, now.day + 1);

    final query = await eventCollection.find({
      'date_start': {'\$gte': nowStart}
    }).toList();

    for (int i = 0; i < query.length; i++) {
      var data = query[i];
      eventsList.add(Event.fromJson(data));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return eventsList.isNotEmpty
        ? ListView.builder(
            itemCount: eventsList.length,
            itemBuilder: ((context, index) {
              final event = eventsList[index];

              return EventTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => EventDetailPage(
                                event: event, eventType: 'upcoming',
                              ))));
                },
                ratings: 0,
                photo: "trail.photo",
                userId: "trail.userID",
                id: event.id,
                title: event.name,
                subtitle: event.address,
                subtitle2: event.description,
                subtitle3: "",
                subtitle4:
                    "${event.dateStartFormatted}   -  ${event.dateEndFormatted}",
                subtitle5: "trail.ratings.toStringAsFixed(1)",
              );
            }))
        : Center(
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: const Text("No events yet"),
            ),
          );
  }
}

class PastEventsList extends StatefulWidget {
  const PastEventsList({Key? key}) : super(key: key);

  @override
  State<PastEventsList> createState() => _PastEventsListState();
}

class _PastEventsListState extends State<PastEventsList> {
  final Dio _dio = Dio();
  List<Event> eventsList = [];
  final mongo.DbCollection eventCollection =
      globalMongoDB!.collection('events');

  @override
  void initState() {
    _getPastEvents();
    super.initState();
  }

  void _getPastEvents() async {
    var now = DateTime.now();
    var nowEnd = DateTime(now.year, now.month, now.day + 1);

    final query = await eventCollection.find({
      'date_end': {'\$lt': nowEnd}
    }).toList();

    for (int i = 0; i < query.length; i++) {
      var data = query[i];
      eventsList.add(Event.fromJson(data));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return eventsList.isNotEmpty
        ? ListView.builder(
            itemCount: eventsList.length,
            itemBuilder: ((context, index) {
              final event = eventsList[index];

              return EventTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => EventDetailPage(
                                event: event, eventType: 'past',
                              ))));
                },
                ratings: 0,
                photo: "trail.photo",
                userId: "trail.userID",
                id: event.id,
                title: event.name,
                subtitle: event.address,
                subtitle2: event.description,
                subtitle3: "",
                subtitle4:
                    "${event.dateStartFormatted}   -   ${event.dateEndFormatted}",
                subtitle5: "trail.ratings.toStringAsFixed(1)",
              );
            }))
        : Center(
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: const Text("No events yet"),
            ),
          );
  }
}

class EventTile extends StatelessWidget {
  const EventTile(
      {Key? key,
      this.userId,
      this.id,
      this.title,
      this.subtitle,
      this.onTap,
      this.subtitle2,
      this.subtitle3,
      this.subtitle4,
      this.subtitle5,
      this.photo,
      this.ratings})
      : super(key: key);
  final String? userId;
  final String? id;
  final String? title;
  final String? subtitle;
  final String? subtitle2;
  final String? subtitle3;
  final String? subtitle4;
  final String? subtitle5;
  final VoidCallback? onTap;
  final String? photo;
  final double? ratings;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 1, 10, 1),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              ListTile(
                // leading: CircleAvatar(
                //   backgroundColor: Colors.grey[200],
                //   radius: 25,
                //   backgroundImage: profilePicture ?? AssetImage("assets/default_user.png"),
                // ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title!,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle3!,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        subtitle4!,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        subtitle2!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(
              //   height: 10,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
