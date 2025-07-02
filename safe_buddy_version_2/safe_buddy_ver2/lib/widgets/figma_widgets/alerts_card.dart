import 'package:flutter/material.dart';

class Alerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: ShapeDecoration(
            color: const Color(0xFF232323) /* Colors-Accent-400 */,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFF424242) /* Colors-Accent-100 */,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 32,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 32,
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16,
                      children: [
                        Container(
                          width: 48,
                          height: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: ShapeDecoration(
                            color: const Color(0x7FE53935) /* Colors-Error-Alpha-50 */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Container(width: 20, height: 20, child: Stack()),
                            ],
                          ),
                        ),
                        Container(
                          width: 189,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 189,
                                child: Text(
                                  'Severity : High',
                                  style: TextStyle(
                                    color: Colors.white /* Colors-Secondary-600 */,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 189,
                                child: Text(
                                  'Device No: 1203 299292',
                                  style: TextStyle(
                                    color: Colors.white /* Colors-Secondary-600 */,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    height: 1.85,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 164,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              SizedBox(
                                width: 164,
                                child: Text(
                                  '2024-01-15 14:30',
                                  style: TextStyle(
                                    color: const Color(0xFFE0E0E0) /* Colors-Secondary-500 */,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.91,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 164,
                                child: Text(
                                  '123 Main Street , Nairobi',
                                  style: TextStyle(
                                    color: const Color(0xFF757575) /* Colors-Secondary-200 */,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.91,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: 223,
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 84, vertical: 14),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEF5350) /* Colors-Error-500 */,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              'Locate',
                              style: TextStyle(
                                color: Colors.white /* Colors-Neutral-100 */,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 226,
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 79, vertical: 14),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              color: const Color(0xFF616161) /* Colors-Secondary-100 */,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              'Cancel',
                              style: TextStyle(
                                color: const Color(0xFF616161) /* Colors-Secondary-100 */,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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