import 'package:flutter/material.dart';
import '../services/social_service.dart';

class NewPostButton extends StatelessWidget {
  final Function() onPostCreated;

  const NewPostButton({
    super.key,
    required this.onPostCreated,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => _NewPostSheet(
            onPostCreated: onPostCreated,
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class _NewPostSheet extends StatefulWidget {
  final Function() onPostCreated;

  const _NewPostSheet({
    required this.onPostCreated,
  });

  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _contentController = TextEditingController();
  final _socialService = SocialService();
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking
    setState(() {
      _imageUrl = 'https://picsum.photos/400/300'; // Placeholder image
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _socialService.createPost(
        content: _contentController.text,
        imageUrl: _imageUrl,
      );
      widget.onPostCreated();
      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
              ),
              maxLines: 4,
              autofocus: true,
            ),
            const SizedBox(height: 16.0),
            if (_imageUrl != null)
              Stack(
                children: [
                  Image.network(
                    _imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => setState(() => _imageUrl = null),
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                ),
                const Spacer(),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _createPost,
                    child: const Text('Post'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
