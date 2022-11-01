// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/conversation.dart';
import 'package:flutter_module/push.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit_calling_plugin/model/TIMUIKitCallingListener.dart';
import 'package:tim_ui_kit_push_plugin/tim_ui_kit_push_plugin.dart';
import 'package:tim_ui_kit_calling_plugin/tim_ui_kit_calling_plugin.dart';

/// The entrypoint for the flutter module.
void main() {
  // This call ensures the Flutter binding has been set up before creating the
  // MethodChannel-based model.
  WidgetsFlutterBinding.ensureInitialized();

  final model = ChatInfoModel();

  runApp(
    ChangeNotifierProvider.value(
      value: model,
      child: const MyApp(),
    ),
  );
}

class ChatInfo {
  String? sdkappid;
  String? userSig;
  String? userID;

  ChatInfo.fromJSON(Map<String, dynamic> json) {
    sdkappid = json["sdkappid"].toString();
    userSig = json["userSig"].toString();
    userID = json["userID"].toString();
  }

}

/// A simple model that uses a [MethodChannel] as the source of truth for the
/// state of a counter.
///
/// Rather than storing app state data within the Flutter module itself (where
/// the native portions of the app can't access it), this module passes messages
/// back to the containing app whenever it needs to increment or retrieve the
/// value of the counter.
class ChatInfoModel extends ChangeNotifier {
  final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  final V2TIMManager _sdkInstance = TIMUIKitCore.getSDKInstance();
  final ChannelPush channelPush = ChannelPush();
  final PushAppInfo appInfo = PushAppInfo(
      apple_buz_id: 35763
  );

  final push = TimUiKitPushPlugin(isUseGoogleFCM: false);
  final TUICalling _calling = TUICalling();
  late TUICallingListener _onRtcListener;

  ChatInfoModel() {
    _channel.setMethodCallHandler(_handleMessage);
    _channel.invokeMethod<void>('requestChatInfo');
    _onRtcListener = TUICallingListener(onInvited:
        (params) {
      _channel.invokeMethod<void>('launchChat');
    });
  }

  final _channel = const MethodChannel('com.tencent.chat/add-to-ios');

  ChatInfo? _chatInfo;

  bool _isInit = false;

  bool get isInit => _isInit;

  set isInit(bool value) {
    _isInit = value;
    notifyListeners();
  }

  set chatInfo(ChatInfo? value) {
    _chatInfo = value;
    notifyListeners();
    if(value != null && value.sdkappid != null && value.userID != null && value.userSig != null){
      Future.delayed(const Duration(seconds: 0), () => initChat());
    }
  }

  Future<void> initChat() async {
    if(isInit){
      return;
    }
    await _coreInstance.init(
        sdkAppID: int.parse(_chatInfo!.sdkappid!),
        loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
        onTUIKitCallbackListener: (callbackValue) {},
        listener: V2TimSDKListener());
    final res = await _coreInstance.login(
        userID: _chatInfo!.userID!, userSig: _chatInfo!.userSig!);
    if (res.code == 0) {
      isInit = true;
    }
    await _calling.init(
        sdkAppID: int.parse(_chatInfo!.sdkappid!),
        userID: _chatInfo!.userID!,
        userSig: _chatInfo!.userSig!);
    _calling.setCallingListener(_onRtcListener);
    await ChannelPush.init((msg) {
      print("Push Click ${msg}");
    }, appInfo);

    final tokenRes = await ChannelPush.uploadToken(appInfo);
    print("Push Upload Result ${tokenRes}");
  }

  ChatInfo? get chatInfo => _chatInfo;

  Future<dynamic> _handleMessage(MethodCall call) async {
    if (call.method == 'reportChatInfo') {
      final jsonString = call.arguments as String;
      try{
        final Map<String, dynamic> chatInfoMap = jsonDecode(jsonString) as Map<String, dynamic>;
        chatInfo = ChatInfo.fromJSON(chatInfoMap);
      }catch(e){
        print("error ${e.toString()}");
      }
    }
  }
}

/// The "app" displayed by this module.
///
/// It offers two routes, one suitable for displaying as a full screen and
/// another designed to be part of a larger UI.class MyApp extends StatelessWidget {
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tencent Cloud Chat',
      navigatorKey: TUICalling.navigatorKey,
      routes: {
        '/': (context) => const FullScreenView(),
        '/mini': (context) => const Contents(),
      },
    );
  }
}

/// Wraps [Contents] in a Material [Scaffold] so it looks correct when displayed
/// full-screen.
class FullScreenView extends StatelessWidget {
  const FullScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tencent Cloud Chat'),
      ),
      body: const Contents(),
    );
  }
}

class Contents extends StatelessWidget {

  const Contents({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaInfo = MediaQuery.of(context);
    final ChatInfoModel chatInfoModel = Provider.of<ChatInfoModel>(context);
    final ChatInfo? chatInfo = chatInfoModel.chatInfo;
    final bool isInit = chatInfoModel.isInit;

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          if(!isInit) Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.grey,
                size: 40,
              )
          ),
          if(isInit) const Conversation()
        ],
      ),
    );
  }
}
