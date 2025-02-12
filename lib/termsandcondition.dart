import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Terms and Conditions',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please read and accept the following terms and conditions before proceeding:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
1. The advertisement must not contain any misleading or false information.
2. The user is solely responsible for the content they post.
3. Any advertisement violating community guidelines will be removed.
4. Items advertised must comply with legal regulations.
5. No offensive, illegal, or inappropriate content is allowed.
6. The platform holds the right to reject or remove any advertisement.
7. The advertiser must ensure that the product or service being advertised is legitimate.
8. If a faulty or misrepresented product is sold, necessary actions such as refunds or product exchanges may be enforced.
9. Repeated violations may result in a ban from using the platform.
10. By using this platform, the advertiser agrees to comply with all applicable terms and policies.
                  ''',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Accept & Proceed', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
