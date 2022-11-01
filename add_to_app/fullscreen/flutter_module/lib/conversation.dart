import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

import 'chat.dart';

class Conversation extends StatelessWidget {
  const Conversation({super.key});

  String? _getConvID(V2TimConversation conversation) {
    return conversation.type == 1 ? conversation.userID : conversation.groupID;
  }

  ConvType _getConvType(V2TimConversation conversation) {
    return conversation.type == 1 ? ConvType.c2c : ConvType.group;
  }

  @override
  Widget build(BuildContext context) {
    void handleOnConvItemTaped(V2TimConversation selectedConv) {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => Chat(
              conversationID: _getConvID(selectedConv) ?? "",
              conversationType: _getConvType(selectedConv),
              conversationShowName: selectedConv.showName ?? "Chat",
            ),
          ));
    }

    return TIMUIKitConversation(
      onTapItem: handleOnConvItemTaped,
    );
  }
}
