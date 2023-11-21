import 'package:flutter/material.dart';

import '../utils/formatTgl.dart';

class JadwalVaksinCard extends StatelessWidget {
  final double fem;
  final double ffem;
  final String tipeVaksin;
  final String tanggalVaksin;
  final String lokasiVaksin;
  const JadwalVaksinCard(
      {super.key,
      required this.fem,
      required this.ffem,
      required this.tipeVaksin,
      required this.tanggalVaksin,
      required this.lokasiVaksin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12 * fem, 12 * fem, 42.27 * fem, 12 * fem),
      width: double.infinity,
      height: 78 * fem,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xfff0f0f0)),
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(10 * fem),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0f1b253e),
            offset: Offset(0 * fem, 2 * fem),
            blurRadius: 3.5 * fem,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 11 * fem, 0 * fem),
            width: 50 * fem,
            height: 50 * fem,
            child: Image.asset(
              'assets/images/group-1-sRb.png',
              width: 42.73 * fem,
              height: 42.73 * fem,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tipeVaksin,
                style: TextStyle(
                  fontSize: 14 * ffem,
                  fontWeight: FontWeight.w500,
                  height: 1.2142857143 * ffem / fem,
                  color: const Color(0xff161f35),
                ),
              ),
              Text(
                FormatTgl().setTgl(tanggalVaksin),
                style: TextStyle(
                  fontSize: 12 * ffem,
                  fontWeight: FontWeight.w400,
                  height: 1.4166666667 * ffem / fem,
                  color: const Color(0xff707070),
                ),
              ),
              Text(
                lokasiVaksin,
                style: TextStyle(
                  fontSize: 12 * ffem,
                  fontWeight: FontWeight.w400,
                  height: 1.4166666667 * ffem / fem,
                  color: const Color(0xff707070),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
