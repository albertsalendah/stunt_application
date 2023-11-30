// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:stunt_application/Bloc/SocketBloc/socket_bloc.dart';
import 'package:stunt_application/Bloc/SocketBloc/socket_state.dart';
import 'package:stunt_application/custom_widget/backbutton.dart';
import 'package:stunt_application/custom_widget/sendMessageCard.dart';
import 'package:stunt_application/models/message_model.dart';
import 'package:stunt_application/utils/config.dart';
import 'package:stunt_application/utils/sqlite_helper.dart';
import '../../Bloc/KonsultasiBloc/konsultasiBloc.dart';
import '../../Bloc/KonsultasiBloc/konsultasiState.dart';
import '../../custom_widget/popup_error.dart';
import '../../custom_widget/receiveMessageCard.dart';
import '../../models/user.dart';
import '../../utils/SessionManager.dart';
import 'konsultasi_api.dart';

class ChatPage extends StatefulWidget {
  //final senderID;
  final receverID;
  final receiverNama;
  final receiverKet;
  final receiverFoto;
  final receiverFCM;
  const ChatPage(
      {super.key,
      //required this.senderID,
      required this.receverID,
      required this.receiverNama,
      required this.receiverKet,
      required this.receiverFoto,
      required this.receiverFCM});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  KonsultasiAPI api = KonsultasiAPI();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isEmojiVisible = false;
  User user = User();
  FocusNode focusNode = FocusNode();
  List<MessageModel> listMessage = [];
  List<PlatformFile> picked_foto = [];
  String foto = '';
  late SocketProviderBloc socketBloc;
  Timer? _checkTypingTimer;
  SqliteHelper sqlite = SqliteHelper();
  static const String link = Configs.LINK;
  String token = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    socketBloc = context.read<SocketProviderBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user = await SessionManager.getUser();
      token = await SessionManager.getToken() ?? '';
      String currentPage = await SessionManager.getCurrentPage() ?? '';
      if (currentPage.isNotEmpty) {
        await SessionManager.removeCurrentPage();
      }
      await SessionManager.saveCurrentPage(widget.receverID);
      await fetchData();
      if (listMessage.isEmpty) {
        await fetchData();
      }
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isEmojiVisible = false;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        log('CHAT PAGE INACTIVE');
        break;
      case AppLifecycleState.resumed:
        fetchData();
        log('CHAT PAGE RESUMED');
        break;
      case AppLifecycleState.paused:
        log('CHAT PAGE PAUSED');
        break;
      case AppLifecycleState.detached:
        log('CHAT PAGE DETACHED');
        break;
      case AppLifecycleState.hidden:
        log('CHAT PAGE HIDDEN');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
  }

  startTimer() {
    socketBloc.userTyping(
        isTyping: true,
        senderID: user.userID.toString(),
        receiverID: widget.receverID);
    _checkTypingTimer = Timer(const Duration(milliseconds: 600), () {
      socketBloc.userTyping(
          isTyping: false,
          senderID: user.userID.toString(),
          receiverID: widget.receverID);
    });
  }

  resetTimer() {
    _checkTypingTimer?.cancel();
    startTimer();
  }

  void onEmojiSelected(Emoji emoji) {
    messageController.text = messageController.text + emoji.emoji;
  }

  Future<void> fetchData() async {
    await context.read<KonsultasiBloc>().getIndividualMessage(
        senderID: user.userID.toString(), receiverID: widget.receverID);
    context
        .read<KonsultasiBloc>()
        .getLatestMesage(userID: user.userID.toString());
  }

  void pickPicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false, type: FileType.image, withData: true);

      if (result != null && result.files.single.path != null) {
        picked_foto = result.files;
        String? mimeType = lookupMimeType(picked_foto.first.name);
        double sizeInMB = picked_foto.first.size / math.pow(1024, 2);

        setState(() {
          if (mimeType?.startsWith('image') == true) {
            if (sizeInMB <= 11) {
              if (picked_foto.first.bytes != null) {
                foto = base64Encode(picked_foto.first.bytes!);
              }
            } else {
              showDialog(
                context: context,
                builder: (context) =>
                    const PopUpError(message: 'File Terlalu Besar (10 MB) MAX'),
              );
            }
          }
        });
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  void messageRead(List<MessageModel> unReadMessageList) async {
    int count = unReadMessageList.length;
    for (var item in unReadMessageList) {
      socketBloc.messageRead(
          messageId: item.idmessage.toString(),
          senderID: item.idreceiver.toString(),
          receiverID: item.idsender.toString());
      await sqlite.updateStatusChat(
          messageRead: 1, id_message: item.idmessage.toString());
      count--;
    }
    if (count == 0) {
      context
          .read<KonsultasiBloc>()
          .getLatestMesage(userID: user.userID.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SafeArea(
        child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (isEmojiVisible) {
          setState(() {
            isEmojiVisible = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 234, 243, 247),
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.grey),
          title: Text(
            'Konsultasi Gizi',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16 * fem,
                color: Colors.black),
          ),
          leading: CustomBackButton(
            fem: fem,
          ),
        ),
        body: Column(children: [
          header(fem, ffem),
          BlocBuilder<KonsultasiBloc, KonsultasiState>(
            builder: (context, state) {
              if (state is DataInitialState) {
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 40 * fem,
                            width: 40 * fem,
                            child: const CircularProgressIndicator()),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Memuat Data')
                      ]),
                );
              } else if (state is DataErrorState) {
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 32 * fem,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(state.errorMessage)
                      ]),
                );
              } else if (state is ListIndividualMesasage) {
                listMessage = state.listIndividualMessage;
                if (listMessage.isNotEmpty) {
                  List<MessageModel> unReadMessageList = listMessage
                      .where((item) =>
                          user.userID.toString() != item.idsender &&
                          item.messageRead != 1)
                      .toList();
                  unReadMessageList.sort((a, b) {
                    DateTime dateTimeA = DateTime.parse('${a.tanggalkirim}');
                    DateTime dateTimeB = DateTime.parse('${b.tanggalkirim}');
                    return dateTimeA.compareTo(dateTimeB);
                  });
                  if (unReadMessageList.isNotEmpty) {
                    messageRead(unReadMessageList);
                  }
                }
              }
              return Expanded(
                child: SizedBox(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await fetchData();
                    },
                    child: ListView.builder(
                      reverse: true,
                      itemCount: listMessage.length,
                      itemBuilder: (context, index) {
                        if (user.userID.toString() ==
                            listMessage[index].idsender) {
                          return SendMessageCard(message: listMessage[index]);
                        } else {
                          return ReceiveMessageCard(
                            message: listMessage[index],
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                if (foto.isNotEmpty) ...[
                  Offstage(
                    offstage: foto.isEmpty ||
                        MediaQuery.of(context).viewInsets.bottom > 0,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear,
                      child: Container(
                        height: 200,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(8),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.memory(base64Decode(foto)),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      foto = '';
                                      setState(() {});
                                    },
                                    child: const CircleAvatar(
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  )
                ],
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                            focusNode: focusNode,
                            controller: messageController,
                            maxLines: 5,
                            minLines: 1,
                            onChanged: (value) {
                              resetTimer();
                            },
                            decoration: InputDecoration(
                              hintText: 'Message',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              prefixIcon: InkWell(
                                onTap: () {
                                  focusNode.unfocus();
                                  focusNode.canRequestFocus = false;
                                  setState(() {
                                    isEmojiVisible = !isEmojiVisible;
                                  });
                                },
                                child: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  pickPicture();
                                },
                                child: const Icon(
                                  Icons.attachment,
                                  color: Colors.grey,
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await api
                              .sendMessage(
                                  id_sender: user.userID.toString(),
                                  id_receiver: widget.receverID,
                                  message: messageController.text,
                                  image: foto,
                                  fcm_token: widget.receiverFCM.toString(),
                                  title: user.nama.toString())
                              .then((value) async {
                            if (value.idmessage != null &&
                                value.idmessage!.isNotEmpty) {
                              foto = '';
                              messageController.clear();
                              setState(() {});
                              await fetchData().then((_) async {
                                await api.saveMesagetoServer(
                                    entry: value,
                                    fcm_token: widget.receiverFCM.toString(),
                                    title: user.nama.toString());
                              });
                            }
                          });
                        },
                        child: const CircleAvatar(
                          child: Icon(Icons.send),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Offstage(
            offstage: !isEmojiVisible,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                height: (focusNode.hasFocus) ? 0 : 300,
                child: emojiSelect(),
              ),
            ),
          )
        ]),
      ),
    ));
  }

  Container header(double fem, double ffem) {
    bool isOnline = false;
    bool isTyping = false;
    return Container(
      padding: EdgeInsets.fromLTRB(16 * fem, 16 * fem, 0 * fem, 0 * fem),
      width: double.infinity,
      height: 72 * fem,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xfff0f0f0)),
        color: const Color(0xffffffff),
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
        height: 96 * fem,
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
                      width: 45 * fem,
                      height: double.infinity,
                      child: CircleAvatar(
                        radius: 39.0 * fem,
                        backgroundImage: widget.receiverFoto != null &&
                                widget.receiverFoto!.isNotEmpty
                            ? FileImage(File(widget.receiverFoto.toString()))
                                as ImageProvider
                            : const AssetImage('assets/images/group-1-jAH.png'),
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 2 * fem),
                        child: Text(
                          widget.receiverNama ?? '',
                          style: TextStyle(
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.2125 * ffem / fem,
                            color: const Color(0xff161f35),
                          ),
                        ),
                      ),
                      BlocBuilder<SocketProviderBloc, SocketState>(
                        builder: (context, state) {
                          if (state is UserConnected) {
                            if (widget.receverID == state.connectedUser) {
                              isOnline = true;
                            }
                          } else if (state is UserDisonnected) {
                            if (widget.receverID == state.disconnectedUser) {
                              isOnline = false;
                            }
                          } else if (state is UserTyping) {
                            if (widget.receverID == state.senderID) {
                              isTyping = state.isTyping;
                            }
                          }
                          return Visibility(
                            visible: !isTyping,
                            replacement: Text(
                              'Typing...',
                              style: TextStyle(
                                fontSize: 12 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.6666666667 * ffem / fem,
                                color: const Color(0xff707070),
                              ),
                            ),
                            child: Text(
                              !isOnline
                                  ? widget.receiverKet != null
                                      ? widget.receiverKet.toString()
                                      : ''
                                  : 'Online',
                              style: TextStyle(
                                fontSize: 12 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.6666666667 * ffem / fem,
                                color: const Color(0xff707070),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
                    Icons.error_outline,
                    color: Colors.grey,
                  )),
            )
          ],
        ),
      ),
    );
  }

  EmojiPicker emojiSelect() {
    return EmojiPicker(
      textEditingController: messageController,
      onEmojiSelected: (category, emoji) => onEmojiSelected(emoji),
    );
  }
}
