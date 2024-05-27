import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery/api/posts_api.dart';
import 'package:image_gallery/models/post.dart';
import 'package:image_gallery/pages/create_post_page.dart';
import 'package:image_gallery/pages/image_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("My Gallery"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          )
        ],
      ),
      body: StreamBuilder<List<Post>>(
          stream: PostsApi.readPosts(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final posts = snapshot.data!;
              return GridView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImagePage(
                                    post: posts[index],
                                  ))),
                      child: Stack(children: [
                        Hero(
                          tag: "image",
                          child: Image.network(
                            posts[index].imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ]),
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
              );
            } else {
              return const SizedBox();
            }
          }),
      bottomNavigationBar: BottomAppBar(
        child: TextButton(
          child: const SizedBox(
              height: 60,
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload,
                    size: 40,
                  ),
                  Text(
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      "Upload"),
                ],
              ))),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const CreatePostPage(isEditMode: false))),
        ),
      ),
    );
  }
}
