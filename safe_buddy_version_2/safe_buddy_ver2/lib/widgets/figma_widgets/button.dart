import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 350,
          height: 40,
          decoration: ShapeDecoration(
            color: const Color(0xFF42A5F5) /* Colors-Primary-500 */,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: const Color(0xFFBBBBBB) /* Colors-Neutral-400 */,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 151,
                top: 7.50,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white /* Colors-Neutral-100 */,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
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