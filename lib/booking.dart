import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'paymentpage.dart';
import '../global.dart'; // Make sure this contains your loggedInUserId

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final firestore = FirebaseFirestore.instance;

    // Step 1: Get work requests where current user is the requester
    final workRequestsSnapshot =
        await firestore
            .collection('workrequests')
            .where('requestedBy', isEqualTo: loggedInUserId)
            .get();

    List<Map<String, dynamic>> bookings = [];

    for (var doc in workRequestsSnapshot.docs) {
      final requestData = doc.data();
      final workerId = requestData['requestedTo'];

      // Step 2: Fetch worker details
      final workerSnapshot =
          await firestore.collection('usercredentials').doc(workerId).get();

      final workerData = workerSnapshot.data();

      if (workerData != null) {
        bookings.add({
          'workerName': workerData['name'],
          'category': workerData['work'],
          'status': requestData['status'],
          'fee': workerData['minfee'], // Getting fee from usercredentials
        });
      }
    }

    return bookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.permanentMarker(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 147, 165),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final status = booking['status'];

              Color statusColor;
              switch (status) {
                case 'Accepted':
                  statusColor = Colors.green;
                  break;
                case 'Pending':
                  statusColor = Colors.orange;
                  break;
                case 'Declined':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    booking['workerName'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking['category']} | ₹${booking['fee']}',
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      status == 'Accepted'
                          ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PaymentPage(
                                        workerName: booking['workerName'],
                                        fee: booking['fee'],
                                      ),
                                ),
                              );
                            },
                            child: const Text('Pay Now'),
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
