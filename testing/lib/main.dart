import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("306d457d-6f91-47bf-9c89-2d22c831fd57"); // Your App ID
  OneSignal.Notifications.requestPermission(true); // Ask for push permission

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal Push',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationSenderScreen(),
    );
  }
}

class NotificationSenderScreen extends StatefulWidget {
  const NotificationSenderScreen({super.key});

  @override
  State<NotificationSenderScreen> createState() => _NotificationSenderScreenState();
}

class _NotificationSenderScreenState extends State<NotificationSenderScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  final String restApiKey = 'os_v2_app_gbwuk7lpsfd37hejfurmqmp5k7onnvkkbmju244axaahd3jpxqlwxskmhxdlo7rfzs2tg6ougluc77vcxq7wcpevklsmdaolrprpwna';
  final String appId = '306d457d-6f91-47bf-9c89-2d22c831fd57';

  @override
  void initState() {
    super.initState();
    _printOneSignalInfo();
  }

  void _printOneSignalInfo() async {
    final userId = await OneSignal.User.pushSubscription.id!;
    final deviceState = await OneSignal.User.pushSubscription.optIn();

    print('📱 OneSignal User ID: $userId');
    print('🔔 Subscribed: ${deviceState?.isSubscribed}');

    if (deviceState?.isSubscribed == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Please allow notifications in system settings.')),
      );
    }
  }

  Future<void> sendNotification(String title, String body) async {
    var url = Uri.parse('https://onesignal.com/api/v1/notifications');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $restApiKey',
    };

    var payload = jsonEncode({
      'app_id': appId,
      'included_segments': ['Total Subscriptions'],
      'headings': {'en': title},
      'contents': {'en': body},
    });

    try {
      var response = await http.post(url, headers: headers, body: payload);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Notification sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Push Notification')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/images/app.png', height: 100),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notification Body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final title = _titleController.text.trim();
                final body = _bodyController.text.trim();
                if (title.isNotEmpty && body.isNotEmpty) {
                  sendNotification(title, body);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠️ Please fill in both fields.')),
                  );
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
