import 'package:flutter/material.dart';
import 'package:relieflink/screens/razorpay_screen.dart';

class DonationDetails extends StatefulWidget {
  const DonationDetails({
    super.key,
    required this.title,
    required this.organization,
    required this.target,
    required this.raised,
    required this.imageUrl,
    required this.merchantId,
  });

  final String title;
  final String organization;
  final String target;
  final String raised;
  final String imageUrl;
  final String merchantId;

  @override
  State<DonationDetails> createState() => _DonationDetailsState();
}

class _DonationDetailsState extends State<DonationDetails> {
  bool reported = false;
  @override
  Widget build(BuildContext context) {
    final double progress = 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image display (Using NetworkImage if a URL is provided)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: // In DonationDetails.dart, update the Image.network part:

                  // Replace the current Image.network with this:
                  Image.network(
                widget.imageUrl,
                height: 250.0,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250.0,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    height: 250.0,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            // Title and Organization
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'By ${widget.organization}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 20.0),
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0.3
                    ? Colors.red
                    : progress < 0.7
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  //'\$${raised.toStringAsFixed(0)} raised',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Goal: 10000',
                  // 'Goal: \$${target.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            // Donate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement donation logic or navigation to donation page
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Donate'),
                      content: const Text('Do you want to donate now?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => CampaignDonationPage(
                                  campaignId: widget.title,
                                  merchantId: widget.merchantId,
                                ),
                              ),
                            );
                          },
                          child: const Text('Donate'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Background color of the button
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: const Text('Donate Now'),
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
