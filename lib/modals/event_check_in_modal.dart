import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:upec_mobile/components/expanded_button.dart';
import 'package:upec_mobile/global_variables.dart';
import 'package:upec_mobile/models/event_model.dart';
import 'package:upec_mobile/models/user_model.dart';
import 'package:upec_mobile/utilities/color_utility.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class EventCheckInModal extends StatefulWidget {
  final Event? event;

  EventCheckInModal({Key? key, this.event}) : super(key: key);

  @override
  _EventCheckInModalState createState() => _EventCheckInModalState();
}

class _EventCheckInModalState extends State<EventCheckInModal> {
  bool _isLoading = false;
  final mongo.DbCollection eventCollection = globalMongoDB!.collection('events');

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      scrollable: true,
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(widget.event!.name,
                 style: const TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 20
              ),),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ))
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Text("Start Date: ${widget.event!.dateStartFormatted}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Text("End Date: ${widget.event!.dateEndFormatted}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: _isLoading == false
                ? ExpandedButton(
                    buttonColor: AppColors.secondary,
                    borderRadius: 20,
                    expanded: true,
                    elevation: 1,
                    title: 'Check-in',
                    titleFontSize: 14,
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      var query = await eventCollection.findOne({'_id':widget.event!.mongoId});
                      Event event = Event.fromJson(query!);

                      if(event.attendances!.contains(globalCurrentUser.value.mongoId)){
                        Toast.show("Already checked in!");
                        return;
                      }

                      eventCollection.updateOne({'_id': widget.event!.mongoId}, {"\$push": {'attendances': globalCurrentUser.value.mongoId}}).then(
                        (value){
                        Navigator.pop(context);

                        Toast.show("Check in Successfully!");
                        setState(() {
                          _isLoading = false;
                        });
                      }).catchError((err){
                      setState(() {
                        _isLoading = false;
                      });
                      });
                    },
                    titleAlignment: Alignment.center,
                    titleColor: Colors.white,
                  )
                : const CircularProgressIndicator(),
          ),
          // SizedBox(
          //   height: 10,
          // ),
        ],
      ),
    );
  }
}
