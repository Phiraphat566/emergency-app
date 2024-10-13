import 'package:flutter/material.dart'; 
import '../screens/illness_form_screen.dart';
import '../screens/complaint_form_screen.dart'; 
import '../screens/accident_form_screen.dart'; 
import '../screens/status_form_screen.dart';

class EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String type;

  EmergencyButton({required this.icon, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == 'illness') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => IllnessFormScreen()));
        } else if (type == 'accident') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AccidentFormScreen()));
        } else if (type == 'public_issue') { 
          Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintFormScreen(type: type))); 
        } else if (type == 'status') { 
          Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintStatusScreen()));
        }
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
