import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/shared_preferences.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String databaseUrl =
    "https://relieflink-e824d-default-rtdb.firebaseio.com";

// Fetch universalId from SharedPreferences
Future<String> getUniversalId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('universalId') ?? 'Sign Up/ Login to view details';
}

// Add Post to Firebase Realtime Database
Future<void> addPost(String title, String description) async {
  try {
    final url = Uri.parse("$databaseUrl/posts.json");
    String userId = await getUniversalId();

    await http.post(
      url,
      body: jsonEncode({
        'title': title,
        'description': description,
        'userId': userId,
        'likes': 0,
        'likedByUser': false, // New field to track likes per user
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  } catch (e) {
    print("Error adding post: $e");
  }
}

// Like/Dislike function with a bool flag
Future<int> toggleLikePost(String postId, int currentLikes) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool liked = prefs.getBool('liked_$postId') ??
        false; // Check if user has liked before
    final url = Uri.parse("$databaseUrl/posts/$postId.json");

    int newlikes = liked ? currentLikes - 1 : currentLikes + 1;

    await http.patch(
      url,
      body: jsonEncode({'likes': liked ? currentLikes - 1 : currentLikes + 1}),
    );

    prefs.setBool('liked_$postId', !liked); // Toggle the like state
    return newlikes;
  } catch (e) {
    print("Error toggling like: $e");
    return currentLikes;
  }
}

// Comment on a Post
Future<void> addComment(String postId, String text) async {
  try {
    final url = Uri.parse("$databaseUrl/posts/$postId/comments.json");
    String userId = await getUniversalId();

    await http.post(
      url,
      body: jsonEncode({
        'userId': userId,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  } catch (e) {
    print("Error adding comment: $e");
  }
}

class CommunityForum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Community Discussion".tr)),
      body: PostList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (logStatus) {
            _showPostDialog(context);
          } else {
            _showLoginDialog(context);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create a Post".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title".tr)),
              TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description".tr)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel".tr)),
            TextButton(
              onPressed: () {
                addPost(titleController.text, descriptionController.text);
                Navigator.pop(context);
              },
              child: Text("Post".tr),
            ),
          ],
        );
      },
    );
  }
}

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  List<Map<String, dynamic>> posts = [];
  Map<String, List<Map<String, dynamic>>> comments = {};

  Future<void> fetchPosts() async {
    try {
      final url = Uri.parse("$databaseUrl/posts.json");
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body != "null") {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          posts = data.entries.map((entry) {
            return {
              'id': entry.key,
              'title': entry.value['title'],
              'description': entry.value['description'],
              'likes': entry.value['likes'],
            };
          }).toList();
        });

        for (var post in posts) {
          fetchComments(post['id']);
        }
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  Future<void> fetchComments(String postId) async {
    try {
      final url = Uri.parse("$databaseUrl/posts/$postId/comments.json");
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body != "null") {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          comments[postId] = data.entries.map((entry) {
            return {
              'userId': entry.value['userId'],
              'text': entry.value['text'],
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return posts.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Title in Bold
                      Text(
                        post['title'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(post['description']),
                      SizedBox(height: 10),

                      // Like & Comment buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FutureBuilder<bool>(
                            future: _hasLikedPost(post['id']),
                            builder: (context, snapshot) {
                              bool liked = snapshot.data ?? false;
                              return Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.thumb_up,
                                      color: liked ? Colors.blue : null,
                                    ),
                                    onPressed: () async {
                                      int updatelikes = await toggleLikePost(
                                          post['id'], post['likes']);
                                      setState(() {
                                        posts[index]['likes'] = updatelikes;
                                      });
                                    },
                                  ),
                                  Text("${post['likes']} Likes".tr),
                                ],
                              );
                            },
                          ),
                          IconButton(
                              icon: Icon(Icons.comment),
                              onPressed: () {
                                if (logStatus) {
                                  _showCommentDialog(context, post['id']);
                                } else {
                                  _showLoginDialog(context);
                                }
                              }),
                        ],
                      ),

                      // Display Comments
                      if (comments.containsKey(post['id']) &&
                          comments[post['id']]!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Comments".tr,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ...comments[post['id']]!.map((comment) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                      "${comment['userId']}: ${comment['text']}"),
                                )),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Future<bool> _hasLikedPost(String postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('liked_$postId') ?? false;
  }

  void _showCommentDialog(BuildContext context, String postId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Comment".tr),
          content: TextField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Comment".tr)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel".tr)),
            TextButton(
              onPressed: () {
                addComment(postId, commentController.text);
                Navigator.pop(context);
              },
              child: Text("Comment".tr),
            ),
          ],
        );
      },
    );
  }
}

void _showLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Login Required'.tr),
      content: Text('You need to login to comment/post. Please login first.'.tr),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:  Text('Cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => LoginScreen()),
            );
          },
          child:  Text('Login'.tr),
        ),
      ],
    ),
  );
}
