import 'package:flutter/material.dart';
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/models/volunteer/volunteer_page.dart';
import 'package:relieflink/shared_preferences.dart';

class VolunteerDetails extends StatefulWidget {
  const VolunteerDetails({
    super.key,
    required this.title,
    required this.organization,
    required this.target,
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String organization;
  final String target;
  final String description;
  final String imageUrl;

  @override
  State<VolunteerDetails> createState() => _VolunteerDetailsState();
}

class _VolunteerDetailsState extends State<VolunteerDetails> {
  bool reported = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0, // Add elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16.0), // Rounded corners for the card
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded corners and overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey),
                  ),
                  // Gradient overlay for better text readability
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'By ${widget.organization}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Target: ${widget.target}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.description,
              style: const TextStyle(
                  fontSize: 16, height: 1.5), // Improved line height
            ),
            const SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 216, 140, 69),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16), // Larger padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2.0, // Add elevation to the button
                ),
                onPressed: () {
                  if (logStatus) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => VolunteerPage(
                          title: widget.title,
                          organization: widget.organization,
                          description: widget.description,
                          imageUrl: widget.imageUrl,
                        ),
                      ),
                    );
                  } else {
                    _showLoginDialog(context);
                  }
                },
                child: const Text(
                  'Volunteer Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      reported = !reported;
                    });
                  },
                  icon: Icon(Icons.report_gmailerrorred,
                      color: reported ? Colors.red : null),
                ),
                Text(
                  'Report a fraud',
                  style: TextStyle(
                    color: reported ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Login Required'),
      content: const Text('You need to login to donate. Please login first.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => LoginScreen()),
            );
          },
          child: const Text('Login'),
        ),
      ],
    ),
  );
}
