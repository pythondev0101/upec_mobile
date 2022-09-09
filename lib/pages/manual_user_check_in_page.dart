import 'package:flutter/material.dart';
import 'package:upec_mobile/global_variables.dart';
import 'package:upec_mobile/modals/user_check_in_modal.dart';
import 'package:upec_mobile/models/event_model.dart';
import 'package:upec_mobile/models/user_model.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:upec_mobile/utilities/color_utility.dart';

class ManualUserCheckInPage extends StatefulWidget {
  const ManualUserCheckInPage({Key? key, required this.event})
      : super(key: key);
  final Event event;

  @override
  State<ManualUserCheckInPage> createState() => _ManualUserCheckInPageState();
}

class _ManualUserCheckInPageState extends State<ManualUserCheckInPage> {
  TextEditingController _searchController = TextEditingController();
  List<User> membersList = [];
  final mongo.DbCollection usersCollection =
      globalMongoDB!.collection('auth_users');
  final mongo.DbCollection eventsCollection =
      globalMongoDB!.collection('events');
  
  List<dynamic> attendancesList = [];

  @override
  void initState() {
    attendancesList = widget.event.attendances!;
    loadMembersList();
    super.initState();
  }

  void loadMembersList() async {
    membersList.clear();
    var query = await usersCollection.find().toList();

    for (int i = 0; i < query.length; i++) {
      final User user = User.fromJson(query[i]);
      membersList.add(user);
    }
    setState(() {});
  }

  void reloadEventAttendances() async {
    var query = await eventsCollection.findOne({'_id': widget.event.mongoId});

    Event event = Event.fromJson(query!);
    attendancesList.clear();
    setState(() {
      attendancesList = event.attendances!;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        title: const Text(
          "Manual Check in",
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
      body: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Container(
            //height: 70,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
              ),
            )),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                ),
                child: TextField(
                  onChanged: (text) {
                    // setState(() {
                    //   searchValue = text;
                    //                       });
                  },
                  controller: _searchController,
                  style: const TextStyle(fontSize: 16.0),
                  decoration: const InputDecoration(
                      hintText: "Search last name",
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
        body: ListView.builder(
          itemCount: membersList.length,
          itemBuilder: (context, index) {
            var user = membersList[index];
            var isJoined = false;
            if (attendancesList.contains(user.mongoId)) {
              isJoined = true;
            }

            return UserTile(
              user: user,
              isJoined: isJoined,
              onTap: () async {
                if (isJoined) {
                  return;
                }

                await showDialog(
                    context: context,
                    builder: (context) => UserCheckinInModal(
                          event: widget.event,
                          user: user,
                        )).then((value) {
                  reloadEventAttendances();
                  loadMembersList();
                });
              },
            );
          },
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile(
      {Key? key,
      required this.onTap,
      required this.user,
      required this.isJoined})
      : super(key: key);

  final VoidCallback onTap;
  final User user;
  final bool isJoined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
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
                    "${user.fname!} ${user.lname}",
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
                          user.batch!,
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
                          user.address!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Container(
                    width: 110,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 50),
                              child: TextButton(
                                onPressed: onTap,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 25),
                                  backgroundColor: isJoined == false
                                      ? AppColors.accent
                                      : Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  isJoined == false ? 'Check in' : 'Attended',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
