import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phara_driver/screens/pages/delivery/delivery_page.dart';
import 'package:phara_driver/screens/pages/reports_page.dart';
import 'package:phara_driver/widgets/text_widget.dart';
import 'package:phara_driver/widgets/textfield_widget.dart';
import 'package:badges/badges.dart' as b;
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/pages/aboutus_page.dart';
import '../screens/pages/contactus_page.dart';
import '../screens/pages/messages_tab.dart';
import '../screens/pages/trips_page.dart';
import '../utils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
    getBadgeCount();
  }

  final numberController = TextEditingController();

  late String fileName = '';

  late File imageFile;

  late String imageURL = '';

  int messageBadge = 0;
  int deliveryBadge = 0;

  getBadgeCount() {
    FirebaseFirestore.instance
        .collection('Delivery')
        .where('driverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('status', isEqualTo: 'Pending')
        .get()
        .then((QuerySnapshot querySnapshot) async {
      setState(() {
        deliveryBadge = querySnapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('Messages')
        .where('driverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('seen', isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      setState(() {
        messageBadge = querySnapshot.docs.length;
      });
    });
  }

  Future<void> uploadPicture(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName = path.basename(pickedImage.path);
      imageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: const [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Drivers/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Drivers/$fileName')
            .getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Drivers')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'profilePicture': imageURL});

        Navigator.of(context).pop();
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Drivers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return StreamBuilder<DocumentSnapshot>(
        stream: userData,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading'));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          dynamic data = snapshot.data;

          double rating = data['stars'] / data['ratings'].length;

          return SizedBox(
            child: Drawer(
              child: ListView(
                padding: const EdgeInsets.only(top: 0),
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    accountEmail: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.star,
                              color: data['ratings'].length == 0
                                  ? Colors.grey
                                  : Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            TextRegular(
                              text: data['ratings'].length == 0
                                  ? 'No ratings'
                                  : rating.toStringAsFixed(2),
                              fontSize: 12,
                              color: data['ratings'].length == 0
                                  ? Colors.grey
                                  : Colors.amber,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.grey,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextRegular(
                                  text: data['number'],
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: ((context) {
                                          return AlertDialog(
                                            title: TextRegular(
                                                text: 'New contact number',
                                                fontSize: 14,
                                                color: Colors.black),
                                            content: SizedBox(
                                              height: 80,
                                              child: TextFieldWidget(
                                                  radius: 0,
                                                  inputType:
                                                      TextInputType.number,
                                                  hint: data['number'],
                                                  color: grey,
                                                  height: 35,
                                                  label: '',
                                                  controller: numberController),
                                            ),
                                            actions: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: (() {
                                                      Navigator.pop(context);
                                                    }),
                                                    child: TextRegular(
                                                        text: 'Close',
                                                        fontSize: 14,
                                                        color: grey),
                                                  ),
                                                  TextButton(
                                                    onPressed: (() async {
                                                      if (numberController
                                                              .text !=
                                                          '') {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Drivers')
                                                            .doc(data['id'])
                                                            .update({
                                                          'number':
                                                              numberController
                                                                  .text
                                                        });
                                                        numberController
                                                            .clear();
                                                        Navigator.pop(context);
                                                      }
                                                    }),
                                                    child: TextBold(
                                                        text: 'Update',
                                                        fontSize: 15,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }));
                                  },
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: grey,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                    accountName: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextBold(
                        text: data['name'],
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    currentAccountPicture: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        minRadius: 75,
                        maxRadius: 75,
                        backgroundImage: NetworkImage(data['profilePicture']),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30, left: 30),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () {
                                // Image picker
                                uploadPicture('camera');
                              },
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: TextRegular(
                      text: 'Home',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                    },
                  ),
                  // ListTile(
                  //   leading: b.Badge(
                  //       showBadge: deliveryBadge != 0,
                  //       badgeContent: TextRegular(
                  //           text: deliveryBadge.toString(),
                  //           fontSize: 12,
                  //           color: Colors.white),
                  //       badgeStyle:
                  //           b.BadgeStyle(badgeColor: Colors.amber[600]!),
                  //       child: const Icon(Icons.delivery_dining_outlined)),
                  //   title: TextRegular(
                  //     text: 'Delivery',
                  //     fontSize: 14,
                  //     color: Colors.grey,
                  //   ),
                  //   onTap: () {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (context) => const DeliveryPage()));
                  //   },
                  // ),
                  ListTile(
                    leading: b.Badge(
                        showBadge: messageBadge != 0,
                        badgeContent: TextRegular(
                            text: messageBadge.toString(),
                            fontSize: 12,
                            color: Colors.white),
                        badgeStyle: b.BadgeStyle(badgeColor: Colors.red[600]!),
                        child: const Icon(Icons.message_outlined)),
                    title: TextRegular(
                      text: 'Messages',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MessagesTab()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.stacked_line_chart_sharp),
                    title: TextRegular(
                      text: 'Earnings report',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const ReportsPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.tab_rounded),
                    title: TextRegular(
                      text: 'Recent trips',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const TripsPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.manage_accounts_outlined,
                    ),
                    title: TextRegular(
                      text: 'Contact us',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const ContactusPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                    ),
                    title: TextRegular(
                      text: 'About us',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const AboutusPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: TextRegular(
                      text: 'Logout',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                  'Logout Confirmation',
                                  style: TextStyle(
                                      fontFamily: 'QBold',
                                      fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Are you sure you want to Logout?',
                                  style: TextStyle(fontFamily: 'QRegular'),
                                ),
                                actions: <Widget>[
                                  MaterialButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                          fontFamily: 'QRegular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()));
                                    },
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                          fontFamily: 'QRegular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
