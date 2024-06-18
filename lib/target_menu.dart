import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proteus/constants.dart';

class TargetMenu extends StatelessWidget {
  const TargetMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'SCOPE:',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SizedBox(
            height: 32,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'This tab',
                  items: <String>[
                    'All of the web',
                    'All tabs',
                    'This tab',
                    'This domain'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.raleway(
                          textStyle: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12.0, // Adjust the font size here
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {},
                  dropdownColor: GradientOne.blurple,
                  iconEnabledColor: Colors.white,
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0, // Adjust the font size here as well
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
