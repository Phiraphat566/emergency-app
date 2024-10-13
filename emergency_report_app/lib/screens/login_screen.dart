import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    if (_email.isEmpty || _password.isEmpty) {
      _showAlert(context, 'กรุณากรอกอีเมลและรหัสผ่าน');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ComplaintStatusScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showAlert(context, e.message ?? 'เกิดข้อผิดพลาด');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAlert(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message, style: const TextStyle(fontSize: 16)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login เจ้าหน้าที่')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Login', style: TextStyle(fontSize: 30)),
              const SizedBox(height: 45.0),
              TextFormField(
                key: UniqueKey(),
                initialValue: _email,
                onChanged: (value) => _email = value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
              const SizedBox(height: 25.0),
              TextFormField(
                key: UniqueKey(),
                obscureText: true,
                initialValue: _password,
                onChanged: (value) => _password = value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
              const SizedBox(height: 35.0),
              _isLoading
                  ? CircularProgressIndicator()
                  : Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.deepPurpleAccent,
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        onPressed: _login,
                        child: const Text("Login", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                      ),
                    ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}

class ComplaintStatusScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateReportStatus(String collection, String reportId, String status) async {
    try {
      await _firestore.collection(collection).doc(reportId).update({'status': status});
    } catch (e) {
      print('Error updating report status: $e');
      throw Exception('ไม่สามารถอัปเดตสถานะได้');
    }
  }

  Future<String> getReportDetails(String reportId) async {
    List<String> collections = ['accident_reports', 'complaint_reports', 'illness_reports'];
    String details = '';

    for (String collection in collections) {
      var doc = await _firestore.collection(collection).doc(reportId).get();
      if (doc.exists) {
        if (collection == 'illness_reports') {
          details = 'Collection: $collection\nDetails: ${doc['symptoms'] ?? 'ไม่มีรายละเอียด'}\nStatus: ${doc['status'] ?? 'ไม่มีสถานะ'}';
        } else {
          details = 'Collection: $collection\nDetails: ${doc['details'] ?? 'ไม่มีรายละเอียด'}\nStatus: ${doc['status'] ?? 'ไม่มีสถานะ'}';
        }
        break;
      }
    }

    return details.isNotEmpty ? details : 'ไม่พบข้อมูลรายงาน';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สถานะการร้องเรียน')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('accident_reports').snapshots(),
        builder: (context, accidentSnapshot) {
          if (accidentSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (accidentSnapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('complaint_reports').snapshots(),
            builder: (context, complaintSnapshot) {
              if (complaintSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (complaintSnapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
              }

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('illness_reports').snapshots(),
                builder: (context, illnessSnapshot) {
                  if (illnessSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (illnessSnapshot.hasError) {
                    return Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
                  }

                  final accidentReports = accidentSnapshot.data?.docs ?? [];
                  final complaintReports = complaintSnapshot.data?.docs ?? [];
                  final illnessReports = illnessSnapshot.data?.docs ?? [];

                  final allReports = [...accidentReports, ...complaintReports, ...illnessReports];

                  if (allReports.isEmpty) {
                    return Center(child: Text('ไม่มีข้อมูลเรื่องร้องเรียน'));
                  }

                  return ListView.builder(
                    itemCount: allReports.length,
                    itemBuilder: (context, index) {
                      final report = allReports[index].data() as Map<String, dynamic>;
                      final reportId = allReports[index].id;

                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text('เรื่องที่ร้องเรียน: ${report['symptoms'] ?? report['details'] ?? 'ไม่มีรายละเอียด'}'),
                          subtitle: Text('สถานะ: ${report['status'] ?? 'ไม่มีสถานะ'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () async {
                                  String collection = 'accident_reports';
                                  if (complaintReports.contains(allReports[index])) {
                                    collection = 'complaint_reports';
                                  } else if (illnessReports.contains(allReports[index])) {
                                    collection = 'illness_reports';
                                  }
                                  await updateReportStatus(collection, reportId, 'ดำเนินการเสร็จสิ้น');
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.info),
                                onPressed: () async {
                                  String details = await getReportDetails(reportId);
                                  _showReportDetails(context, details);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showReportDetails(BuildContext context, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายละเอียดรายงาน'),
          content: Text(details),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }
}
