import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart';

class WorkerProfilePage extends StatefulWidget {
  const WorkerProfilePage({super.key});

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String address = '';
  String contact = '';
  String work = '';
  double rating = 0;
  String bio = '';
  String minFee = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Worker Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xff2D93A5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(label: "Name", onSaved: (val) => name = val!),
                _buildTextField(
                  label: "Address",
                  onSaved: (val) => address = val!,
                ),
                _buildTextField(
                  label: "Contact Info",
                  keyboard: TextInputType.phone,
                  onSaved: (val) => contact = val!,
                ),
                _buildTextField(
                  label: "Work",
                  onSaved: (val) => work = val!,
                ),
                 _buildTextField(
                  label: "Work Description",
                  maxLines: 3,
                  onSaved: (val) => bio = val!,
                ), _buildTextField(
                  label: "Minimum Fee",
                  keyboard: TextInputType.number,
                  onSaved: (val) => minFee = val!,
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        try {
                          // Update the main usercredentials document
                          await FirebaseFirestore.instance
                              .collection('usercredentials')
                              .doc(loggedInUserId)
                              .update({
                                'name': name,
                                'address': address,
                                'contact': contact,
                                'work': work,
                                'bio' : bio,
                                'minfee' : minFee
                              });

                          // Also create/update a new document in 'workers' collection
                          await FirebaseFirestore.instance
                              .collection('workers')
                              .doc(
                                loggedInUserId,
                              ) // Use the same UID as the doc ID
                              .set({
                                'userid': loggedInUserId,
                                'name': name,
                                'address': address,
                                'contact': contact,
                                'work': work,
                                'bio' : bio,
                                'minfee' : minFee,
                                'rating':
                                    rating, // optional: you can let it be 0.0 initially
                                'timestamp':
                                    FieldValue.serverTimestamp(), // to track when it's created/updated
                              });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update profile: $e'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2D93A5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Update Profile",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
        onSaved: onSaved,
      ),
    );
  }
}
