import 'package:flutter/material.dart';

class TermsOfUseText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          SizedBox(height: 12),
          Text(
            'Welcome to Fundder.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
              'Our Terms of Use provide information about the service we provide. Fundder is a service provided by Stade Limited. These Terms of Use constitute an agreement between the user and Stade Limited.'),
          SizedBox(height: 12),
          Text(
              'Our service provides users with a social media platform that enables easy fundraising for our listed charities.'),
          SizedBox(height: 12),
          Text(
            'The Data Policy',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
              'Creating an account with Fundder requires you to consent for us to collect the following personal information:'),
          SizedBox(height: 12),
          Text('- Name'),
          Text('- Date of Birth'),
          Text('- Email address'),
          SizedBox(height: 12),
          Text(
              'Fundder does not store any of your personal information beyond your account details. Fundder will not sell or pass on your information to any third parties, advertisers or charities.'),
          SizedBox(height: 12),
          Text(
              'Personal information collected by Stripe when making payments remain the responsibility of Stripe in compliance with EU Data Protection laws.'),
          SizedBox(height: 12),
          Text(
              'All uploaded content (videos/images) will be viewable from any Fundder account. Uploaded content can be deleted at any time by the user. All users have their rights as outlined by GDPR laws, including the right to be forgotten. Deleting an account will result in all uploaded content by the user to be deleted from the Fundder app.'),
          SizedBox(height: 12),
          Text(
            'Your Commitments',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
              'We want to provide a safe platform for users worldwide. We therefore ask that in return for our commitment to provide this, users agree to the following prior to creating an account with us:'),
          SizedBox(height: 12),
          Text(
            'Who Can Use Fundder?',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 12),
          Text('- You must be at least 13 years old'),
          Text(
              '- All content that you upload must comply with our Terms of Use'),
          Text(
              '- You must not have any legal reasons prohibiting you from using social media'),
          Text('- You must not be a convicted sex offender'),
          SizedBox(height: 12),
          Text(
            'What content is NOT permitted?',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 12),
          Text(
              '- Any content or account impersonating another person without their permission'),
          Text('- Any content violating domestic law'),
          Text(
              '- Fraudulent or misleading information that may lead to legal action'),
          Text(
              '- Any stolen/pirated content or violation of intellectual property'),
          Text(
              '- Any content that encourages the violation of our Terms of Use'),
          Text(
              '- Any content intended to collect other people’s personal information without permission'),
          Text('- Any attempt to buy or sell your login'),
          Text('- Any content that violates another user’s rights'),
          Text(
              '- Use of a domain name or URL in your username without prior written consent.'),
          SizedBox(height: 12),
          Text(
            'Permissions You Give to Us.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 12),
          Text(
            'As part of our agreement, you also give us permissions that we need to provide the Service.',
          ),
          SizedBox(height: 12),
          Text(
              '- Fundder does not claim ownership or responsibility for your content We will not sell or pass on your information. However, your content will remain visible to the public when you upload and will be until it is removed.'),
          Text(
              '- Permission to display your account informationBy creating an account, you give us permission to display your username, profile picture, uploaded content and donations on our platform. We will not sell this information, but it will be available for the public, until the account is deleted.'),
          SizedBox(height: 12),
          Text(
            'Additional Rights We Retain',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
              '- Fundder retains the right to remove any content or account that violates our Terms of Use.'),
          Text(
              '- Fundder retains the right to store information related to completed donations in an anonymised and secure form on our private database for up to 12 months from deleting the account. This is entirely for auditing and legal purposes. Fundder guarantees that this information will never be shared with the public or any third party.'),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
