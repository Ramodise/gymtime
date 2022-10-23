import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String name;
  String gender;
  //String interestedIn;
  String photo;
  Timestamp age;
  GeoPoint location;

  User(
      {required this.uid,
      required this.name,
      required this.gender,
      //this.interestedIn,
      required this.photo,
      required this.age,
      required this.location});
}
