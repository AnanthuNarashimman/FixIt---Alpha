import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/categ.dart';
import 'package:flutter_app/chat2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'workerdetail.dart';
import 'booking.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'FIX-it',
          style: GoogleFonts.permanentMarker(
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 147, 165),
        toolbarHeight: 70,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 45, 147, 165),
              ),
              accountName: const Text('Welcome!'),
              accountEmail: const Text('user@email.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xff666666)),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Categories'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.book_online),
                    title: const Text('My Bookings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyBookingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for workers...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.teal.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                'Categories',
                style: GoogleFonts.permanentMarker(fontSize: 20),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CategoryCard(title: 'Plumber', icon: Icons.plumbing),
                    CategoryCard(
                      title: 'Electrician',
                      icon: Icons.electrical_services,
                    ),
                    CategoryCard(title: 'Carpenter', icon: Icons.construction),
                    CategoryCard(title: 'Tailor', icon: Icons.checkroom),
                    CategoryCard(title: 'DJ', icon: Icons.music_note),
                    CategoryCard(title: 'Photographer', icon: Icons.camera_alt),
                    CategoryCard(
                      title: 'Finance',
                      icon: Icons.attach_money_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text(
                'Featured Workers',
                style: GoogleFonts.permanentMarker(fontSize: 20),
              ),
              const SizedBox(height: 10),

              // Firestore-based Featured Workers List
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('workers')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text(
                      'No featured workers available right now.',
                      style: GoogleFonts.poppins(),
                    );
                  }

                  final workers = snapshot.data!.docs;

                  return Column(
                    children:
                        workers.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'Unnamed';
                          final work = data['work'] ?? 'N/A';
                          final bio = data['bio'] ?? 'No bio provided';
                          final id = data['userid'];
                          final address =
                              data['address'] ?? 'No address provided';
                          final minFee = int.tryParse(data['minfee'].toString()) ?? 0;


                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  231,
                                  228,
                                  253,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xff6b62f6),
                                ),
                              ),
                              title: Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '$work | ★ 4.5',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => WorkerDetailPage(
                                          name: name,
                                          profession: work,
                                          rating: 4.5, // Static for now
                                          bio: bio,
                                          address: address,
                                          minFee: minFee,
                                          userid: id,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 45, 147, 165),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Chat2()),
          );
        },
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const CategoryCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: const Color.fromARGB(255, 129, 120, 247)),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
