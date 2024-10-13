import 'package:flutter/material.dart';
import 'login_screen.dart';

import '../widgets/emergency_button.dart';
  
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แจ้งเหตุฉุกเฉินและร้องเรียน'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            EmergencyButton(icon: Icons.sick, label: 'แจ้งเหตุด่วนเจ็บป่วย', type: 'illness'),
            EmergencyButton(icon: Icons.car_crash, label: 'แจ้งเหตุด่วนอุบัติเหตุ', type: 'accident'),
            EmergencyButton(icon: Icons.people, label: 'การร้องเรียนปัญหาสาธารณะ', type: 'public_issue'),
            EmergencyButton(icon: Icons.message, label: 'ติดตามสถานะ', type: 'status'),
          ],
        ),
      ),
    );
  }
}
