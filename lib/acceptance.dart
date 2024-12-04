import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/acceptance_detail_screen.dart';

class Acceptance extends StatefulWidget {
  const Acceptance({super.key});

  @override
  _AcceptanceState createState() => _AcceptanceState();
}

class _AcceptanceState extends State<Acceptance> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';

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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 400),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('휴대폰 번호 입력해주세요', style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PhoneNumberFormatter(),
                    ],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '휴대폰 번호',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.length != 13) {
                        return '유효한 휴대폰 번호를 입력해주세요.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Keep the formatted phone number with hyphens
                      _phoneNumber = value!;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                      ),
                      onPressed: _submitForm,
                      child: const Text('조회', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    final text = newValue.text;
    if (text.length <= 3) {
      return newValue;
    } else if (text.length <= 7) {
      return newValue.copyWith(
        text: '${text.substring(0, 3)}-${text.substring(3)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else {
      return newValue.copyWith(
        text: '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    }
  }
}