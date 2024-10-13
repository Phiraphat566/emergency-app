import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

class IllnessFormScreen extends StatefulWidget {
  @override
  _IllnessFormScreenState createState() => _IllnessFormScreenState();
}

class _IllnessFormScreenState extends State<IllnessFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController tellController = TextEditingController();
  List<XFile?> images = [null, null, null, null];
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null) {
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
        throw Exception('กรุณาเลือกภาพอย่างน้อย 1 รูป');
      }

      List<String> imageUrls = await _firebaseService.uploadImages(nonNullImages);
      await _firebaseService.submitIllnessReport(
        nameController.text,
        locationController.text,
        symptomsController.text,
        tellController.text,
        imageUrls,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งข้อมูลเรียบร้อยแล้ว')));
      nameController.clear();
      locationController.clear();
      symptomsController.clear();
      tellController.clear();
      setState(() {
        images = [null, null, null, null]; 
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อมูล: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แจ้งเหตุเจ็บป่วย'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(nameController, 'ชื่อผู้แจ้ง', hintText: 'กรุณาระบุชื่อของคุณ'),
            _buildInputField(locationController, 'สถานที่', hintText: 'กรุณาระบุสถานที่ที่เกิดเหตุ'),
            _buildInputField(symptomsController, 'อาการ', hintText: 'กรุณาระบุรายละเอียดอาการป่วยและชื่อผู้ป่วย'),
            _buildInputField(tellController, 'เบอร์โทรศัพท์', hintText: 'กรุณาระบุเบอร์โทรศัพท์ที่สามารถติดต่อกลับได้'),
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
              child: Text('ส่งข้อมูล'),
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
