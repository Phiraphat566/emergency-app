import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintStatusScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QuerySnapshot>> _fetchReports() async {
    
    final accidentReports = _firestore.collection('accident_reports').get();
    final complaintReports = _firestore.collection('complaint_reports').get();
    final illnessReports = _firestore.collection('illness_reports').get();

    return Future.wait([accidentReports, complaintReports, illnessReports]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สถานะการร้องเรียน'),
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: _fetchReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ไม่มีข้อมูลเรื่องร้องเรียน'));
          }

          
          final allReports = [
            ...snapshot.data![0].docs,  
            ...snapshot.data![1].docs,  
            ...snapshot.data![2].docs   
          ];

          return ListView.builder(
            itemCount: allReports.length,
            itemBuilder: (context, index) {
              final report = allReports[index].data() as Map<String, dynamic>;

              final String details = report['symptoms'] ?? report['details'] ?? 'ไม่มีรายละเอียด';
              final String status = report['status'] ?? 'ไม่ระบุสถานะ';
              final String timestamp = (report['timestamp'] != null)
                  ? (report['timestamp'] as Timestamp).toDate().toString()
                  : 'ไม่ระบุวันที่';
              final String additionalDetails = report['additionalDetails'] ?? 'ไม่มีรายละเอียดเพิ่มเติม';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('เรื่องที่ร้องเรียน: $details'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สถานะ: $status'),
                      Text('วันที่: $timestamp'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('รายละเอียดการร้องเรียน'),
                          content: Text(
                            'เรื่อง: $details\n'
                            'สถานะ: $status\n'
                            'วันที่: $timestamp\n'
                            'รายละเอียดเพิ่มเติม: $additionalDetails',
                          ),
                          actions: [
                            TextButton(
                              child: Text('ปิด'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
