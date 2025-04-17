import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:translator/translator.dart';
import '../models/emergency_contact.dart';

class ContactCard extends StatefulWidget {
  final EmergencyContact contact;

  const ContactCard({super.key, required this.contact});

  @override
  State<ContactCard> createState() => _ContactCardState();
}

String convertToEasternArabic(String number) {
  const western = ['0','1','2','3','4','5','6','7','8','9'];
  const eastern = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];

  for (int i = 0; i < western.length; i++) {
    number = number.replaceAll(western[i], eastern[i]);
  }
  return number;
}

String convertToEng(String number) {
  const western = ['0','1','2','3','4','5','6','7','8','9'];
  const eastern = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];

  for (int i = 0; i < eastern.length; i++) {
    number = number.replaceAll(eastern[i], western[i]);
  }
  return number;
}

class _ContactCardState extends State<ContactCard> {
  String? nameEn;
  String? nameAr;

  @override
  void initState() {
    super.initState();
    _translateNames();
  }

  Future<void> _translateNames() async {
    final translator = GoogleTranslator();

    final en = await translator.translate(widget.contact.name, to: 'en');
    final ar = await translator.translate(widget.contact.name, to: 'ar');

    setState(() {
      nameEn = en.text;
      nameAr = ar.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        trailing: CachedNetworkImage(
          imageUrl: widget.contact.iconUrl,
          width: 50,
          height: 50,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        title: nameEn == null || nameAr == null
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$nameEn: ${convertToEng(widget.contact.number)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$nameAr: ${convertToEasternArabic(widget.contact.number)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
