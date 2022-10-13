import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';
import 'package:upec_mobile/global_variables.dart';
import 'package:upec_mobile/models/event_model.dart';
import 'package:upec_mobile/models/user_model.dart';
import 'package:upec_mobile/pages/manual_user_check_in_page.dart';
import 'package:upec_mobile/pages/qr_scanner_page.dart';
import 'package:upec_mobile/utilities/color_utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class EventDetailPage extends StatefulWidget {
  final Event event;
  final String eventType;
  const EventDetailPage(
      {Key? key, required this.event, required this.eventType})
      : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  List<User> attendanceList = [];
  final mongo.DbCollection eventsCollection =
      globalMongoDB!.collection('events');
  final mongo.DbCollection usersCollection =
      globalMongoDB!.collection('auth_users');

  @override
  void initState() {
    loadAttendanceList();
    super.initState();
  }

  void loadAttendanceList() async {
    attendanceList.clear();

    Map<String, dynamic>? query =
        await eventsCollection.findOne({'_id': widget.event.mongoId});
    final Event event = Event.fromJson(query!);

    for (int i = 0; i < event.attendances!.length; i++) {
      mongo.ObjectId id = event.attendances![i];
      Map<String, dynamic>? query = await usersCollection.findOne({'_id': id});
      final User user = User.fromJson(query!);
      attendanceList.add(user);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Details"),
              Tab(text: "Attendance"),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          title: const Text(
            "Event",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(
            color: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 10),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 20,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.all(0),
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ListTile(
                                      title: Text(widget.event.name),
                                      subtitle: const Text("Name"),
                                      leading: const Icon(Icons.person),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ListTile(
                                      title: Text(
                                        widget.event.description,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      subtitle: const Text("Description"),
                                      leading: const Icon(Icons.location_city),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ListTile(
                                      title: Text(widget.event.address),
                                      subtitle: const Text("Address"),
                                      leading: const Icon(Icons.location_city),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ListTile(
                                      title: Text(
                                          widget.event.dateStart.toString()),
                                      subtitle: const Text("Start Date"),
                                      leading: const Icon(Icons.calendar_month),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ListTile(
                                      title:
                                          Text(widget.event.dateEnd.toString()),
                                      subtitle: const Text("End Date"),
                                      leading: const Icon(Icons.calendar_month),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                                top: 25, left: 10, right: 10, bottom: 10),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 20,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.all(0),
                              color: Colors.white,
                              child: QrImage(
                                data: widget.event.id!,
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                title: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                    child: Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                      ),
                      child: TextField(
                        enabled: false,
                        onChanged: (text) {},
                        // controller: _searchController,
                        style: const TextStyle(fontSize: 16.0),
                        decoration: const InputDecoration(
                            hintText: "Search Name",
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20.0,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: attendanceList.isNotEmpty
                    ? ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: attendanceList.length,
                        itemBuilder: (context, index) {
                          return AttendanceTile(
                            user: attendanceList[index],
                            onTap: () {},
                          );
                        })
                    : Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 50),
                          child: const Text("No members yet"),
                        ),
                      ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: globalCurrentUser.value.type == 'member' 
        ? const SizedBox()
        : Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: AppColors.primary,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  // onTap: _capturePhoto,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(Icons.camera, color: Colors.grey),
                      Text("Camera",
                          style: TextStyle(color: Colors.grey, fontSize: 12))
                    ],
                  ),
                ),
              ),
              const VerticalDivider(
                thickness: 5,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (widget.eventType != 'ongoing') {
                      Toast.show('This event is not ongoing!');
                      return;
                    }

                    await Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => QRScannerPage(
                        event: widget.event,
                        scanType: 'for_event',
                      ),
                    ))
                        .then((value) {
                      loadAttendanceList();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(Icons.qr_code_scanner, color: Colors.white),
                      Text("QR",
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ],
                  ),
                ),
              ),
              const VerticalDivider(
                thickness: 5,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (widget.eventType != 'ongoing') {
                      Toast.show('This event is not ongoing!');
                      return;
                    }
                    await Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => ManualUserCheckInPage(
                        event: widget.event,
                      ),
                    ))
                        .then((value) {
                      loadAttendanceList();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(Icons.search, color: Colors.white),
                      Text("Manual",
                          style: TextStyle(color: Colors.white, fontSize: 12))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceTile extends StatefulWidget {
  const AttendanceTile({Key? key, required this.onTap, required this.user})
      : super(key: key);

  final VoidCallback onTap;
  final User user;

  @override
  _AttendanceTileState createState() => _AttendanceTileState();
}

class _AttendanceTileState extends State<AttendanceTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 1, 10, 1),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text(
                    "${widget.user.fname!} ${widget.user.lname}",
                    style: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.batch!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.user.address!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
