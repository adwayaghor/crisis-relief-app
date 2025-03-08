import 'package:flutter/material.dart';
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/shared_preferences.dart';
import 'package:relieflink/widgets/donation_details.dart';

class DonationCampaignCard extends StatelessWidget {
  final String title;
  final String organization;
  final String target;
  final String raised;
  final String imageUrl;
  final String merchantId;
final VoidCallback? onTap;

// Update constructor:
const DonationCampaignCard({
  super.key,
  required this.title,
  required this.organization,
  required this.target,
  required this.raised,
  required this.merchantId,
  required this.imageUrl,
  this.onTap,
});

  @override
  Widget build(BuildContext context) {
    final double progress = 0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 160.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 48.0, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'By $organization',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 12.0),
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
                  const SizedBox(height: 8.0),
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
                  const SizedBox(height: 16.0),
                  // Only show button if logStatus is true
                  if (logStatus)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => DonationDetails(
                                imageUrl: imageUrl,
                                title: title,
                                target: target,
                                raised: raised,
                                organization: organization,
                                merchantId: merchantId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Donate Now'),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Login Required'),
                              content: const Text(
                                  'You need to login to donate. Please login first.'),
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
                                        builder: (ctx) => LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Donate Now'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
