import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery/api/posts_api.dart';
import 'package:image_gallery/models/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreatePostPage2 extends StatefulWidget {
  final bool isEditMode;
  final Post? post;
  const CreatePostPage2({super.key, required this.isEditMode, this.post});

  @override
  State<CreatePostPage2> createState() => _CreatePostPage2State();
}

class _CreatePostPage2State extends State<CreatePostPage2> {
  File? imageFile;
  UploadTask? uploadTask;
  String imageUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.isEditMode) {
      imageUrl = widget.post!.imageUrl;
    }
  }

  void clearPost() {
    setState(() {
      imageUrl = "";
      uploadTask = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Post"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Center(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all()),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text(
                                  "From where do you want to take the image?"),
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextButton(
                                    child: const Text("Gallery"),
                                    onPressed: () {
                                      _getFromGallery();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("Camera"),
                                    onPressed: () {
                                      _getFromCamera();
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ),
                            ));
                  },
                  child: imageUrl == ""
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 150,
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 200,
                          width: 200,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 48,
            width: 200,
            child: ElevatedButton(
                onPressed: () => createPost(),
                child: const Text("Post Picture")),
          )
        ],
      ),
      bottomNavigationBar:
          uploadTask != null ? buildProgress() : const SizedBox(),
    );
  }

  Future _getFromCamera() async {
    XFile? result = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 400, maxHeight: 400);
    if (result == null) return;
    setState(() {
      imageFile = File(result.path);
    });
    uploadFile();
  }

  Future _getFromGallery() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      imageFile = File(result.files.single.path.toString());
    });
    uploadFile();
  }

  Future uploadFile() async {
    final ramdomNumber = Random().nextInt(999999);
    final imageFileName = imageFile!.path.split("/").last;
    final imageFileNames = imageFileName.split(".");
    final path =
        "files/${imageFileNames[0]}_$ramdomNumber.${imageFileNames[1]}";
    final ref = FirebaseStorage.instance.ref().child(path);

    //ref.putFile(imageFile!);

    setState(() {
      uploadTask = ref.putFile(imageFile!);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final imageUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      this.imageUrl = imageUrl;
    });
  }

  Future createPost() async {
    final postId = getId();
    final post = Post(
      id: postId,
      createdAt: Timestamp.now(),
      imageUrl: imageUrl,
      //content: _bodyTextController.text,
    );
    PostsApi.createPost(post).whenComplete(() {
      const snackBar = SnackBar(content: Text("Yay! Post Created!"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
    Navigator.pop(context);
  }

  Widget buildProgress() {
    return StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                  Center(
                    child: Text(
                      "${(100 * progress).roundToDouble()}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox(
              height: 0,
            );
          }
        });
  }

  String getId() {
    DateTime now = DateTime.now();
    String timestamp = DateFormat("yyyyMMddHHmmss").format(now);
    return timestamp;
  }
}
