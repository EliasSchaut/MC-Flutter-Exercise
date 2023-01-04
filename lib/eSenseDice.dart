
import 'package:flutter/material.dart';
import 'package:esense_flutter/esense.dart';
import 'dart:async';
import 'dart:math';

class ESenseDice extends StatefulWidget {
  const ESenseDice({super.key});

  @override
  _ESenseDiceState createState() => _ESenseDiceState();
}

class _ESenseDiceState extends State<ESenseDice> {
  String _deviceStatus = '';
  bool sampling = false;
  bool connected = false;

  static const String eSenseDeviceName = 'eSense-0830';
  ESenseManager eSenseManager = ESenseManager(eSenseDeviceName);

  int _diceIndex = 5;
  List<AssetImage> diceImgs = [
    const AssetImage('lib/assets/dice-1-fill.png'),
    const AssetImage('lib/assets/dice-2-fill.png'),
    const AssetImage('lib/assets/dice-3-fill.png'),
    const AssetImage('lib/assets/dice-4-fill.png'),
    const AssetImage('lib/assets/dice-5-fill.png'),
    const AssetImage('lib/assets/dice-6-fill.png')
  ];

  Random random = Random();
  void rollDice() {
    setState(() {
      _diceIndex = random.nextInt(6);
    });
  }

  @override
  void initState() {
    super.initState();
    _listenToESense();
  }

  Future<void> _listenToESense() async {
    eSenseManager.connectionEvents.listen((event) {
      setState(() {
        connected = false;
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            connected = true;
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
  }

  Future<void> _connectToESense() async {
    if (!connected) {
      connected = await eSenseManager.connect();

      setState(() {
        _deviceStatus = connected ? 'connecting...' : 'connection failed';
      });
    }
  }

  StreamSubscription? subscription;
  void _startListenToSensorEvents() async {
    await eSenseManager.setSamplingRate(10);

    subscription = eSenseManager.sensorEvents.listen((event) {
      if (hasNod(event.accel![1].toDouble())) {
        rollDice();
      }
    });
    setState(() {
      sampling = true;
    });
  }

  bool wasUp = false;
  bool hasNod(double y) {
    if (wasUp && (y > 0)) {
      wasUp = false;
      return true;

    } else if (y < 0) {
      wasUp = true;
    }

    return false;
  }

  void _pauseListenToSensorEvents() async {
    subscription?.cancel();
    setState(() {
      sampling = false;
    });
  }

  @override
  void dispose() {
    _pauseListenToSensorEvents();
    eSenseManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect eSense'),
        backgroundColor: Colors.purple,
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: ListView(
          children: [
            const Text(''),
            Center(child: Text('eSense Device Status: \t$_deviceStatus')),
            Container(
              height: 80,
              width: 200,
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: TextButton.icon(
                onPressed: _connectToESense,
                icon: const Icon(Icons.login),
                label: const Text(
                  'CONNECT....',
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ),
            Image(image: diceImgs[_diceIndex]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        // a floating button that starts/stops listening to sensor events.
        // is disabled until we're connected to the device.
        onPressed: (!eSenseManager.connected)
            ? null
            : (!sampling)
            ? _startListenToSensorEvents
            : _pauseListenToSensorEvents,
        tooltip: 'Listen to eSense sensors',
        child: (!sampling)
            ? const Icon(Icons.play_arrow)
            : const Icon(Icons.pause),
      ),
    );
  }
}
