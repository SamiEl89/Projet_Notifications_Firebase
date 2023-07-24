//Auteur: El Idrissi Sami
//

import 'dart:ui';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:projet_notif_b/page/notifications_screen.dart';
import 'api/firebase_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



final navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initState();
  DartPluginRegistrant.ensureInitialized();
  await FirebaseApi().initNotifications();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projet B (Reception)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyText2: TextStyle(fontSize: 40),
        ),
      ),
      navigatorKey: navigatorKey,
        home: const MyHomePage(),
      routes: {
        NotificationScreen.route: (context) => const NotificationScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

/*
  La fonction suivante sert à enregistrer le Token de notre portable dans la liste tokens
 */

String? myToken;

void getToken() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission( );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await FirebaseMessaging.instance.getToken();
    myToken = token;
    print('Token: $myToken');
  }
}

@override
void initState() {
  getToken();
  Firebase.initializeApp();
}


List tokens = [myToken,'TOKEN_1','TOKEN_2'];  // Remplacez par les tokens des utilisateurs cibles


/*
  La fonction suivante prend en entrée la liste de Tokens "tokens" et leur envoie un message (ici message1)
 */

Future sendNotification(List tokens) async {
  //Nouvelle version :
  //final String serverToken = 'ya29.a0AbVbY6PdBysTPpRjRtaPltpRcNL3Yo-XdbE63E9_oUbiVBPFpQnzJJ5upIBmr5ujgwnJAdHsaWyZCn3lje-D70xeMdyZ-Cp5vWgl1kgVWeH6tbSko6oOrOgdnIAueXZZFNyOK9qcCKta6lD0mI_ZKXcqGxi3aCgYKAeUSARESFQFWKvPl578-sFJ6rZ5yJHV-mTyZWA0163';


  final String serverToken = 'AAAAFnKZLt4:APA91bHIrsTpQVYOZTM2qSqEZo0kNXgB7PKlbobaI2sdjb5Ir2l7f-LqqQRpU-0osuJOPtXvjXSeLetjzk8hNxfeLiwSrAxyUg4t069CKdy0JVo78pejePgVnh6bqNw236QhcsP6OuRe';
  // Remplacer par le token de serveur Firebase

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final message1 = {
    'registration_ids': tokens,
    'notification': {
      'title': 'Notification Projet_B',
      'body': 'Ce message a été envoyé depuis l\'appli',
    },
  };

  try {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'), //Version obsolète
      //Uri.parse('https://fcm.googleapis.com/v1/projects/projet2-84b90/messages:send'), // Nouvelle version
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken', //Version obsolète
        //'Authorization': 'Bearer' + '$serverToken', //Nouvelle version
      },
      body: jsonEncode(message1),
    );

    if (response.statusCode == 200) {
      print('Notification envoyée avec succès');
      } else {
      print('Erreur lors de l envoi de la notification');
      }
      } catch (e) {
        print('Erreur lors de l envoi de la notification : $e');
    }

  }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State {
  String buttonText = 'Envoyer la notification ?';

  void changeText() {
    setState(() {
      buttonText = 'Notification envoyée';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projet B (Reception)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:() {
                sendNotification(tokens);
                changeText();
                },
              child: Text('Appuyez ici'),
            ),
          ],
        ),
      ),
    );
  }

}

