//Auteur: El Idrissi Sami
//
import 'dart:ui';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api/firebase_api.dart';


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
      title: 'Projet A (Bouton)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyText2: TextStyle(fontSize: 40),
        ),
      ),
        home: const MyHomePage(),
      debugShowCheckedModeBanner: false,  //Pour retirer la mention de debug en haut de l'application
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


// Remplacez par les tokens des utilisateurs cibles
List tokensA = [myToken,'TOKEN_1','TOKEN_2','TOKEN_3'];
List tokensB = ['f8niflURTnGmD0uIOmrs_j:APA91bGmOhwEOtea7IHDsrpNNjXvO3Ri4xdj_gaM8T7LUPXb9gti8b_0iCy344ViHvTEV_voqmQyKa9iksVAum1CiYS4nKj8dp68mQnvgjqE9sf1MVLaDke5rYlLoJ1ZdrGCpyQDc7_n','TOKEN_2','TOKEN_3'];  // Remplacez par les tokens des utilisateurs cibles


// Remplacer par le token de serveur Firebase
final String serverTokenA = 'AAAAO_Vbny8:APA91bEriagxvgMnaiYPGcrKZRZGFDuhkWv_YiJgztiu4ZvZHaReShjQfHpw2ZZR-4j8vDOSXg4wxwTkWczAAIRzLoPSRb3NaXTnISyw8s-s2gdhe_RY-lM9hub0Lf9GzAuT_GG6PG3R';
final String serverTokenB = 'AAAAFnKZLt4:APA91bHIrsTpQVYOZTM2qSqEZo0kNXgB7PKlbobaI2sdjb5Ir2l7f-LqqQRpU-0osuJOPtXvjXSeLetjzk8hNxfeLiwSrAxyUg4t069CKdy0JVo78pejePgVnh6bqNw236QhcsP6OuRe';




/*
  La fonction suivante prend en entrée la liste de Tokens "tokens" et leur envoie un message (ici message1)
 */

Future sendNotification(List tokens, String serverToken) async {
  //Nouvelle version :
  //final String serverToken = 'ya29.a0AbVbY6PdBysTPpRjRtaPltpRcNL3Yo-XdbE63E9_oUbiVBPFpQnzJJ5upIBmr5ujgwnJAdHsaWyZCn3lje-D70xeMdyZ-Cp5vWgl1kgVWeH6tbSko6oOrOgdnIAueXZZFNyOK9qcCKta6lD0mI_ZKXcqGxi3aCgYKAeUSARESFQFWKvPl578-sFJ6rZ5yJHV-mTyZWA0163';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final message = {
    'registration_ids': tokens,
     'notification': {
      'title': 'Notification Test',
      'body': 'Ce message a été envoyé depuis l\'appli A',
    },
  };

      try {
        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'), //Version obsolète
          //Uri.parse('https://fcm.googleapis.com/v1/projects/projet1-d7c2b/messages:send'), // Nouvelle version
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverToken', //Version obsolète
            //'Authorization': 'Bearer' + '$serverToken', //Nouvelle version
          },
          body: jsonEncode(message),
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
        title: Text('Projet A (Bouton)'),
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
                sendNotification(tokensA, serverTokenA);
                changeText();
                },
              child: Text('Projet A'),
            ),
            ElevatedButton(
              onPressed:() {
                sendNotification(tokensB, serverTokenB);
                changeText();
              },
              child: Text('Projet B'),
            ),
          ],
        ),
      ),
    );
  }

}

