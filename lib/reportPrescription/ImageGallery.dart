import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<String> _imageUrls = [];

  // Picker instance to select images
  final ImagePicker _picker = ImagePicker();

  // Method to pick image from gallery or camera
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the picked image to Firebase Storage
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(DateTime.now().toString() + '.jpg');
        await ref.putFile(File(pickedFile.path));

        final imageUrl = await ref.getDownloadURL();
        setState(() {
          _imageUrls.add(imageUrl); // Add the image URL to the list
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Optionally load images from Firebase storage if you have existing images
    _loadImages();
  }

  // Method to load images from Firebase (optional)
  Future<void> _loadImages() async {
    try {
      final ListResult result = await FirebaseStorage.instance
          .ref('user_images')
          .listAll();
      final urls = await Future.wait(result.items.map((ref) async {
        return await ref.getDownloadURL();
      }));
      setState(() {
        _imageUrls.addAll(urls); // Add existing images to the list
      });
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: _imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // You can add functionality to open the image in full screen
              },
              child: CachedNetworkImage(
                imageUrl: _imageUrls[index],
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
