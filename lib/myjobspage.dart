import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../global.dart'; // must contain loggedInUserId

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
  Future<List<Map<String, dynamic>>> fetchJobs() async {
    final firestore = FirebaseFirestore.instance;

    final workRequestsSnapshot =
        await firestore
            .collection('workrequests')
            .where('requestedTo', isEqualTo: loggedInUserId)
            .get();

    List<Map<String, dynamic>> jobs = [];

    for (var doc in workRequestsSnapshot.docs) {
      final requestData = doc.data();
      final requestId = doc.id;

      // Fetching client details using requestedBy
      final clientId = requestData['requestedBy'];
      final clientSnapshot =
          await firestore.collection('usercredentials').doc(clientId).get();

      final clientData = clientSnapshot.data();

      if (clientData != null) {
        // Convert Firestore Timestamp to readable string
        final Timestamp timestamp = requestData['timestamp'];
        final dateTime = timestamp.toDate();
        final formattedDateTime =
            "${_formatDate(dateTime)} - ${_formatTime(dateTime)}";

        jobs.add({
          'id': requestId,
          'client': requestData['clientName'],
          'job': requestData['jobdes'],
          'status': requestData['status'],
          'datetime': formattedDateTime,
        });
      }
    }

    return jobs;
  }

  String _formatDate(DateTime date) {
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final amPm = time.hour >= 12 ? "PM" : "AM";
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $amPm";
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  Future<void> markJobCompleted(String jobId) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('workrequests').doc(jobId).update({
      'status': 'Completed',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job marked as completed!', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Jobs',
          style: GoogleFonts.permanentMarker(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff2D93A5),
      ),
      backgroundColor: const Color(0xffF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchJobs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No jobs found.'));
            }

            final jobs = snapshot.data!;

            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                final isCompleted = job['status'] == 'Completed';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Client: ${job['client']}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Job: ${job['job']}",
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      Text(
                        "Date/Time: ${job['datetime']}",
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status: ${job['status']}",
                            style: GoogleFonts.poppins(
                              color: isCompleted ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!isCompleted)
                            ElevatedButton(
                              onPressed: () => markJobCompleted(job['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2D93A5),
                              ),
                              child: const Text('Mark Completed'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
