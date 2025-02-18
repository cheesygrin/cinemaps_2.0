import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../models/review.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onLike;
  final Function(String) onComment;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: CinemapsTheme.hotPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewHeader(),
            const SizedBox(height: 16),
            _buildReviewContent(),
            if (review.photos.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPhotoGrid(),
            ],
            const SizedBox(height: 16),
            _buildInteractionBar(),
            if (review.comments.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildComments(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: CinemapsTheme.hotPink,
          child: Text(
              review.username[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat.yMMMd().format(review.timestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 16,
              color: index < review.rating
                  ? CinemapsTheme.neonYellow
                  : Colors.white.withOpacity(0.3),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReviewContent() {
    return Text(
      review.comment,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: review.photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                review.photos[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractionBar() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.favorite,
            color: review.likeCount > 0
                ? CinemapsTheme.hotPink
                : Colors.white.withOpacity(0.5),
            size: 20,
          ),
          onPressed: onLike,
        ),
        Text(
          review.likeCount.toString(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            Icons.comment,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          onPressed: () => onComment(''),
        ),
        Text(
          review.comments.length.toString(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: CinemapsTheme.hotPink),
        const SizedBox(height: 8),
        ...review.comments.map((comment) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: CinemapsTheme.hotPink,
                    child: Text(
                            comment.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat.yMMMd().format(comment.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          comment.content,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _showCommentDialog(BuildContext context) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text(
          'Add Comment',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: commentController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: CinemapsTheme.hotPink.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: CinemapsTheme.hotPink.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: CinemapsTheme.hotPink,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                onComment(commentController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CinemapsTheme.hotPink,
            ),
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}
