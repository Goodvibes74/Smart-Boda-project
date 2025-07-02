import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 568,
          height: 1064,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFF8A38F5),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 20,
                child: Container(
                  height: 1024,
                  padding: const EdgeInsets.all(32),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF232323) /* Colors-Accent-400 */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0xFF424242) /* Colors-Accent-100 */,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 64,
                    children: [
                      Container(
                        width: 308.94,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 16.94,
                          children: [
                            Expanded(
                              child: Container(
                                height: double.infinity,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 10,
                                  children: [
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
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
                                    style: TextStyle(
                                      color: const Color(0xFF616161) /* Colors-Secondary-100 */,
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
                      Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 449,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                        Text(
                                          'Home',
                                          style: TextStyle(
                                            color: const Color(0xFF1E88E5) /* Colors-Primary-600 */,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            height: 1.50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Container(width: 24, height: 24, child: Stack()),
                                        Text(
                                          'Devices',
                                          style: TextStyle(
                                            color: const Color(0xFF1E88E5) /* Colors-Primary-600 */,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                        Text(
                                          'Settings',
                                          style: TextStyle(
                                            color: const Color(0xFF1E88E5) /* Colors-Primary-600 */,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 44,
                                children: [
                                  SizedBox(
                                    width: 308.94,
                                    child: Text(
                                      'Developed by \nGroup 7 @MAKCOCIS\n 2025',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF616161) /* Colors-Secondary-100 */,
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 412.94,
                top: 20,
                child: Container(
                  height: 1024,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF232323) /* Colors-Accent-400 */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0xFF424242) /* Colors-Accent-100 */,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 64,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 16.94,
                          children: [
                            Expanded(
                              child: Container(
                                height: double.infinity,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 10,
                                  children: [                        
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 789,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 449,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Container(
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Container(width: 24, height: 24, child: Stack()),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1E1E1E) /* Colors-Accent-500 */,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 116,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16,
                                children: [
                                  Text(
                                    'Developed by \nGroup 7 @MAKCOCIS\n 2025',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF616161) /* Colors-Secondary-100 */,
                                      fontSize: 10,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 2.40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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