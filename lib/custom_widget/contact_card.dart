import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../pages/Konsultasi/chat_page.dart';

class ContactCard extends StatelessWidget {
  final User user;
  const ContactCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              senderID: '',
              receverID: user.userID,
              receiverNama: user.nama,
              receiverKet: user.keterangan,
              receiverFCM: user.fcm_token,
              receiverFoto: user.foto,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16 * fem, 16 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        height: 72 * fem,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xfff0f0f0)),
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(12 * fem),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0f1b253e),
              offset: Offset(0 * fem, 2 * fem),
              blurRadius: 3.5 * fem,
            ),
          ],
        ),
        child: SizedBox(
          width: 348 * fem,
          height: 94 * fem,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin:
                    EdgeInsets.fromLTRB(0 * fem, 0.5 * fem, 73 * fem, 0 * fem),
                height: 41 * fem,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 11 * fem, 0 * fem),
                      padding: EdgeInsets.fromLTRB(
                          28 * fem, 27 * fem, 2 * fem, 3 * fem),
                      width: 39 * fem,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xfff0f0f0)),
                        borderRadius: BorderRadius.circular(19.5 * fem),
                        image: user.foto == null
                            ? const DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage('assets/images/group-1-jAH.png'),
                              )
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(
                                    base64Decode(user.foto.toString())),
                              ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: double.infinity,
                          height: 9 * fem,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.5 * fem),
                              color: const Color(0xff12b66a),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 2 * fem),
                            child: Text(
                              user.nama ?? '',
                              style: TextStyle(
                                fontSize: 14 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.2125 * ffem / fem,
                                color: const Color(0xff161f35),
                              ),
                            ),
                          ),
                          Text(
                            user.keterangan ?? '',
                            style: TextStyle(
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.6666666667 * ffem / fem,
                              color: const Color(0xff707070),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                    width: 35 * fem,
                    height: 35 * fem,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      Icons.chat_outlined,
                      color: Colors.grey,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
