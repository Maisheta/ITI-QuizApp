import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/logout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = "English";
  bool _notifications = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveSettingsToFirestore() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'language': _language,
          'notifications': _notifications,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  void handleChangeLanguage(String? value) async {
    if (value != null) {
      setState(() {
        _language = value;
      });
      await saveSettingsToFirestore();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Language changed to $value')));
    }
  }

  void handleToggleNotifications(bool value) async {
    setState(() {
      _notifications = value;
    });
    await saveSettingsToFirestore();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifications ${_notifications ? "enabled" : "disabled"}',
        ),
      ),
    );
  }

  void handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6CC), Color(0xFFF4C4C4), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.all(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFA726),
                            Color(0xFFF48FB1),
                            Color(0xFFAB47BC),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              "Language",
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: DropdownButton<String>(
                              value: _language,
                              items: <String>['English', 'Arabic'].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: handleChangeLanguage,
                              dropdownColor: Color(0xFFAB47BC),
                            ),
                          ),
                          Divider(color: Colors.white54, height: 1),
                          ListTile(
                            title: Text(
                              "Notifications",
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Switch(
                              value: _notifications,
                              onChanged: handleToggleNotifications,
                              activeColor: Colors.white,
                            ),
                          ),
                          Divider(color: Colors.white54, height: 1),
                          ListTile(
                            title: Text(
                              "Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: handleLogout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
