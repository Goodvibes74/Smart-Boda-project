import 'package:flutter/material.dart';
class InputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 350,
          height: 74,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: const Color(0xFF616161) /* Colors-Secondary-100 */,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 32,
                child: Container(
                  width: 350,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFFBBBBBB) /* Colors-Neutral-400 */,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16,
                        top: 8,
                        child: Text(
                          'Enter your username',
                          style: TextStyle(
                            color: const Color(0xFF616161) /* Colors-Secondary-100 */,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Text(
                  'Username',
                  style: TextStyle(
                    color: const Color(0xFFA4A4A4) /* Colors-Neutral-500 */,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
