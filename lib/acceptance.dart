import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'acceptance_detail_screen.dart';

class Acceptance extends StatefulWidget {
  const Acceptance({super.key});

  @override
  _AcceptanceState createState() => _AcceptanceState();
}

class _AcceptanceState extends State<Acceptance> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  bool _isButtonActive = false;

  void _handleInputChange(String value) {
    final formattedValue = PhoneNumberFormatter.formatPhoneNumber(value);
    setState(() {
      _phoneNumber = formattedValue;
      _isButtonActive = formattedValue.length > 3; // ###-####-####
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(_phoneNumber);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AcceptanceDetailScreen(phoneNumber: _phoneNumber),
      ));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const SizedBox(height: 96),
            Text(
              '휴대폰 번호 입력해주세요',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            // 입력 필드
            Container(
              width: 360,
              child: TextField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PhoneNumberFormatter(),
                ],
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: '  휴대폰 번호',

                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width:2, color: Color(0xFF485FE9)),

                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width:2, color: Color(0xFF000000)),
                  ),
                ),
                onChanged: _handleInputChange,
              ),
            ),
            const SizedBox(height: 40),
            // 버튼
            Container(
              width: 360,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: _isButtonActive
                      ? const Color(0xFF788aF8)
                      : const Color(0xFFF6F6F6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 30,
                  ),
                ),
                onPressed: _isButtonActive ? _submitForm : null,
                child: Text(
                  '다음',
                  style: TextStyle(
                    fontSize: 24,
                    color: _isButtonActive ? Colors.black : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), ''); // 숫자만 유지
    return TextEditingValue(
      text: formatPhoneNumber(text),
      selection: TextSelection.collapsed(
        offset: formatPhoneNumber(text).length,
      ),
    );
  }

  static String formatPhoneNumber(String value) {
    if (value.length <= 3) {
      return value;
    } else if (value.length <= 7) {
      return '${value.substring(0, 3)}-${value.substring(3)}';
    } else {
      return '${value.substring(0, 3)}-${value.substring(3, 7)}-${value.substring(7)}';
    }
  }
}
