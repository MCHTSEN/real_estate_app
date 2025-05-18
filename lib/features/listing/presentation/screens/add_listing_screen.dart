import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:real_estate_app/features/auth/providers/auth_provider.dart';
import 'package:real_estate_app/features/home/providers/listing_provider.dart';

// State providers for form
final typeProvider = StateProvider<String>((ref) => 'sell');
final imageFilesProvider = StateProvider<List<File>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Location data providers
final selectedCityProvider = StateProvider<String?>((ref) => null);
final selectedDistrictProvider = StateProvider<String?>((ref) => null);
final selectedNeighborhoodProvider = StateProvider<String?>((ref) => null);

// Location data
final Map<String, List<String>> cityDistricts = {
  'İstanbul': ['Kadıköy', 'Beşiktaş', 'Üsküdar', 'Şişli', 'Maltepe'],
  'Ankara': ['Çankaya', 'Keçiören', 'Yenimahalle', 'Mamak', 'Etimesgut'],
  'İzmir': ['Karşıyaka', 'Bornova', 'Konak', 'Buca', 'Çiğli'],
  'Bursa': ['Nilüfer', 'Osmangazi', 'Yıldırım', 'Mudanya', 'Gemlik'],
  'Antalya': ['Muratpaşa', 'Konyaaltı', 'Kepez', 'Alanya', 'Manavgat'],
};

final Map<String, Map<String, List<String>>> districtNeighborhoods = {
  'Kadıköy': {
    'Merkez': ['Caferağa', 'Osmanağa', 'Rasimpaşa'],
    'Sahil': ['Caddebostan', 'Suadiye', 'Fenerbahçe'],
  },
  'Beşiktaş': {
    'Merkez': ['Sinanpaşa', 'Türkali', 'Vişnezade'],
    'Sahil': ['Ortaköy', 'Arnavutköy', 'Bebek'],
  },
  // Add more districts and neighborhoods as needed
};

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _squareMetersController = TextEditingController();
  final _roomCountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillWithMockData();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _squareMetersController.dispose();
    _roomCountController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Mock data generator
  void _fillWithMockData() {
    if (!kDebugMode) return;

    final random = Random();

    final titles = [
      'Ferah ve Aydınlık Daire',
      'Merkezi Konumda Lüks Konut',
      'Yeni Yapı Satılık Daire',
      'Deniz Manzaralı Modern Daire',
      'Bahçeli Müstakil Ev'
    ];

    final descriptions = [
      'Merkezi konumda, yeni yapı, full eşyalı daire. Metro ve alışveriş merkezlerine yakın.',
      'Geniş ve ferah iç mekan, yüksek tavanlı, açık mutfak konseptli daire.',
      'Site içerisinde güvenlikli, otoparklı, sosyal olanaklara sahip modern daire.',
      'Doğa manzaralı, geniş balkonlu, yeni tadilatlı daire.',
      'Bahçe kullanımlı, müstakil girişli, 2 katlı ev.'
    ];

    final cities = cityDistricts.keys.toList();
    final city = cities[random.nextInt(cities.length)];
    final districts = cityDistricts[city]!;
    final district = districts[random.nextInt(districts.length)];

    final names = [
      'Ahmet Yılmaz',
      'Mehmet Demir',
      'Ayşe Kaya',
      'Fatma Öztürk',
      'Ali Can'
    ];

    ref.read(typeProvider.notifier).state = random.nextBool() ? 'sell' : 'rent';
    ref.read(selectedCityProvider.notifier).state = city;
    ref.read(selectedDistrictProvider.notifier).state = district;

    _titleController.text = titles[random.nextInt(titles.length)];
    _descriptionController.text =
        descriptions[random.nextInt(descriptions.length)];
    _priceController.text = (random.nextInt(9000) + 1000).toString();
    _squareMetersController.text = (random.nextInt(150) + 50).toString();
    _roomCountController.text = (random.nextInt(4) + 1).toString();
    _nameController.text = names[random.nextInt(names.length)];
    _phoneController.text = '05${random.nextInt(100000000) + 300000000}';
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
      }
    } catch (e) {
      developer.log('Error picking image: $e');
    }
  }

  Widget _buildTypeSelector() {
    final listingType = ref.watch(typeProvider);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlan Türü',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    title: 'Satılık',
                    value: 'sell',
                    isSelected: listingType == 'sell',
                    onTap: () => ref.read(typeProvider.notifier).state = 'sell',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    title: 'Kiralık',
                    value: 'rent',
                    isSelected: listingType == 'rent',
                    onTap: () => ref.read(typeProvider.notifier).state = 'rent',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final images = ref.watch(imageFilesProvider);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fotoğraflar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Ekle'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (images.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Henüz fotoğraf eklenmedi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
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
                                final updatedImages = List<File>.from(images);
                                updatedImages.removeAt(index);
                                ref.read(imageFilesProvider.notifier).state =
                                    updatedImages;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final selectedCity = ref.watch(selectedCityProvider);
    final selectedDistrict = ref.watch(selectedDistrictProvider);
    final selectedNeighborhood = ref.watch(selectedNeighborhoodProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konum Bilgileri',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCity,
              decoration: const InputDecoration(
                labelText: 'Şehir',
                border: OutlineInputBorder(),
              ),
              items: cityDistricts.keys.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (String? newValue) {
                ref.read(selectedCityProvider.notifier).state = newValue;
                ref.read(selectedDistrictProvider.notifier).state = null;
                ref.read(selectedNeighborhoodProvider.notifier).state = null;
              },
              validator: (value) => value == null ? 'Lütfen şehir seçin' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: const InputDecoration(
                labelText: 'İlçe',
                border: OutlineInputBorder(),
              ),
              items: selectedCity != null
                  ? cityDistricts[selectedCity]!.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList()
                  : [],
              onChanged: selectedCity == null
                  ? null
                  : (String? newValue) {
                      ref.read(selectedDistrictProvider.notifier).state =
                          newValue;
                      ref.read(selectedNeighborhoodProvider.notifier).state =
                          null;
                    },
              validator: (value) => value == null ? 'Lütfen ilçe seçin' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetailsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlan Detayları',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'İlan Başlığı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Lütfen başlık girin' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) =>
                  value?.isEmpty == true ? 'Lütfen açıklama girin' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Fiyat (TL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Lütfen fiyat girin';
                if (int.tryParse(value!) == null)
                  return 'Geçerli bir sayı girin';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyFeaturesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Özellikler',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                      prefixIcon: Icon(Icons.square_foot),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Metrekare girin';
                      if (int.tryParse(value!) == null)
                        return 'Geçerli bir sayı girin';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _roomCountController,
                    decoration: const InputDecoration(
                      labelText: 'Oda Sayısı',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Oda sayısı girin';
                      if (int.tryParse(value!) == null)
                        return 'Geçerli bir sayı girin';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İletişim Bilgileri',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Ad soyad girin' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty == true ? 'Telefon girin' : null,
            ),
          ],
        ),
      ),
    );
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

    if (ref.read(imageFilesProvider).isEmpty) {
      developer.log('No images selected.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir fotoğraf eklemelisiniz')),
      );
      return;
    }

    final selectedCity = ref.read(selectedCityProvider);
    final selectedDistrict = ref.read(selectedDistrictProvider);

    if (selectedCity == null || selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen konum bilgilerini eksiksiz doldurun')),
      );
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final listingId = DateTime.now().millisecondsSinceEpoch.toString();
      developer.log('Generated listing ID: $listingId');

      final imageUrls = await _uploadImages(listingId);

      final listingData = {
        'userId': user.uid,
        'userPhone': _phoneController.text.trim(),
        'userName': _nameController.text.trim(),
        'type': ref.read(typeProvider),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'location': '$selectedCity/$selectedDistrict',
        'squareMeters': int.parse(_squareMetersController.text.trim()),
        'roomCount': int.parse(_roomCountController.text.trim()),
        'imageUrls': imageUrls,
        'createdAt': DateTime.now().toIso8601String(),
      };
      developer.log('Listing data: $listingData');

      await ref.read(listingRepositoryProvider).addListing(listingData);
      developer.log('Listing added to Firestore successfully.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İlan başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      developer.log('Error submitting listing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
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
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_by': 'app_user'},
        );

        final uploadTask = storageRef.putFile(file, metadata);
        await uploadTask.whenComplete(() => null);

        final downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
        developer.log('Image $i uploaded successfully: $downloadUrl');
      } catch (e) {
        developer.log('Error uploading image $i: $e');
      }
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Ekle'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildTypeSelector(),
                const SizedBox(height: 16),
                _buildImageSection(),
                const SizedBox(height: 16),
                _buildLocationSection(),
                const SizedBox(height: 16),
                _buildPropertyDetailsSection(),
                const SizedBox(height: 16),
                _buildPropertyFeaturesSection(),
                const SizedBox(height: 16),
                _buildContactSection(),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'İlanı Yayınla',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
