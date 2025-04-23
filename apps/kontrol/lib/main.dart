import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Remote Control',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101010),
        primaryColor: Colors.tealAccent,
      ),
      home: MatrixControlPage(
        isDarkMode: isDarkMode,
        onThemeToggle: () => setState(() => isDarkMode = !isDarkMode),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MatrixControlPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  MatrixControlPage({required this.isDarkMode, required this.onThemeToggle});

  @override
  _MatrixControlPageState createState() => _MatrixControlPageState();
}

class _MatrixControlPageState extends State<MatrixControlPage> {
  late MqttServerClient client;
  bool isConnected = false;
  String broker = 'broker.emqx.io';
  int port = 1883;
  String topic = 'matrix/text';
  String clientId = 'flutter_matrix_client';

  int countdown = 300;
  Timer? _timer;
  bool isCounting = false;

  List<Map<String, String>> logHistory = [];

  int _currentIndex = 0;

  final TextEditingController brokerController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController clientIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    brokerController.text = broker;
    portController.text = port.toString();
    topicController.text = topic;
    clientIdController.text = clientId;
    _connectMQTT();
  }

  void _connectMQTT() async {
    client = MqttServerClient.withPort(broker, clientId, port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('Connection Closed')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('MQTT Connection Error: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT Connected');
      setState(() => isConnected = true);
      client.subscribe(topic, MqttQos.atMostOnce);
    } else {
      print('MQTT Connection Failed - Status: ${client.connectionStatus}');
    }
  }

  void _onConnected() {
    print('Connected to MQTT broker');
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
    setState(() => isConnected = false);
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _sendMessage(String msg) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('Sent MQTT message: $msg');
    setState(() {
      logHistory.insert(0, {
        'time': TimeOfDay.now().format(context),
        'topic': topic,
        'message': msg
      });
    });
  }

  void _startCountdown() {
    _sendMessage('mulai');
    setState(() {
      isCounting = true;
      countdown = 300;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown <= 0) {
        timer.cancel();
        setState(() => isCounting = false);
        _sendMessage('SELESAI');
      } else if (countdown == 60) {
        _sendMessage('Sebentar lagi selesai');
      } else if (countdown == 120) {
        _sendMessage('Waktunya berhenti');
      }
      setState(() => countdown--);
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Matrix Control'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onThemeToggle,
          )
        ],
      ),
      body: _currentIndex == 0
          ? _buildMainControlPage()
          : _currentIndex == 1
              ? _buildSettingsPage()
              : _buildLogsPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Logs',
          ),
        ],
      ),
    );
  }

  Widget _buildMainControlPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: ScaleTransition(
              scale: AlwaysStoppedAnimation(1.2),
              child: Icon(
                Icons.electrical_services,
                key: ValueKey<int>(countdown),
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            duration: Duration(seconds: 1),
            opacity: isConnected ? 1.0 : 0.6,
            child: Text(
              isConnected ? "Status: Connected" : "Status: Disconnected",
              style: TextStyle(
                  color: isConnected ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          if (isCounting)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8.0,
                    color: Colors.black45,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _formatTime(countdown),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (isConnected && !isCounting) _startCountdown();
            },
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected && !isCounting
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              onPressed: () {
                if (isConnected && !isCounting) {
                  _startCountdown();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    "Mulai Countdown",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Log Pengiriman",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    columnSpacing: 12,
                    columns: const [
                      DataColumn(label: Text('Waktu')),
                      DataColumn(label: Text('Topik')),
                      DataColumn(label: Text('Pesan')),
                    ],
                    rows: logHistory.map((log) {
                      return DataRow(cells: [
                        DataCell(Text(log['time'] ?? '')),
                        DataCell(Text(log['topic'] ?? '')),
                        DataCell(Text(log['message'] ?? '')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pengaturan MQTT",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: brokerController,
            decoration: InputDecoration(
              labelText: "Broker MQTT",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              broker = value;
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: portController,
            decoration: InputDecoration(
              labelText: "Port MQTT",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              port = int.tryParse(value) ?? 1883;
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: topicController,
            decoration: InputDecoration(
              labelText: "Topik MQTT",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              topic = value;
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: clientIdController,
            decoration: InputDecoration(
              labelText: "Client ID MQTT",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              clientId = value;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Update broker, port, topic, and client ID
                broker = brokerController.text;
                port = int.tryParse(portController.text) ?? 1883;
                topic = topicController.text;
                clientId = clientIdController.text;
              });
              _connectMQTT(); // Reconnect with updated settings
            },
            child: Text("Update Settings"),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Histori Log Pengiriman",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    columnSpacing: 12,
                    columns: const [
                      DataColumn(label: Text('Waktu')),
                      DataColumn(label: Text('Topik')),
                      DataColumn(label: Text('Pesan')),
                    ],
                    rows: logHistory.map((log) {
                      return DataRow(cells: [
                        DataCell(Text(log['time'] ?? '')),
                        DataCell(Text(log['topic'] ?? '')),
                        DataCell(Text(log['message'] ?? '')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
