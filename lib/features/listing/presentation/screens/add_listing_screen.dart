import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:real_estate_app/features/auth/providers/auth_provider.dart';
import 'package:real_estate_app/features/home/providers/listing_provider.dart';

// State providers for form
final typeProvider = StateProvider<String>((ref) => 'sell'); // Default to sell
final imageFilesProvider = StateProvider<List<File>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _squareMetersController = TextEditingController();
  final _roomCountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _neighborhoodController.dispose();
    _squareMetersController.dispose();
    _roomCountController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    developer.log('Picking image...');
    final imagePicker = ImagePicker();
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final images = ref.read(imageFilesProvider);
        ref.read(imageFilesProvider.notifier).state = [
          ...images,
          File(pickedFile.path)
        ];
        developer.log('Image picked successfully: ${pickedFile.path}');
      } else {
        developer.log('No image picked.');
      }
    } catch (e) {
      developer.log('Error picking image: $e');
    }
  }

  Future<List<String>> _uploadImages(String listingId) async {
    developer.log('Uploading images for listing ID: $listingId');
    final images = ref.read(imageFilesProvider);
    final List<String> imageUrls = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('listings')
          .child(listingId)
          .child('image_$i.jpg');

      try {
        // Create metadata
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_by': 'app_user'},
        );

        // Upload with metadata
        final uploadTask = storageRef.putFile(file, metadata);
        await uploadTask.whenComplete(() => null);

        final downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
        developer.log('Image $i uploaded successfully: $downloadUrl');
      } catch (e) {
        developer.log('Error uploading image $i: $e');
        // Consider handling the error more gracefully, e.g., by returning an error list
      }
    }

    developer.log('All images uploaded. Image URLs: $imageUrls');
    return imageUrls;
  }

  Future<void> _submitListing() async {
    developer.log('Submitting listing...');
    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed.');
      return;
    }

    final user = ref.read(authProvider).value;
    if (user == null) {
      developer.log('User not logged in.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş yapmanız gerekiyor')),
      );
      return;
    }

    // Check if images exist
    if (ref.read(imageFilesProvider).isEmpty) {
      developer.log('No images selected.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir fotoğraf eklemelisiniz')),
      );
      return;
    }

    // Set loading
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      // Create a unique listing ID
      final listingId = DateTime.now().millisecondsSinceEpoch.toString();
      developer.log('Generated listing ID: $listingId');

      // Upload images
      final imageUrls = await _uploadImages(listingId);

      // Create listing data
      final listingData = {
        'userId': user.uid,
        'userPhone': _phoneController.text.trim(),
        'userName': _nameController.text.trim(),
        'type': ref.read(typeProvider), // 'sell' or 'rent'
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'location':
            '${_cityController.text.trim()}/${_districtController.text.trim()}',
        'neighborhood': _neighborhoodController.text.trim(),
        'squareMeters': int.parse(_squareMetersController.text.trim()),
        'roomCount': int.parse(_roomCountController.text.trim()),
        'imageUrls': imageUrls,
      };
      developer.log('Listing data: $listingData');

      // Save to Firestore
      await ref.read(listingRepositoryProvider).addListing(listingData);
      developer.log('Listing added to Firestore successfully.');

      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan başarıyla eklendi')),
        );
        context.go('/home');
      }
    } catch (e) {
      developer.log('Error submitting listing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      // Reset loading
      ref.read(isLoadingProvider.notifier).state = false;
      developer.log('Loading state reset.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingType = ref.watch(typeProvider);
    final images = ref.watch(imageFilesProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Listing type selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İlan Türü',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Satılık'),
                            value: 'sell',
                            groupValue: listingType,
                            onChanged: (value) {
                              ref.read(typeProvider.notifier).state = value!;
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Kiralık'),
                            value: 'rent',
                            groupValue: listingType,
                            onChanged: (value) {
                              ref.read(typeProvider.notifier).state = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Images section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fotoğraflar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (images.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      images[index],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        final updatedImages =
                                            List<File>.from(images);
                                        updatedImages.removeAt(index);
                                        ref
                                            .read(imageFilesProvider.notifier)
                                            .state = updatedImages;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Fotoğraf Ekle'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Property details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İlan Bilgileri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'İlan Başlığı',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir başlık girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir açıklama girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (TL)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir fiyat girin';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Konum Bilgileri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'Şehir',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şehir girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _districtController,
                            decoration: const InputDecoration(
                              labelText: 'İlçe',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'İlçe girin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Mahalle',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mahalle girin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Property features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Özellikler',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _squareMetersController,
                            decoration: const InputDecoration(
                              labelText: 'Metrekare (m²)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Değer girin';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Geçerli bir sayı girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _roomCountController,
                            decoration: const InputDecoration(
                              labelText: 'Oda Sayısı',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Değer girin';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Geçerli bir sayı girin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İletişim Bilgileri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ad soyad girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Telefon girin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'İlanı Yayınla',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
