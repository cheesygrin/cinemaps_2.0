import 'package:flutter/material.dart';
import '../models/social_post.dart';

class SocialFeedList extends StatelessWidget {
  final List<SocialPost> posts;
  final Function(String) onLike;
  final Function(String, String) onComment;

  const SocialFeedList({
    super.key,
    required this.posts,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(post.userAvatarUrl),
                ),
                title: Text(post.username),
                subtitle: Text(post.timestamp.toString()),
              ),
              if (post.imageUrl != null)
                Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(post.content),
              ),
              OverflowBar(
                children: [
                  TextButton.icon(
                    onPressed: () => onLike(post.id),
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : null,
                    ),
                    label: Text('${post.likeCount}'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _CommentSheet(
                          postId: post.id,
                          onComment: onComment,
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                    label: Text('${post.commentCount}'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final String postId;
  final Function(String, String) onComment;

  const _CommentSheet({
    required this.postId,
    required this.onComment,
  });

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                ),
                autofocus: true,
              ),
            ),
            IconButton(
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  widget.onComment(widget.postId, _commentController.text);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
