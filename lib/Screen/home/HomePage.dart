import 'package:chat_app/Componants/textfield.dart';
import 'package:chat_app/Screen/chat/ChatPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  String name;
  String number;
  HomePage(this.name, this.number);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController name=TextEditingController();
  TextEditingController mobile=TextEditingController();
  List key = [];
  List value = [];
  List sorted = [];
  SharedPreferences? prefs;
  String mainname = "";
  String mainnumber = "";

  DatabaseReference starCountRef = FirebaseDatabase.instance.ref('user');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      Map m = data as Map;
      key = m.keys.toList();
      value = m.values.toList();
      setState(() {});
    });
  }

  get()
  async {
    prefs = await SharedPreferences.getInstance();
   mainname  = prefs?.getString('name')?? "";
   mainnumber  = prefs?.getString('number')?? "";

   print(prefs?.getString('name'));

  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("loged as ${mainname}"),
          actions: [IconButton(onPressed:  () async {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          actions: [
            Form(child: Container(
              child: Column(
                children: [
                  Mytextfield(controller: name, hintText: "name", obscuretext: false),
                  Mytextfield(controller: mobile, hintText: "mobile", obscuretext: false),
                  ElevatedButton(onPressed: () async {
                    DatabaseReference ref = FirebaseDatabase.instance.ref("user").push();
                    await ref.set({
                      "name":"${name.text}",
                      "contact":"${mobile.text}",
                    });
                    Navigator.pop(context);
                  }, child: Text("Add")),
                ],
              ),
            ))
          ],
        );
      },);

      }, icon: Icon(Icons.add))]
      ),
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

              } else {
               print("its null");
              }



              print("valueee ${value}");

              value.forEach((element) {
                sorted.add(element["name"]);
              });
              sorted.sort((a, b){ //sorting in ascending order
                return a.compareTo(b);
              });
              return ListView.builder(reverse: false,shrinkWrap: true,
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return InkWell(onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ChatPage("${value[index]['name']}","${value[index]['contact']}",mainname,mainnumber);
                    },));
                  },
                    child: Card(
                      child: ListTile(
                        title: Text("${value[index]['name']}"),
                        trailing: Wrap(children: [
                        InkWell(
                          onTap: () {
                            DatabaseReference ref = FirebaseDatabase.instance
                                .ref("user")
                                .child(key[index]);
                            ref.remove();
                            setState(() {});
                          },
                          child: Icon(
                            Icons.delete,
                          ),
                        ),

                      ]),
                      ),
                    ),
                  );
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        )
    );
  }
}
