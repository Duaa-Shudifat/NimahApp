import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  static const _serviceAccountJson = {
    "type": "service_account",
    "project_id": "nimah-app-74450",
    "private_key_id": "8b279dce7b36d101cae087873d39685e76ebe939",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDVoN/NxmwXfJHQ\ndUdg01d5LLNDotVWVmDFHXgTwwuuYKq7mR4itUtgWE3dD52B9pgAfVgpRExBl5r/\nCxXzLOOKXE/rVAvhK20RtClGUdV2uScNobki7aG3dCU/w3dxR2LLKOdvmunuNLxA\nyspoVtuhqx1BsrpT3YQIFK2DA5lgV21L1KChy8eW8JUjfTJI3toVDTB4P3+tWEz5\nVFJylKRgaCZbaQiZBHpHMvfIa0emEUl9xS9ZOojItlSMDTGECXalsdh9PuOrbli5\nFZfF9LBysH2IMxyUHrF/C0WGtFu20SC2H69BM4MxAUD7T2SR1EWpppYzD4XBDGTx\nRayg5OFnAgMBAAECggEAMt0e7Gu2CNGMFkoWOKOZTCyscgovKWNfnw8pK+tguKAj\nho8qcbEgxUvBHkU9h1gjUNqHRywPy/5A1UDadQ/XDXZ1QN6+BVrFmVWADlIltSLY\nfZJn9j0GKBvrUodDxSDuENkoYZZM5H6B5BtknfswSAnp6V6YpqczbIkf1vXgauN2\neR1/iTw5EWHc39h2emo84lcHUFMGbje6rNyNgUjOYrcjoc40tn0BjfBqzQZI4yWL\ncCNiObpELhcq6zuuy1pIfmf4qDJEPFThqP8uLlwyhUNNRadyvDqwC0p73K+1JdXa\nonZ5cde4QPAte9snFeQyqOaf6o3sSDkKDZCgZKhb4QKBgQD5F2biwrIMjVD+auUs\nIvkkPqLvydJBO/CpQXFQPbvmpw2MMaYNJ5PvsdyxcG10AHv4IfMoFYjYueLlRkZW\nLNqqDB0AZwsmuvMjV8NpmsxkhfyxCSstRlVW3+72/ESHklVswmEFiBrrUeTqwaz0\nAkPqeeEUWCH0E7yEA//7ImpBbQKBgQDbja2VViWSIJwCDeIkKB3lZ9b2/vmRolM3\nO1g9gCUy3v9Hyg0pby4hAuWmyaKDGjkjl0uXW2BZGZlXNvf53yNy4V3dyxR+bCoh\nRLHwha4GNS/rD7h1HexTw58s46COr9HcG+N6y+k+ajoXKOPRmhNVQyzaGbM/i8Gi\nNofPdpd9owKBgQCq2jpf31tw8J1VZMy8cWCiU7Q+9ReaVxrDfXfTqgRwOLU6K/PR\nogv+pOjTbGIm5w4hLGg0XlD3Fsliqckk4q85ZAWgeQ1VC3YqD9ChZuQ7LwwcAkXz\nUALJC+BE2NPIib6+UrVpremI7ystOpr+427iLacM5Uaku8TaaEP0Za6sIQKBgQCD\n+CBLsHF66XD85x10QEzgFM+ovdCDkn/Upi4/IWS6tEHcA/5vVm3y18v0uiSeC0gn\nNYzxWLKMPA/o1ZiusEqdhgunAqe56ghU4PbYLXJSNuwrrdJhS3A/VUm7cMOUoOhT\nFsxghmsX4kAypZhy59sRGATAwEv3OWlVuNNfh9g9YwKBgQC/4MRz4rcE/PS/vYl7\n45qXdg7619bpbk02dlh5lG7EW4OEXwXb/99mm+jBMfNDvjMa+4wPFWzmA9dCizeq\nHIv6ocWV3ZaWrOsP8qzugP9rY0Y0EbORv+pfkfPkiNZF5KtmQbY8UE+NtZSoPrap\nkHdKjMGi5HQzf/T9IPxuwpS+PQ==\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@nimah-app-74450.iam.gserviceaccount.com",
    "client_id": "114273433057305785297",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
  };

  Future<void> setupNotifications() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || token == null) return;

      final customerDoc = await FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(uid)
          .get();

      if (customerDoc.exists) {
        await FirebaseFirestore.instance
            .collection('CUSTOMERS')
            .doc(uid)
            .set({'fcmToken': token}, SetOptions(merge: true));

        print("Customer token saved from setupNotifications");
        return;
      }

      final providerDoc = await FirebaseFirestore.instance
          .collection('FOOD_PROVIDERS')
          .doc(uid)
          .get();

      if (providerDoc.exists) {
        await FirebaseFirestore.instance
            .collection('FOOD_PROVIDERS')
            .doc(uid)
            .set({'fcmToken': token}, SetOptions(merge: true));

        print("Provider token saved from setupNotifications");
        return;
      }

      final driverDoc = await FirebaseFirestore.instance
          .collection('DRIVERS')
          .doc(uid)
          .get();

      if (driverDoc.exists) {
        await FirebaseFirestore.instance
            .collection('DRIVERS')
            .doc(uid)
            .set({'fcmToken': token}, SetOptions(merge: true));

        print("Driver token saved from setupNotifications");
        return;
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          print("Foreground message title: ${message.notification!.title}");
          print("Foreground message body: ${message.notification!.body}");
        }
      });
    }
  }
  static Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    String orderId = "",
    required String type,


  }) async {
    try {
      final accountCredentials = ServiceAccountCredentials.fromJson(
        _serviceAccountJson,
      );

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(accountCredentials, scopes);

      final projectId = 'nimah-app-74450';
      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final response = await client.post(

        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': {
              'orderId': orderId,
              "type": type,
            },
          },
        }),
      );
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      client.close();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}