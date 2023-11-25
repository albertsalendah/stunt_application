import 'package:flutter/material.dart';

class PopUpStatusGizi extends StatelessWidget {
  final String title;
  final String message;
  const PopUpStatusGizi(
      {super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 305;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return AlertDialog(
        scrollable: true,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20 * fem))),
        content: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin:
                      EdgeInsets.fromLTRB(5 * fem, 0 * fem, 5 * fem, 20 * fem),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            67.25 * fem, 0 * fem, 67.25 * fem, 16 * fem),
                        padding: EdgeInsets.fromLTRB(
                            12.23 * fem, 13.59 * fem, 13.59 * fem, 12.23 * fem),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xffebf1fe),
                          borderRadius:
                              BorderRadius.circular(12.228260994 * fem),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 36.68 * fem,
                            height: 36.68 * fem,
                            child: Image.asset(
                              'assets/images/group-1-jAH.png',
                              width: 36.68 * fem,
                              height: 36.68 * fem,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 7 * fem),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.2125 * ffem / fem,
                                color: const Color(0xff161f35),
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 197 * fem,
                            ),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.4285714286 * ffem / fem,
                                color: const Color(0xff2d2d2d),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: const Color(0xff3f7af6)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Tutup',
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ),
          ],
        ));
  }
}
