import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ready Countdown App',
        home: ReadyScreen(deviceId: 'device1'), // Change deviceId per device if needed
      );
}

class ReadyScreen extends StatefulWidget {
  final String deviceId;
  const ReadyScreen({required this.deviceId});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {
  final _db = FirebaseDatabase.instance.ref();
  bool _isReady = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _db.child('countdown/start_time').onValue.listen((event) {
      final startTimestamp = event.snapshot.value;
      if (startTimestamp != null && startTimestamp is int && startTimestamp > 0) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(startTimestamp);
        final now = DateTime.now();
        final elapsed = now.difference(startTime).inSeconds;
        final remaining = 10 - elapsed;

        if (remaining > 0) {
          setState(() => _countdown = remaining);
          _startCountdown(remaining);
        }
      }
    });
  }

  void _startCountdown(int from) {
    _timer?.cancel();
    _countdown = from;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _countdown--);
      if (_countdown <= 0) timer.cancel();
    });
  }

  Future<void> _markReady() async {
    await _db.child('devices/${widget.deviceId}').set({"ready": true});
    _isReady = true;

    _db.child('devices').onValue.listen((event) async {
      final devices = Map<String, dynamic>.from(event.snapshot.value as Map);
      final allReady = devices.values.every((val) => val['ready'] == true);
      if (allReady) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await _db.child('countdown').update({
          'start_time': now,
          'duration': 10,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Ready Countdown')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _countdown > 0
                  ? Text('Countdown: $_countdown',
                      style: TextStyle(fontSize: 32, color: Colors.red))
                  : ElevatedButton(
                      onPressed: _isReady ? null : _markReady,
                      child: Text('READY', style: TextStyle(fontSize: 24)),
                    ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
