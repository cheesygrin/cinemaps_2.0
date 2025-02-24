import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/photo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cinemaps/services/supabase_service.dart';

class GalleryPage extends StatefulWidget {
  final String? locationId;
  final String userId;

  const GalleryPage({
    super.key,
    this.locationId,
    required this.userId,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  final PhotoService _photoService = PhotoService();
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;
  final List<String> _selectedTags = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _uploadPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // Show dialog to add caption and tags
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UploadDialog(),
    );

    if (result != null) {
      await _photoService.uploadPhoto(
        locationId: widget.locationId ?? 'general',
        imagePath: image.path,
        caption: result['caption'] as String,
        userId: widget.userId,
        tags: (result['tags'] as String)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: Text(
          widget.locationId != null ? 'LOCATION GALLERY' : 'PHOTO GALLERY',
          style: const TextStyle(
            color: CinemapsTheme.neonYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CinemapsTheme.hotPink,
          tabs: const [
            Tab(text: 'RECENT'),
            Tab(text: 'SEARCH'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentPhotos(),
          _buildPhotoSearch(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPhoto,
        backgroundColor: CinemapsTheme.hotPink,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  Widget _buildRecentPhotos() {
    final photos = widget.locationId != null
        ? _photoService.getPhotosForLocation(widget.locationId!)
        : _photoService.recentPhotos;

    return photos.isEmpty
        ? _buildEmptyState()
        : GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) => _buildPhotoTile(photos[index]),
          );
  }

  Widget _buildPhotoSearch() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search photos...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: CinemapsTheme.hotPink,
                ),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        _buildTagChips(),
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildTagChips() {
    final popularTags = _photoService.getPopularTags();
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularTags.length,
        itemBuilder: (context, index) {
          final tag = popularTags[index];
          final isSelected = _selectedTags.contains(tag);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: CinemapsTheme.hotPink,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.1),
              labelStyle: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchText = _searchController.text.toLowerCase();
    final photos = _photoService
        .searchPhotos(
      locationId: widget.locationId,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
    )
        .where((photo) {
      if (searchText.isEmpty) return true;
      return photo.caption.toLowerCase().contains(searchText) ||
          photo.tags.any((tag) => tag.toLowerCase().contains(searchText));
    }).toList();

    return photos.isEmpty
        ? _buildEmptyState()
        : GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) => _buildPhotoTile(photos[index]),
          );
  }

  Widget _buildPhotoTile(LocationPhoto photo) {
    return GestureDetector(
      onTap: () => _showPhotoDetails(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CinemapsTheme.hotPink.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                photo.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white54,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: photo.likeCount > 0
                            ? CinemapsTheme.hotPink
                            : Colors.white54,
                      ),
                      Text(
                        '${photo.likeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoDetails(LocationPhoto photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PhotoDetailsSheet(
        photo: photo,
        userId: widget.userId,
        photoService: _photoService,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No photos yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share a photo!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadDialog extends StatefulWidget {
  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  final _captionController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      title: const Text(
        'Add Photo Details',
        style: TextStyle(color: CinemapsTheme.neonYellow),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _captionController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Caption',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: CinemapsTheme.hotPink),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagsController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Tags (comma-separated)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: CinemapsTheme.hotPink),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {
            'caption': _captionController.text,
            'tags': _tagsController.text,
          }),
          child: const Text(
            'UPLOAD',
            style: TextStyle(color: CinemapsTheme.hotPink),
          ),
        ),
      ],
    );
  }
}

class _PhotoDetailsSheet extends StatelessWidget {
  final LocationPhoto photo;
  final String userId;
  final PhotoService photoService;

  const _PhotoDetailsSheet({
    required this.photo,
    required this.userId,
    required this.photoService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: CinemapsTheme.deepSpaceBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 160,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      photo.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat.yMMMd().format(photo.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: photo.likeCount > 0
                                    ? CinemapsTheme.hotPink
                                    : Colors.white54,
                              ),
                              onPressed: () =>
                                  photoService.likePhoto(photo.id, userId),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          photo.caption,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: photo.tags.map((tag) {
                            return Chip(
                              label: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor:
                                  CinemapsTheme.hotPink.withOpacity(0.3),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
