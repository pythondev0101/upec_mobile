
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:upec_mobile/global_variables.dart';
import 'package:upec_mobile/modals/event_check_in_modal.dart';
import 'package:upec_mobile/modals/user_check_in_modal.dart';
import 'package:upec_mobile/models/event_model.dart';
import 'package:upec_mobile/models/user_model.dart';


class QRScannerPage extends StatefulWidget {
  final Event? event;
  final String? scanType;
  const QRScannerPage({Key? key, this.event, this.scanType='for_event'}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isScanned = false;
  mongo.DbCollection usersCollection = globalMongoDB!.collection('auth_users');


  @override
  void initState() {
    super.initState();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan a QR'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),     
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _buildQrView(context),

            widget.event == null ?
            const SizedBox()
            : Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 15, 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                            widget.event!.name,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                    ),
                  ],
                ),
              )),
          ],
        ),
        
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if(isScanned == false){
        isScanned = true;
        if(widget.scanType == 'for_event'){
          _showUserCheckInModal(result!.code!);
        } else if(widget.scanType == 'for_member') {
          _showEventCheckInModal(result!.code!);
        }
      }
    });
  }

  Future<void> _showEventCheckInModal(String eventId) async{
    Map<String, dynamic>? query = await usersCollection.findOne({'_id': mongo.ObjectId.fromHexString(eventId)});
    Event event = Event.fromJson(query!);

    await showDialog(
              context: context, 
              builder: (context) => EventCheckInModal(
                event: event,
            ));
    isScanned = false;
  }

  Future<void> _showUserCheckInModal(String tfoeNo) async{
    Map<String, dynamic>? query = await usersCollection.findOne({'tfoe_no': tfoeNo});

    var user = User.fromJson(query!);

    await showDialog(
              context: context, 
              builder: (context) => UserCheckinInModal(
                event: widget.event,
                user: user,
            ));
    isScanned = false;
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}