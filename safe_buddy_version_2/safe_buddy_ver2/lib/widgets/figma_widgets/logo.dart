import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 246,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16.94,
            children: [
              Container(
                width: 269.02,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                  
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  SizedBox(
                    width: 192,
                    child: Text(
                      'Safe Buddy',
                      style: TextStyle(
                        color: Colors.white /* Colors-Secondary-600 */,
                        fontSize: 33.89,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        height: 1.50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 192,
                    child: Text(
                      'Your safety is our priority',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFBDBDBD) /* Colors-Secondary-400 */,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}