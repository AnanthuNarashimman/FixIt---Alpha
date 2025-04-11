import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../global.dart'; // Adjust if your global.dart is in a different folder
import 'models/job.dart';

class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          job.description,
          style: GoogleFonts.permanentMarker(color: Colors.white),
        ),
        backgroundColor: const Color(0xff2D93A5),
      ),
      backgroundColor: const Color(0xffF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailTile("Client", job.client),
            buildDetailTile("Date & Time", job.dateTime),
            const SizedBox(height: 10),
            Text(
              "Description:",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(job.description, style: GoogleFonts.poppins(fontSize: 16)),
            const SizedBox(height: 30),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final querySnapshot =
                          await FirebaseFirestore.instance
                              .collection('workrequests')
                              .where('requestedTo', isEqualTo: loggedInUserId)
                              .where('jobdes', isEqualTo: job.description)
                              .get();

                      if (querySnapshot.docs.isNotEmpty) {
                        final docId = querySnapshot.docs.first.id;
                        await FirebaseFirestore.instance
                            .collection('workrequests')
                            .doc(docId)
                            .update({'status': 'accepted'});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Job Accepted")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Job not found.")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final querySnapshot =
                          await FirebaseFirestore.instance
                              .collection('workrequests')
                              .where('requestedTo', isEqualTo: loggedInUserId)
                              .where('jobdes', isEqualTo: job.description)
                              .get();

                      if (querySnapshot.docs.isNotEmpty) {
                        final docId = querySnapshot.docs.first.id;
                        await FirebaseFirestore.instance
                            .collection('workrequests')
                            .doc(docId)
                            .update({'status': 'rejected'});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Job Declined")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Job not found.")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text("Decline"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }
}
