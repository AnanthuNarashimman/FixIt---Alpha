import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart'; // Ensure this file contains 'loggedInUserId'

class WorkerDetailPage extends StatefulWidget {
  final String name;
  final String profession;
  final double rating;
  final String bio;
  final String address;
  final int minFee;
  final String userid;

  const WorkerDetailPage({
    super.key,
    required this.name,
    required this.profession,
    required this.rating,
    required this.bio,
    required this.address,
    required this.minFee,
    required this.userid,
  });

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  bool isRequested = false;

  @override
  void initState() {
    super.initState();
    checkIfAlreadyRequested();
  }

  Future<void> checkIfAlreadyRequested() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('workrequests')
              .where('requestedBy', isEqualTo: loggedInUserId)
              .where('requestedTo', isEqualTo: widget.userid)
              .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          isRequested = true;
        });
      }
    } catch (e) {
      print('Error checking request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Worker Details',
          style: GoogleFonts.permanentMarker(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 147, 165),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${widget.profession} • ★ ${widget.rating}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bio',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.bio, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              Text(
                'Address',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.address, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              Text(
                'Minimum Fee',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('₹${widget.minFee}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed:
                      isRequested
                          ? null
                          : () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                TextEditingController descriptionController =
                                    TextEditingController();
                                TextEditingController clientNameController =
                                    TextEditingController();

                                return AlertDialog(
                                  title: const Text('Job Request'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: clientNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Client Name',
                                            hintText: 'Enter your name',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: descriptionController,
                                          maxLines: 3,
                                          decoration: const InputDecoration(
                                            labelText: 'Job Description',
                                            hintText:
                                                'Describe the work you want to get done',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        String description =
                                            descriptionController.text.trim();
                                        String clientName =
                                            clientNameController.text.trim();

                                        if (description.isNotEmpty &&
                                            clientName.isNotEmpty) {
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('workrequests')
                                                .add({
                                                  'requestedBy': loggedInUserId,
                                                  'requestedTo': widget.userid,
                                                  'status': 'pending',
                                                  'jobdes': description,
                                                  'clientName': clientName,
                                                  'timestamp':
                                                      FieldValue.serverTimestamp(),
                                                });

                                            setState(() {
                                              isRequested = true;
                                            });

                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Request sent successfully!',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error sending request: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          45,
                                          147,
                                          165,
                                        ),
                                      ),
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                  icon: Icon(
                    isRequested ? Icons.check_circle : Icons.send,
                    color: Colors.white,
                  ),
                  label: Text(
                    isRequested ? 'Requested' : 'Hire Now',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRequested
                            ? Colors.grey
                            : const Color.fromARGB(255, 45, 147, 165),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
