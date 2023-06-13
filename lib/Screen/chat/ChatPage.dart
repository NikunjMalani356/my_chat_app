
import 'package:chat_app/Screen/Login/LoginPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';

class ChatPage extends StatefulWidget {
  String? to_person_name;
  String? to_person_number;

  String? login_person_name;
  String? login_person_number;

  ChatPage(this.to_person_name, this.to_person_number, this.login_person_name,
      this.login_person_number);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  SharedPreferences? prefs;
  TextEditingController chat = TextEditingController();
  DatabaseReference starCountRef = FirebaseDatabase.instance.ref('chat');
  List sorted = [];
  List sortedkeys= [];
  DateTime? dt;
  ScrollController controller = new ScrollController();

  ImagePicker picker = ImagePicker();
  PickedFile? image;
  String? img_name;
  Directory? dir;
  File? file;


  FilePickerResult? filePickerResult;
  File? pickedFile;

  List selectedImages=  [];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
    print(widget.to_person_number);
    print(widget.to_person_name);
  }

  get() async {
    prefs = await SharedPreferences.getInstance();
    var status = await Permission.camera.status;
    var status1 = await Permission.storage.status;
    if (status.isDenied && status1.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();
    }
    setState(() {});
  }


  String getdiff(DateTime d,ind)
  {
    final difference = DateTime.now().difference(d);

    if(difference.inMinutes < 1)
      {
       return "Just now";
      }
      else
      {
         return "${sorted[ind]['time'].substring(11, sorted[ind]['time'].length - 10)}";
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                "${widget.login_person_name} to ${widget.to_person_name} "),
            actions: [
              IconButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            Form(
                                child: Container(
                              child: Column(
                                children: [
                                  TextField(
                                      controller: chat,
                                      decoration: InputDecoration(
                                          hintText: "Text",
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: IconButton(
                                                onPressed: () async {
                                                  dt = DateTime.now();
                                                  DatabaseReference ref =
                                                      FirebaseDatabase.instance
                                                          .ref("chat")
                                                          .push();
                                                  await ref.set({
                                                    "from":
                                                        "${widget.login_person_number}",
                                                    "to":
                                                        "${widget.to_person_number}",
                                                    "msg":
                                                        "${chat.text.toString()}",
                                                    "time": "${dt}",
                                                  });
                                                  chat.clear();
                                                },
                                                icon: Icon(Icons.send,
                                                    color: Colors.green)),
                                          ))),
                                ],
                              ),
                            ))
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.add)),
              IconButton(
                  onPressed: () {
                    prefs!.setBool("login", false);

                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      },
                    ));
                    setState(() {});
                  },
                  icon: Icon(Icons.logout))
            ]),
        body: StreamBuilder(
          stream: starCountRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final data = snapshot.data!.snapshot.value;
              if (data != null && data is Map<dynamic, dynamic>) {
                // Perform the type cast

                Map m = data as Map;
                List value = m.values.toList();
                List key = m.keys.toList();




                for (int i = 0; i < value.length; i++) {
                  if (widget.to_person_number == value[i]['to'] && value[i]['is_read']=="false" &&
                      (widget.login_person_number == value[i]['from'] && widget.to_person_number==value[i]['to'])) {
                    DatabaseReference ref = FirebaseDatabase.instance.ref("chat").child(key[i]);
                   ref.update({
                     "is_read":"true",
                   });
                  }
                }

                value.sort((b, a) => a['time'].compareTo(b['time']));
                sorted=[];

                value.forEach((element) {
                  if((widget.login_person_number == element['from'] && widget.to_person_number==element['to'])
                      || (widget.login_person_number == element['to'] && widget.to_person_number==element['from'])
                  )
                  {
                    sorted.add(element);
                  }
                  //   print("${element}\n");
                });



              } else {
                print("its null");
              }


              sorted.forEach((element) {
                   print("${element}\n");
              });

              return Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: ListView.builder(
                          reverse: true,
                          itemCount: sorted.length,
                          itemBuilder: (context, index) {
                            return (widget.to_person_number == sorted
                            [index]['from'])?
                                  Row(mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          width: 1,color:(sorted[index]["image"]=="")? Colors.black12:Colors.transparent)),
                                  child:(sorted[index]["image"]=="")? Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${sorted[index]['msg']}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Baseline(
                                        baseline: 30,
                                        baselineType: TextBaseline.alphabetic,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:Text(getdiff(DateTime.parse(sorted[index]['time']),index),style: TextStyle(fontSize: 11)),
                                        ),
                                      ),
                                      Baseline(
                                        baseline: 30,
                                        baselineType: TextBaseline.alphabetic,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:(sorted[index]["is_read"]=="true")?Icon(Icons.check_circle_rounded,color:Colors.black,):Icon(Icons.check),
                                        ),
                                      )

                                    ],
                                  ):
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        image: (sorted[index]["image"]!="")
                                            ? DecorationImage(image: FileImage(File(sorted[index]["image"])))
                                            : null),
                                  ),
                                )
                              ],
                            )
                                : Row(mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color:(sorted[index]["image"]=="")? Colors.blue.shade50 :Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          width: 1, color:(sorted[index]["image"]=="")? Colors.black12:Colors.transparent)),
                                  child: (sorted[index]["image"]=="")? Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${sorted[index]['msg']}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Baseline(
                                        baseline: 30,
                                        baselineType: TextBaseline.alphabetic,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:Text(getdiff(DateTime.parse(sorted[index]['time']),index),style: TextStyle(fontSize: 11)),
                                        ),
                                      )
                                    ],
                                  ):
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        image: (sorted[index]["image"]!="")
                                            ? DecorationImage(image: FileImage(File(sorted[index]["image"])),fit:BoxFit.scaleDown)
                                            : null),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: TextField(
                          controller: chat,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                              hintText: "Text",
                              suffixIcon: Wrap(
                                children: [
                                  IconButton(onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Stack(
                                            children: [
                                              BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                                child: Container(
                                                  color: Colors.black.withOpacity(0.5),
                                                ),
                                              ),
                                              AlertDialog(
                                                title: Text("Uplode Image"),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () async {
                                                            image = await picker.getImage(
                                                                source: ImageSource.camera);

                                                            showDialog(
                                                                context:
                                                                context,
                                                                builder:
                                                                    (context) {
                                                                  return Stack(
                                                                    children: [
                                                                      BackdropFilter(
                                                                        filter: ImageFilter.blur(
                                                                            sigmaX: 5,
                                                                            sigmaY: 5),
                                                                        child:
                                                                        Container(
                                                                          color:
                                                                          Colors.black.withOpacity(0.5),
                                                                        ),
                                                                      ),
                                                                      AlertDialog(
                                                                        title:
                                                                        Text("Uplode Image"),
                                                                        actions: [
                                                                          Column(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              Container(
                                                                                width: 100,
                                                                                height: 100,
                                                                                decoration: BoxDecoration(image: (image != null) ? DecorationImage(image: FileImage(File(image!.path))) : null),
                                                                              ),
                                                                              TextButton(
                                                                                  onPressed: () async {

                                                                                    var dir_path = "${await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)}/CDMI";

                                                                                    Directory dir = Directory(dir_path);
                                                                                    if (!await dir.exists()) {
                                                                                      dir.create();
                                                                                    }

                                                                                    img_name = "myimg${Random().nextInt(1000)}.jpg";
                                                                                    File file = File("${dir.path}/${img_name}");
                                                                                    print("Imagepath:${file.path}");
                                                                                    file.writeAsBytes(await image!.readAsBytes());

                                                                                    dt = DateTime.now();
                                                                                    DatabaseReference ref = FirebaseDatabase.instance.ref("chat").push();
                                                                                    await ref.set({
                                                                                      "from": "${widget.login_person_number}",
                                                                                      "to": "${widget.to_person_number}",
                                                                                      "msg": "",
                                                                                      "time": "${dt}",
                                                                                      "is_read":"false",

                                                                                      "image": "${file.path.toString()}",
                                                                                    });
                                                                                    chat.clear();

                                                                                    setState(() {
                                                                                      Navigator.pop(context);
                                                                                      Navigator.pop(context);
                                                                                    });
                                                                                  },
                                                                                  child: Text("send")),
                                                                              ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text("close"))
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                });

                                                            setState(() {
                                                            });
                                                          },
                                                          child: Text("Camera")),
                                                      TextButton(
                                                          onPressed: () async {
                                                            image = await picker.getImage(
                                                                source: ImageSource.gallery);
                                                              // final pickedFile = await picker.pickMultiImage(
                                                              //     imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
                                                              // List<XFile> xfilePick = pickedFile;
                                                              //
                                                              // setState(
                                                              //       () {
                                                              //     if (xfilePick.isNotEmpty) {
                                                              //       for (var i = 0; i < xfilePick.length; i++) {
                                                              //         selectedImages.add(File(xfilePick[i].path));
                                                              //       }
                                                              //     } else {
                                                              //       ScaffoldMessenger.of(context).showSnackBar(
                                                              //           const SnackBar(content: Text('Nothing is selected')));
                                                              //     }
                                                              //   },
                                                              // );

                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return Stack(
                                                                      children: [
                                                                        BackdropFilter(
                                                                          filter: ImageFilter.blur(
                                                                              sigmaX: 5,
                                                                              sigmaY: 5),
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                Colors.black.withOpacity(0.5),
                                                                          ),
                                                                        ),
                                                                        AlertDialog(
                                                                          title:
                                                                              Text("Uplode Image"),
                                                                          actions: [
                                                                            Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Container(
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                  decoration: BoxDecoration(image: (image != null) ? DecorationImage(image: FileImage(File(image!.path))) : null),
                                                                                ),
                                                                                TextButton(
                                                                                    onPressed: () async {

                                                                                      var dir_path = "${await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)}/CDMI";

                                                                                      Directory dir = Directory(dir_path);
                                                                                      if (!await dir.exists()) {
                                                                                        dir.create();
                                                                                      }

                                                                                      img_name = "myimg${Random().nextInt(1000)}.jpg";
                                                                                      File file = File("${dir.path}/${img_name}");
                                                                                      print("Imagepath:${file.path}");
                                                                                      file.writeAsBytes(await image!.readAsBytes());

                                                                                      dt = DateTime.now();
                                                                                      DatabaseReference ref = FirebaseDatabase.instance.ref("chat").push();
                                                                                      await ref.set({
                                                                                        "from": "${widget.login_person_number}",
                                                                                        "to": "${widget.to_person_number}",
                                                                                        "msg": "",
                                                                                        "time": "${dt}",
                                                                                        "is_read":"false",

                                                                                        "image": "${file.path.toString()}",
                                                                                      });
                                                                                      chat.clear();

                                                                                      setState(() {
                                                                                        Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                      });
                                                                                    },
                                                                                    child: Text("send")),
                                                                                ElevatedButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text("close"))
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });

                                                              setState(() {
                                                            });
                                                          },
                                                          child: Text("Gallery")),
                                                      TextButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              Navigator.pop(context);
                                                            });
                                                          },
                                                          child: Text("Close"))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        });


                                  }, icon: Icon(Icons.attach_file,color: Colors.black)),

                                  Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: IconButton(
                                      onPressed: () async {
                                        dt = DateTime.now();
                                        DatabaseReference ref = FirebaseDatabase
                                            .instance
                                            .ref("chat")
                                            .push();
                                        await ref.set({
                                          "from": "${widget.login_person_number}",
                                          "to": "${widget.to_person_number}",
                                          "msg": "${chat.text}",
                                          "time": "${dt}",
                                          "is_read":"false",
                                          "image": "",

                                        });
                                        chat.clear();


                                      },
                                      icon:
                                          Icon(Icons.send, color: Colors.green)),
                                ),
                                ]
                              )
                          )
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

