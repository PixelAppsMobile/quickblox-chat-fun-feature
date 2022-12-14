import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickblox_polls_feature/models/message_action_react.dart';
import 'package:quickblox_polls_feature/models/poll_message.dart';
import 'package:quickblox_polls_feature/models/reaction_message.dart';
import 'package:quickblox_polls_feature/models/sticker_message_properties.dart';
import 'package:quickblox_polls_feature/presentation/screens/chat/chat_poll_item.dart';
import 'package:quickblox_polls_feature/presentation/widgets/popup_menu_widget.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:stipop_sdk/stipop_plugin.dart';

import '../../../bloc/chat/chat_screen_bloc.dart';
import '../../../bloc/chat/chat_screen_events.dart';
import '../../../bloc/chat/chat_screen_states.dart';
import '../../../models/message_wrapper.dart';
import '../../../models/poll_action.dart';
import '../../../stream_builder_with_listener.dart';
import '../../../utils/color_util.dart';
import '../../../utils/notification_utils.dart';
import '../../../utils/random_util.dart';
import '../../managers/typing_status_manager.dart';
import '../../widgets/decorated_app_bar.dart';
import '../../widgets/progress.dart';
import '../base_screen_state.dart';
import 'chat_list_item.dart';

class ChatScreen extends StatefulWidget {
  final String _dialogId = '639959da07a49d006c0fc6c5';
  final bool _isNewChat = false;

  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState(_dialogId, _isNewChat);
}

class ChatScreenState extends BaseScreenState<ChatScreenBloc> {
  static const int CHAT_INFO_MENU_ITEM = 0;
  static const int LEAVE_CHAT_MENU_ITEM = 1;
  static const int DELETE_CHAT_MENU_ITEM = 2;

  static const int FORWARD_MESSAGE_MENU_ITEM = 0;
  static const int DELIVERED_TO_MENU_ITEM = 1;
  static const int VIEWED_BY_MENU_ITEM = 2;

  String _dialogId;
  int _dialogType = 0;
  bool _hasMore = true;
  bool _isNewChat;

  final maximumPollOptions = 4;
  final minimumPollOptions = 2;
  int currentPollOptions = 0;
  Stipop stipop = Stipop();

  ScrollController? _scrollController;
  TextEditingController? _inputController = TextEditingController();

  ChatScreenState(this._dialogId, this._isNewChat);

  @override
  void initState() {
    super.initState();
    stipop.connect(
      userId: dotenv.env['stipopApplicationId'],
      onStickerPackSelected: (spPackage) {},
      onStickerDoubleTapped: (sticker) {
        bloc?.events?.add(
          SendStickerMessageEvent(
            StickerMessageProperties.fromData(sticker.stickerImg!),
          ),
        );
      },
      pickerViewAppear: (spIsViewAppear) {},
      onStickerSingleTapped: (sticker) {
        bloc?.events?.add(
          SendStickerMessageEvent(
            StickerMessageProperties.fromData(sticker.stickerImg!),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    TypingStatusManager.cancelTimer();
    _scrollController?.removeListener(_scrollListener);
    _scrollController = null;
    _inputController = null;
    stipop.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initBloc(context);
    bloc?.setArgs(ChatArguments(_dialogId, _isNewChat));

    _scrollController = ScrollController();
    _scrollController?.addListener(_scrollListener);

    return Scaffold(
      appBar: DecoratedAppBar(appBar: _buildAppBar()),
      body: Column(
        children: [
          Expanded(
            child: Stack(children: [
              Container(
                  color: const Color(0xfff1f1f1),
                  child: RawScrollbar(
                    thumbVisibility: false,
                    thickness: 3,
                    controller: _scrollController,
                    radius: const Radius.circular(3),
                    thumbColor: Colors.blue,
                    child: StreamProvider<ChatScreenStates>(
                      create: (context) =>
                          bloc?.states?.stream as Stream<ChatScreenStates>,
                      initialData: LoadMessagesSuccessState([], false),
                      child: Selector<ChatScreenStates, ChatScreenStates>(
                          selector: (_, state) => state,
                          shouldRebuild: (previous, next) {
                            return next is LoadMessagesSuccessState;
                          },
                          builder: (_, state, __) {
                            if (state is LoadMessagesSuccessState) {
                              _hasMore = state.hasMore;
                            }
                            var tapPosition;

                            return GroupedListView<QBMessageWrapper, DateTime>(
                              addAutomaticKeepAlives: true,
                              elements:
                                  (state as LoadMessagesSuccessState).messages,
                              order: GroupedListOrder.DESC,
                              reverse: true,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              floatingHeader: true,
                              useStickyGroupSeparators: true,
                              groupBy: (QBMessageWrapper message) => DateTime(
                                  message.date.year,
                                  message.date.month,
                                  message.date.day),
                              groupHeaderBuilder: (QBMessageWrapper message) =>
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 7, bottom: 7),
                                      padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 3,
                                          bottom: 3),
                                      decoration: const BoxDecoration(
                                          color: Color(0xffd9e3f7),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(11))),
                                      child: Text(
                                          _buildHeaderDate(
                                              message.qbMessage.dateSent),
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13)),
                                    )
                                  ]),
                              itemBuilder: (context, QBMessageWrapper message) {
                                if (message is PollMessage) {
                                  return ChatPollItem(
                                    message: message,
                                    key: ValueKey(
                                      Key(
                                        RandomUtil.getRandomString(10),
                                      ),
                                    ),
                                  );
                                }
                                var reactionCountMap = <String, int>{};
                                if (message is ReactionMessage) {
                                  var elements = message.reacts.values.toList();
                                  for (var x in elements) {
                                    reactionCountMap[x] =
                                        !reactionCountMap.containsKey(x)
                                            ? (1)
                                            : (reactionCountMap[x]! + 1);
                                  }
                                }

                                return GestureDetector(
                                    child: message is ReactionMessage
                                        ? Stack(
                                            fit: StackFit.loose,
                                            children: [
                                              ChatListItem(
                                                Key(
                                                  RandomUtil.getRandomString(
                                                      10),
                                                ),
                                                message,
                                                _dialogType,
                                              ),
                                              Positioned(
                                                right: message.isIncoming
                                                    ? null
                                                    : 20,
                                                left: message.isIncoming
                                                    ? 70
                                                    : null,
                                                bottom: 0,
                                                child: message.reacts.isEmpty
                                                    ? const SizedBox.shrink()
                                                    : Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(10),
                                                          ),
                                                          border: Border.all(
                                                            width: 3,
                                                            color: Colors.grey,
                                                            style: BorderStyle
                                                                .solid,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            for (var reaction
                                                                in reactionCountMap
                                                                    .entries)
                                                              Row(
                                                                children: [
                                                                  Image.asset(
                                                                    REACTION_ID_MAP[
                                                                        reaction
                                                                            .key]!,
                                                                    height: 13,
                                                                    width: 13,
                                                                  ),
                                                                  Text(
                                                                    '${reaction.value} ',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          )
                                        : ChatListItem(
                                            Key(
                                              RandomUtil.getRandomString(10),
                                            ),
                                            message,
                                            _dialogType,
                                          ),
                                    onTapDown: (details) {
                                      tapPosition = details.globalPosition;
                                    },
                                    onLongPress: () {
                                      RenderBox? overlay = Overlay.of(context)
                                          ?.context
                                          .findRenderObject() as RenderBox;

                                      List<PopupMenuEntry> messageMenuItems = [
                                        if (message.qbMessage.body != null)
                                          PopupMenuWidget(
                                            height: 20,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                for (var reaction
                                                    in REACTION_ID_MAP.entries)
                                                  _reactWidget(
                                                    reaction.value,
                                                    () {
                                                      bloc?.events?.add(
                                                        ReactMessageEvent(
                                                          MessageActionReact(
                                                            chosenReactionId:
                                                                reaction.key,
                                                            currentUserId: message
                                                                .currentUserId
                                                                .toString(),
                                                            messageReactId: message
                                                                    .qbMessage
                                                                    .properties![
                                                                "messageReactId"]!,
                                                            reacts: (message
                                                                    as ReactionMessage)
                                                                .reacts,
                                                          ),
                                                        ),
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                        const PopupMenuItem(
                                          value: FORWARD_MESSAGE_MENU_ITEM,
                                          child: Text(
                                            "Forward",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ];

                                      List<PopupMenuItem> ownMessageMenuItems =
                                          [
                                        const PopupMenuItem(
                                          value: DELIVERED_TO_MENU_ITEM,
                                          child: Text(
                                            "Delivered to",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: VIEWED_BY_MENU_ITEM,
                                          child: Text(
                                            "Viewed by",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ];

                                      if (!message.isIncoming) {
                                        messageMenuItems
                                            .addAll(ownMessageMenuItems);
                                      }
                                      showMenu(
                                              context: context,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15.0))),
                                              color: Colors.white,
                                              position: RelativeRect.fromRect(
                                                  tapPosition &
                                                      const Size(40, 40),
                                                  Offset.zero & overlay.size),
                                              elevation: 8,
                                              items: messageMenuItems)
                                          .then((value) {
                                        switch (value) {
                                          case FORWARD_MESSAGE_MENU_ITEM:
                                            forwardMessage();
                                            break;
                                          case DELIVERED_TO_MENU_ITEM:
                                            showMessageDetailsScreen(
                                              message,
                                              isDeliveredTo: true,
                                            );
                                            break;
                                          case VIEWED_BY_MENU_ITEM:
                                            showMessageDetailsScreen(
                                              message,
                                              isDeliveredTo: false,
                                            );
                                            break;
                                        }
                                      });
                                    });
                              },
                              controller: _scrollController,
                            );
                          }),
                    ),
                  )),
              _buildProgress()
            ]),
          ),
          _buildEnterMessageRow()
        ],
      ),
    );
  }

  Widget _reactWidget(
    String imagePath,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Ink.image(
        image: AssetImage(
          imagePath,
        ),
        height: 25,
        width: 25,
      ),
    );
  }

  Widget _buildProgress() {
    return StreamProvider<ChatScreenStates>(
        create: (context) => bloc?.states?.stream as Stream<ChatScreenStates>,
        initialData: ChatConnectingState(),
        child: Selector<ChatScreenStates, ChatScreenStates>(
            selector: (_, state) => state,
            shouldRebuild: (previous, next) {
              return next is ChatConnectingState ||
                  next is ChatConnectingErrorState ||
                  next is UpdateChatErrorState ||
                  next is LoadMessagesInProgressState ||
                  next is LoadMessagesSuccessState;
            },
            builder: (_, state, __) {
              if (state is ChatConnectingErrorState) {
                NotificationBarUtils.showSnackBarError(context, state.error,
                    errorCallback: () {
                  bloc?.events?.add(ConnectChatEvent());
                });
              }
              if (state is ChatConnectingState ||
                  state is LoadMessagesInProgressState) {
                return Progress(Alignment.center);
              } else {
                return const SizedBox.shrink();
              }
            }));
  }

  Widget _buildEnterMessageRow() {
    return SafeArea(
      child: Column(
        children: [
          _buildTypingIndicator(),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: const Icon(
                      Icons.poll,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      final formKey = GlobalKey<FormState>();
                      final pollTitleController = TextEditingController();
                      final pollOption1Controller = TextEditingController();
                      final pollOption2Controller = TextEditingController();
                      final pollOption3Controller = TextEditingController();
                      final pollOption4Controller = TextEditingController();

                      await showModalBottomSheet(
                        isScrollControlled: true,
                        enableDrag: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.0),
                          ),
                        ),
                        context: context,
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                              // height: 500,
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      PollTextFieldRow(
                                        label: 'Enter Poll Title here',
                                        txtController: pollTitleController,
                                      ),
                                      PollTextFieldRow(
                                        label: 'Poll Option 1',
                                        txtController: pollOption1Controller,
                                      ),
                                      PollTextFieldRow(
                                        label: 'Poll Option 2',
                                        txtController: pollOption2Controller,
                                      ),
                                      PollTextFieldRow(
                                        label: 'Poll Option 3',
                                        txtController: pollOption3Controller,
                                      ),
                                      PollTextFieldRow(
                                        label: 'Poll Option 4',
                                        txtController: pollOption4Controller,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          TypingStatusManager.cancelTimer();
                                          bloc?.events?.add(
                                            CreatePollMessageEvent(
                                              PollActionCreate.fromData(
                                                pollTitleController.text.trim(),
                                                [
                                                  pollOption1Controller.text
                                                      .trim(),
                                                  pollOption2Controller.text
                                                      .trim(),
                                                  pollOption3Controller.text
                                                      .trim(),
                                                  pollOption4Controller.text
                                                      .trim(),
                                                ],
                                              ),
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Create Poll'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: SvgPicture.asset('assets/icons/attachment.svg'),
                    onPressed: () {
                      NotificationBarUtils.showSnackBarError(
                          context, "This feature is not available now");
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: const Icon(
                      Icons.sticky_note_2_rounded,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      stipop.show();
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 2, bottom: 2),
                    child: TextField(
                      onTap: () => stipop.hide(),
                      controller: _inputController,
                      onChanged: (text) {
                        TypingStatusManager.typing(
                          (TypingStates state) {
                            switch (state) {
                              case TypingStates.start:
                                bloc?.events?.add(StartTypingEvent());
                                break;
                              case TypingStates.stop:
                                bloc?.events?.add(StopTypingEvent());
                                break;
                            }
                          },
                        );
                      },
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.black26,
                        ),
                        hintText: "Send message...",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: SvgPicture.asset('assets/icons/send.svg'),
                    onPressed: () {
                      TypingStatusManager.cancelTimer();
                      bloc?.events?.add(
                        SendMessageEvent(
                          _inputController?.text,
                        ),
                      );
                      _inputController?.text = "";
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return StreamProvider<ChatScreenStates>(
      create: (context) => bloc?.states?.stream as Stream<ChatScreenStates>,
      initialData: OpponentStoppedTypingState(),
      child: Selector<ChatScreenStates, ChatScreenStates>(
        selector: (_, state) => state,
        shouldRebuild: (previous, next) {
          return next is OpponentIsTypingState ||
              next is OpponentStoppedTypingState ||
              next is LoadMessagesInProgressState;
        },
        builder: (_, state, __) {
          if (state is OpponentIsTypingState) {
            return Container(
              color: const Color(0xfff1f1f1),
              height: 35,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 16),
                  Text(
                    _makeTypingStatus(state.typingNames),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff6c7a92),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    String dialogName = "";
    return AppBar(
      centerTitle: true,
      backgroundColor: const Color(0xff3978fc),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            _leaveChatScreen();
          }),
      actions: <Widget>[
        _buildPopupMenuItems(),
      ],
      title: StreamBuilderWithListener<ChatScreenStates>(
          stream: bloc?.states?.stream as Stream<ChatScreenStates>,
          listener: (state) {
            if (state is ChatConnectedState) {
              bloc?.events?.add(UpdateChatEvent());
            }
            if (state is UpdateChatSuccessState) {
              if (state.dialog.name != null) {
                dialogName = state.dialog.name!;
              }
              _dialogType = state.dialog.type ?? 0;
            }
            if (state is LoadMessagesSuccessState) {
              NotificationBarUtils.hideSnackBar(context);
            }
            if (state is ReturnToDialogsState) {
              NotificationBarUtils.hideSnackBar(context);
              _leaveChatScreen();
            }
            if (state is ErrorState) {
              NotificationBarUtils.showSnackBarError(context, state.error);
            }
            if (state is UpdateChatErrorState) {
              NotificationBarUtils.showSnackBarError(context, state.error,
                  errorCallback: () {
                bloc?.events?.add(UpdateChatEvent());
              });
            }
            if (state is LeaveChatErrorState) {
              NotificationBarUtils.showSnackBarError(context, state.error,
                  errorCallback: () {
                bloc?.events?.add(LeaveChatEvent());
              });
            }
            if (state is DeleteChatErrorState) {
              NotificationBarUtils.showSnackBarError(context, state.error,
                  errorCallback: () {
                bloc?.events?.add(DeleteChatEvent());
              });
            }
            if (state is LoadNextMessagesErrorState) {
              NotificationBarUtils.showSnackBarError(context, state.error,
                  errorCallback: () {
                bloc?.events?.add(LoadNextMessagesPageEvent());
              });
            }
            if (state is SendMessageErrorState && state.messageToSend != null) {
              NotificationBarUtils.showSnackBarError(context, state.error,
                  errorCallback: () {
                bloc?.events?.add(SendMessageEvent(state.messageToSend));
              });
            }
          },
          builder: (context, state) {
            if (state.data is UpdateChatInProgressState ||
                state.data is LoadMessagesInProgressState) {
              return Container(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 15,
                  width: 15,
                  child: Progress(
                    Alignment.center,
                    color: Colors.white,
                  ),
                ),
              );
            }

            if (state.data is LoadMessagesSuccessState ||
                state.data is OpponentIsTypingState ||
                state.data is OpponentStoppedTypingState ||
                state.data is UpdateChatSuccessState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: _dialogType == QBChatDialogTypes.CHAT
                          ? _generateAvatarFromName(dialogName)
                          : null),
                  const SizedBox(width: 4),
                  Text(
                    dialogName,
                    style: const TextStyle(fontSize: 17),
                  )
                ],
              );
            }
            return const SizedBox.shrink();
          }),
    );
  }

  void _leaveChatScreen() {
    // bloc?.events?.add(LeaveChatScreenEvent());
    // NotificationBarUtils.hideSnackBar(context);
    // if (_isNewChat) {
    //   NavigationService().pushReplacementNamed(DialogsScreenRoute);
    // } else {
    //   Navigator.pop(context, DialogsScreen.FLAG_UPDATE);
    // }
  }

  Widget _buildPopupMenuItems() {
    List<PopupMenuItem>? menuItems = <PopupMenuItem>[];
    return StreamProvider<ChatScreenStates>(
      create: (context) => bloc?.states?.stream as Stream<ChatScreenStates>,
      initialData: ChatConnectingState(),
      child: Selector<ChatScreenStates, ChatScreenStates>(
          selector: (_, state) => state,
          shouldRebuild: (previous, next) {
            return next is LoadMessagesInProgressState;
          },
          builder: (_, state, __) {
            switch (_dialogType) {
              case QBChatDialogTypes.PUBLIC_CHAT:
                return const SizedBox.shrink();
              case QBChatDialogTypes.GROUP_CHAT:
                menuItems = [
                  const PopupMenuItem(
                    value: CHAT_INFO_MENU_ITEM,
                    child: Text(
                      "Chat Info",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: LEAVE_CHAT_MENU_ITEM,
                    child: Text(
                      "Leave Chat",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  )
                ];
                break;
              case QBChatDialogTypes.CHAT:
                menuItems = [
                  const PopupMenuItem(
                    value: DELETE_CHAT_MENU_ITEM,
                    child: Text(
                      "Delete Chat",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  )
                ];
                break;
              default:
                menuItems = null;
            }
            Widget popupMenu = PopupMenuButton(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                onSelected: (item) {
                  switch (item) {
                    case CHAT_INFO_MENU_ITEM:
                      _startChatInfoScreen(context);
                      break;
                    case LEAVE_CHAT_MENU_ITEM:
                      _showDialogExitChat(context, "Leave", LeaveChatEvent());
                      break;
                    case DELETE_CHAT_MENU_ITEM:
                      _showDialogExitChat(context, "Delete", DeleteChatEvent());
                      break;
                  }
                },
                itemBuilder: (context) => menuItems!);
            return popupMenu;
          }),
    );
  }

  void _showDialogExitChat(
      BuildContext context, String label, ChatScreenEvents event) {
    Widget okButton = TextButton(
        onPressed: () {
          // bloc?.events?.add(event);
          // Navigator.pop(context, DialogsScreen.FLAG_UPDATE);
        },
        child: Text(label));

    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Cancel"));

    AlertDialog alert = AlertDialog(
        backgroundColor: Colors.white,
        content: Text("$label chat?"),
        actions: [okButton, cancelButton]);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void _scrollListener() {
    double? maxScroll = _scrollController?.position.maxScrollExtent;
    double? currentScroll = _scrollController?.position.pixels;
    if (maxScroll == currentScroll && _hasMore) {
      bloc?.events?.add(LoadNextMessagesPageEvent());
    }
  }

  String _buildHeaderDate(int? timeStamp) {
    String completedDate = "";
    DateFormat dayFormat = DateFormat("d MMMM");
    DateFormat lastYearFormat = DateFormat("dd.MM.yy");

    DateTime now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var yesterday = DateTime(now.year, now.month, now.day - 1);

    timeStamp ??= 0;
    DateTime messageTime =
        DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);
    DateTime messageDate =
        DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (today == messageDate) {
      completedDate = "Today";
    } else if (yesterday == messageDate) {
      completedDate = "Yesterday";
    } else if (now.year == messageTime.year) {
      completedDate = dayFormat.format(messageTime);
    } else {
      completedDate = lastYearFormat.format(messageTime);
    }

    return completedDate;
  }

  String _makeTypingStatus(List<String> usersName) {
    const int MAX_NAME_SIZE = 20;
    const int ONE_USER = 1;
    const int TWO_USERS = 2;

    String result = "";
    int namesCount = usersName.length;

    switch (namesCount) {
      case ONE_USER:
        String firstUser = usersName[0];
        if (firstUser.length <= MAX_NAME_SIZE) {
          result = "$firstUser is typing...";
        } else {
          result = "${firstUser.substring(0, MAX_NAME_SIZE - 1)}??? is typing...";
        }
        break;
      case TWO_USERS:
        String firstUser = usersName[0];
        String secondUser = usersName[1];
        if ((firstUser + secondUser).length > MAX_NAME_SIZE) {
          firstUser = _getModifiedUserName(firstUser);
          secondUser = _getModifiedUserName(secondUser);
        }
        result = "$firstUser and $secondUser are typing...";
        break;
      default:
        String firstUser = usersName[0];
        String secondUser = usersName[1];
        String thirdUser = usersName[2];

        if ((firstUser + secondUser + thirdUser).length <= MAX_NAME_SIZE) {
          result = "$firstUser, $secondUser, $thirdUser are typing...";
        } else {
          firstUser = _getModifiedUserName(firstUser);
          secondUser = _getModifiedUserName(secondUser);
          result =
              "$firstUser, $secondUser and ${namesCount - 2} more are typing...";
          break;
        }
    }
    return result;
  }

  String _getModifiedUserName(String name) {
    const int MAX_NAME_SIZE = 10;
    if (name.length >= MAX_NAME_SIZE) {
      name = "${name.substring(0, (MAX_NAME_SIZE) - 1)}???";
    }
    return name;
  }

  Future<void> _startChatInfoScreen(BuildContext context) async {
    // NotificationBarUtils.hideSnackBar(context);
    // bloc?.events?.add(LeaveChatScreenEvent());
    // var resultList = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ChatInfoScreen(_dialogId),
    //     ));
    // if (resultList != null) {
    //   bloc?.events?.add(ReturnChatScreenEvent());
    //   bloc?.events?.add(UsersAddedEvent(resultList));
    // }
  }

  Widget _generateAvatarFromName(String name) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Color(ColorUtil.getColor(name)),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Future<void> showMessageDetailsScreen(QBMessageWrapper message,
      {bool? isDeliveredTo}) async {
    if (message.id == null) {
      NotificationBarUtils.showSnackBarError(context, "Message has no Id");
      return;
    }
    NotificationBarUtils.hideSnackBar(context);
    bloc?.events?.add(LeaveChatScreenEvent());
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => DeliveredViewedScreen(
    //           _dialogId, message.id!, isDeliveredTo ?? true),
    //     )).then((value) {
    //   bloc?.events?.add(ReturnChatScreenEvent());
    // });
  }

  void forwardMessage() {
    NotificationBarUtils.showSnackBarError(
        context, "This feature is not available now");
  }
}

class PollTextFieldRow extends StatelessWidget {
  final TextEditingController txtController;
  final String label;

  const PollTextFieldRow({
    super.key,
    required this.txtController,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: txtController,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              // width: 1,
              style: BorderStyle.solid,
              color: Colors.grey,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              // width: 1,
              style: BorderStyle.solid,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
