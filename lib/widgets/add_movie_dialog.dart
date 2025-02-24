import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class AddMovieDialog extends StatefulWidget {
  const AddMovieDialog({Key? key}) : super(key: key);

  @override
  State<AddMovieDialog> createState() => _AddMovieDialogState();
}

class _AddMovieDialogState extends State<AddMovieDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _overviewController = TextEditingController();
  final _releaseYearController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();
  final _locationDescriptionController = TextEditingController();
  final List<Map<String, dynamic>> _locations = [];

  @override
  void dispose() {
    _titleController.dispose();
    _overviewController.dispose();
    _releaseYearController.dispose();
    _locationNameController.dispose();
    _locationAddressController.dispose();
    _locationDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _addLocation() async {
    if (_locationNameController.text.isEmpty ||
        _locationAddressController.text.isEmpty ||
        _locationDescriptionController.text.isEmpty) {
      return;
    }

    try {
      final locations = await locationFromAddress(_locationAddressController.text);
      if (locations.isNotEmpty) {
        setState(() {
          _locations.add({
            'name': _locationNameController.text,
            'address': _locationAddressController.text,
            'description': _locationDescriptionController.text,
            'latitude': locations.first.latitude,
            'longitude': locations.first.longitude,
          });
        });

        _locationNameController.clear();
        _locationAddressController.clear();
        _locationDescriptionController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to geocode address. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Movie',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _overviewController,
                decoration: const InputDecoration(
                  labelText: 'Overview',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an overview';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _releaseYearController,
                decoration: const InputDecoration(
                  labelText: 'Release Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a release year';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1888 || year > DateTime.now().year) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Add Filming Locations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationNameController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationAddressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addLocation,
                icon: const Icon(Icons.add_location),
                label: const Text('Add Location'),
              ),
              const SizedBox(height: 16),
              if (_locations.isNotEmpty) ...[
                Text(
                  'Added Locations:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return Card(
                      child: ListTile(
                        title: Text(location['name']),
                        subtitle: Text(location['address']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeLocation(index),
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'title': _titleController.text,
                          'overview': _overviewController.text,
                          'releaseYear': int.parse(_releaseYearController.text),
                          'locations': _locations,
                        });
                      }
                    },
                    child: const Text('Add Movie'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 