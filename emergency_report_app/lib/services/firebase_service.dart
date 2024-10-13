import 'dart:io' as io;
import 'dart:typed_data'; 
import 'dart:html' as html; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';  
import 'package:flutter/foundation.dart' show kIsWeb; 

class FirebaseService {
  Future<List<String>> uploadImages(List<XFile?> images) async {
    List<String> imageUrls = [];

    for (XFile? image in images) {
      if (image != null) {
        try {
          if (kIsWeb) {
            
            final html.File webFile = html.File([], image.name);
            final reader = html.FileReader();
            reader.readAsArrayBuffer(webFile); 
            await reader.onLoadEnd.first; 

            final Uint8List fileBytes = reader.result as Uint8List;
            String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${basename(image.name)}';
            Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

            
            UploadTask uploadTask = storageRef.putData(fileBytes);

            TaskSnapshot taskSnapshot = await uploadTask;
            if (taskSnapshot.state == TaskState.success) {
              String imageUrl = await taskSnapshot.ref.getDownloadURL();
              imageUrls.add(imageUrl);
            }
          } else {
            
            final io.File file = io.File(image.path);
            String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${basename(image.path)}';
            Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

            UploadTask uploadTask = storageRef.putFile(file);

            TaskSnapshot taskSnapshot = await uploadTask;

            if (taskSnapshot.state == TaskState.success) {
              String imageUrl = await taskSnapshot.ref.getDownloadURL();
              imageUrls.add(imageUrl);
            } else {
              print('Upload failed: ${taskSnapshot.state}');
              throw Exception('ไม่สามารถอัปโหลดภาพ: ${image.name}');
            }
          }
        } catch (e) {
          if (e is FirebaseException) {
            print('Firebase error: ${e.code} - ${e.message}');
          } else {
            print('General error: $e');
          }
          print('Error uploading image: ${image.name}');
          throw Exception('ไม่สามารถอัปโหลดภาพ: ${image.name}');
        }
      }
    }

    if (imageUrls.isEmpty) {
      throw Exception('ไม่มีภาพที่อัปโหลด');
    }

    return imageUrls;
  }

  // อาการเจ็บป่วย
  Future<void> submitIllnessReport(String name, String location, String symptoms, String telephone, List<String> images) async {
    try {
      await FirebaseFirestore.instance.collection('illness_reports').add({
        'name': name,
        'location': location,
        'symptoms': symptoms,
        'telephone': telephone,
        'images': images,
        'status': 'กำลังดำเนินงาน',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting report: $e');
      throw Exception('ไม่สามารถส่งรายงานอาการเจ็บป่วยได้');
    }
  }

  // แจ้งเหตุ
  Future<void> submitAccidentReport(String name, String location, String details, String contact, List<String> imageUrls) async {
    try {
      await FirebaseFirestore.instance.collection('accident_reports').add({
        'name': name,
        'location': location,
        'details': details,
        'contact': contact,
        'images': imageUrls,
        'status': 'กำลังดำเนินงาน',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting accident report: $e');
      throw Exception('ไม่สามารถส่งรายงานอุบัติเหตุได้');
    }
  }

  // ร้องเรียน
  Future<void> submitComplaintReport(String name, String location, String details, String contact, List<String> imageUrls) async {
    try {
      await FirebaseFirestore.instance.collection('complaint_reports').add({ 
        'name': name,
        'location': location,
        'details': details,
        'contact': contact,
        'images': imageUrls,
        'status': 'กำลังดำเนินงาน',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting complaint report: $e'); 
      throw Exception('ไม่สามารถส่งรายงานข้อร้องเรียนได้'); 
    }
  }
}
