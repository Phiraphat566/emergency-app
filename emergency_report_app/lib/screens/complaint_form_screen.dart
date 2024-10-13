import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/firebase_service.dart';

class ComplaintFormScreen extends StatefulWidget {
  final String type;

  ComplaintFormScreen({required this.type});

  @override
  _ComplaintFormScreenState createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  List<XFile?> images = [null, null, null, null];
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        for (int i = 0; i < selectedImages.length && i < images.length; i++) {
          images[i] = selectedImages[i];
        }
      });
    }
  }

  Future<void> submitData() async {
    try {
      
      final nonNullImages = images.where((image) => image != null).toList();
      if (nonNullImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาเลือกภาพอย่างน้อย 1 รูป')),
        );
        return;
      }

      
      List<String> imageUrls = await _firebaseService.uploadImages(nonNullImages);
      await _firebaseService.submitComplaintReport(
        nameController.text,
        locationController.text,
        detailsController.text,
        contactController.text,
        imageUrls,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งข้อมูลเรียบร้อยแล้ว')));
      _resetForm();
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อมูล: ${e.toString()}')));
    }
  }

  void _resetForm() {
    nameController.clear();
    locationController.clear();
    detailsController.clear();
    contactController.clear();
    setState(() {
      images = [null, null, null, null]; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แจ้งเรื่องร้องเรียน'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(nameController, 'ชื่อผู้แจ้ง', hintText: 'กรุณาระบุชื่อของคุณ'),
            _buildInputField(locationController, 'สถานที่', hintText: 'กรุณาระบุสถานที่ที่เกิดเหตุ'),
            _buildInputField(detailsController, 'รายละเอียดเรื่องร้องเรียน', hintText: 'กรุณาระบุรายละเอียดเรื่องร้องเรียน'),
            _buildInputField(contactController, 'เบอร์โทรศัพท์', hintText: 'กรุณาระบุเบอร์โทรศัพท์ที่สามารถติดต่อกลับได้'),
            SizedBox(height: 20),
            Text('รูปที่เกี่ยวข้อง (สูงสุด 4 รูป)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                for (XFile? image in images)
                  if (image != null)
                    FutureBuilder<Uint8List>(
                      future: image.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          return Container();
                        }
                      },
                    ),
                if (images.contains(null))
                  GestureDetector(
                    onTap: pickImages,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Icon(Icons.add_a_photo, size: 30, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitData,
              child: Text('ส่งเรื่องร้องเรียน'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {String? hintText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}