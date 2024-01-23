import '../../constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsorLink extends StatelessWidget {
  const SponsorLink({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(kSponsorLink)),
      borderRadius: BorderRadius.circular(4),
      child: const Text(
        kSponsorLink,
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
