import 'dart:io';
import 'dart:typed_data';

import '/bloc/authentication/authentication_bloc.dart';
import '/bloc/authentication/authentication_event.dart';
import '/bloc/profile/bloc.dart';
import '/repositories/userRepository.dart';
import '/ui/constants.dart';
import '/ui/widgets/gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class ProfileForm extends StatefulWidget {
  final UserRepository _userRepository;

  ProfileForm({required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();

  //String gender, interestedIn;
  DateTime? age;
  Uint8List? photo;
  GeoPoint? location;
  String? gender;
  ProfileBloc? _profileBloc;

  final ImagePicker _picker = ImagePicker();

  //UserRepository get _userRepository => widget._userRepository;

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      photo = im;
    });
  }


  bool get isFilled =>
      _nameController.text.isNotEmpty &&
      //gender != null &&
      //interestedIn != null &&
      photo != null &&
      age != null;

  bool isButtonEnabled(ProfileState state) {
    return isFilled && !state.isSubmitting;
  }

  _getLocation() async {
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    location = GeoPoint(position.latitude, position.longitude);
  }

  _onSubmitted() async {
    await _getLocation();
    _profileBloc?.add(
      Submitted(
          name: _nameController.text,
          age: age!,
          location: location!,
          gender: gender!,
          //interestedIn: interestedIn,
          photo: photo!),
    );
  }

  @override
  void initState() {
    _getLocation();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<ProfileBloc, ProfileState>(
      //bloc: _profileBloc,
      listener: (context, state) {
        if (state.isFailure) {
          print("Failed");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Profile Creation Unsuccesful'),
                    Icon(Icons.error)
                  ],
                ),
              ),
            );
        }
        if (state.isSubmitting) {
          print("Submitting");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Submitting'),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          print("Success!");
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: backgroundColor,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Stack(
                    children: [
                      photo != null
                          ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(photo!),
                        backgroundColor: Colors.red,
                      )
                          : const CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(
                            'https://i.stack.imgur.com/l60Hf.png'),
                        backgroundColor: Colors.red,
                      ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
                    ],
                  ),

                  textFieldWidget(_nameController, "Name", size),
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime(1900, 1, 1),
                        maxTime: DateTime(DateTime.now().year - 19, 1, 1),
                        onConfirm: (date) {
                          setState(() {
                            age = date;
                          });
                          print(age);
                        },
                      );
                    },
                    child: Text(
                      "Enter Birthday",
                      style: TextStyle(
                          color: Colors.white, fontSize: size.width * 0.09),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: <Widget>[
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(
                  //           horizontal: size.height * 0.02),
                  //       child: Text(
                  //         "You Are",
                  //         style: TextStyle(
                  //             color: Colors.white, fontSize: size.width * 0.09),
                  //       ),
                  //     ),
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: <Widget>[
                  //         genderWidget(
                  //             FontAwesomeIcons.venus, "Female", size, gender,
                  //             () {
                  //           setState(() {
                  //             gender = "Female";
                  //           });
                  //         }),
                  //         genderWidget(
                  //             FontAwesomeIcons.mars, "Male", size, gender, () {
                  //           setState(() {
                  //             gender = "Male";
                  //           });
                  //         }),
                  //         genderWidget(
                  //           FontAwesomeIcons.transgender,
                  //           "Transgender",
                  //           size,
                  //           gender,
                  //           () {
                  //             setState(
                  //               () {
                  //                 gender = "Transgender";
                  //               },
                  //             );
                  //           },
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(
                  //       height: size.height * 0.02,
                  //     ),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(
                  //           horizontal: size.height * 0.02),
                  //       child: Text(
                  //         "Looking For",
                  //         style: TextStyle(
                  //             color: Colors.white, fontSize: size.width * 0.09),
                  //       ),
                  //     ),
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: <Widget>[
                  //         genderWidget(FontAwesomeIcons.venus, "Female", size,
                  //             interestedIn, () {
                  //           setState(() {
                  //             interestedIn = "Female";
                  //           });
                  //         }),
                  //         genderWidget(
                  //             FontAwesomeIcons.mars, "Male", size, interestedIn,
                  //             () {
                  //           setState(() {
                  //             interestedIn = "Male";
                  //           });
                  //         }),
                  //         genderWidget(
                  //           FontAwesomeIcons.transgender,
                  //           "Transgender",
                  //           size,
                  //           interestedIn,
                  //           () {
                  //             setState(
                  //               () {
                  //                 interestedIn = "Transgender";
                  //               },
                  //             );
                  //           },
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    child: GestureDetector(
                      onTap: () {
                        if (isButtonEnabled(state)) {
                          _onSubmitted();
                        } else {}
                      },
                      child: Container(
                        width: size.width * 0.8,
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                          color: isButtonEnabled(state)
                              ? Colors.white
                              : Colors.grey,
                          borderRadius:
                              BorderRadius.circular(size.height * 0.05),
                        ),
                        child: Center(
                            child: Text(
                          "Save",
                          style: TextStyle(
                              fontSize: size.height * 0.03,
                              color: Colors.blue),
                        )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget textFieldWidget(controller, text, size) {
  return Padding(
    padding: EdgeInsets.all(size.height * 0.02),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        labelStyle:
            TextStyle(color: Colors.white, fontSize: size.height * 0.03),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
      ),
    ),
  );
}
