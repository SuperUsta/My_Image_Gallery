import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery/api/posts_api.dart';
import 'package:image_gallery/models/post.dart';
import 'package:path_provider/path_provider.dart';

class ImagePage extends StatefulWidget {
  final Post post;
  const ImagePage({super.key, required this.post});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  Future downloadFile(String url) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = url.split("files%").last.split("?").first;
    final path = "${tempDir.path}/$fileName";
    await Dio().download(url, path);

    if (url.contains(".mp4")) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains(".jpg")) {
      await GallerySaver.saveImage(path, toDcim: true);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Downloaded $fileName")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Image"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => downloadFile(widget.post.imageUrl),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    "Downlod Image",
                  ),
                  Icon(Icons.download, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Hero(
              tag: "image",
              child: Image.network(
                widget.post.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: BottomAppBar(
          child: TextButton(
            onPressed: deletePost,
            child: const SizedBox(
              height: 60,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      size: 40,
                      color: Colors.red,
                    ),
                    Text(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      "Delete",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future deletePost() async {
    PostsApi.delete(widget.post.id).whenComplete(() {
      const snackbar = SnackBar(content: Text("Ohh! Post Deleted"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
    Navigator.pop(context);
  }
}
