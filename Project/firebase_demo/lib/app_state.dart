import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'guest_book_message.dart';

enum Attending { yes, no, unknown }

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  bool _emailVerified = false;

  bool get emailVerified => _emailVerified;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];

  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  int _attendees = 0;

  int get attendees => _attendees;

  static Map<String, dynamic> defaultValues = <String, dynamic>{
    'event_date': 'October 18, 2022',
    'enable_free_swag': false,
    'call_to_action': 'Join us for a day full of Firebase Workshops and Pizza!',
  };

  // ignoring lints on these fields since we are modifying them in a different
  // part of the codelab
  // ignore: prefer_final_fields
  bool _enableFreeSwag = defaultValues['enable_free_swag'] as bool;

  bool get enableFreeSwag => _enableFreeSwag;

  // ignore: prefer_final_fields
  String _eventDate = defaultValues['event_date'] as String;

  String get eventDate => _eventDate;

  // ignore: prefer_final_fields
  String _callToAction = defaultValues['call_to_action'] as String;

  String get callToAction => _callToAction;

  Attending _attending = Attending.unknown;
  StreamSubscription<DocumentSnapshot>? _attendingSubscription;

  Attending get attending => _attending;

  set attending(Attending attending) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, dynamic>{'attending': true});
    } else {
      userDoc.set(<String, dynamic>{'attending': false}); //THESE TWO LINES UPDATE PERSONAL ATTENDEE STATUS
    }
  }

  int _numAttending = 0;

  int get numAttending => _numAttending;

  set numAttending(int amount) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, int>{'numAttending': amount});
    } else {
      userDoc.set(<String, int>{'numAttending': 0}); //THESE TWO LINES UPDATE PERSONAL ATTENDEE STATUS
    }
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          _attendees = snapshot.docs.length;
          notifyListeners();
        }); //UPDATES AMOUNT OF ATTENDEES

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _emailVerified = user.emailVerified;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
              _guestBookMessages = [];
              for (final document in snapshot.docs) {
                _guestBookMessages.add(
                  GuestBookMessage(
                    name: document.data()['name'] as String,
                    message: document.data()['text'] as String,
                  ),
                );
              }
              notifyListeners();
            });
        _attendingSubscription = FirebaseFirestore.instance //Checks if user is attending (checks if user with user uid is attending)
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.data() != null) {
                if (snapshot.data()!['attending'] as bool) {
                  _attending = Attending.yes;
                } else {
                  _attending = Attending.no;
                }
                if(snapshot.data()!['numAttending'] > -1){
                  _numAttending = snapshot.data()!['numAttending'];
                }
              } else {
                _attending = Attending.unknown;
                _numAttending = 0;
              }
              notifyListeners();
            });
      } else {
        _loggedIn = false;
        _emailVerified = false;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> refreshLoggedInUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await currentUser.reload();
  }

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('guestbook').add(
      <String, dynamic>{
        'text': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'name': FirebaseAuth.instance.currentUser!.displayName,
        'userId': FirebaseAuth.instance.currentUser!.uid,
      },
    );
  }
}
