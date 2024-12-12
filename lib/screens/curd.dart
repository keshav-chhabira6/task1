import 'package:flutter/material.dart';
import '../model/post.dart';
import '../services/api.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _apiService.fetchPosts();
  }

  void _showCreatePostForm() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Post'),
          content: Column(
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  setState(() {
                    _posts = _apiService.fetchPosts();
                  });
                  Navigator.pop(context);
                } catch (e) {
                  // Handle error
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPostForm(Post post) {
    final titleController = TextEditingController(text: post.title);
    final bodyController = TextEditingController(text: post.body);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: Column(
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final updatedPost = Post(
                    id: post.id,
                    title: titleController.text,
                    body: bodyController.text);
                try {
                  await _apiService.updatePost(post.id, updatedPost);
                  setState(() {
                    _posts = _apiService.fetchPosts();
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } catch (e) {
                  // Handle error
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(int postId) async {
    try {
      await _apiService.deletePost(postId);
      setState(() {
        _posts = _apiService.fetchPosts();
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePostForm,
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Posts Found'));
          } else {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    child: ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.body),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditPostForm(post),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deletePost(post.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
