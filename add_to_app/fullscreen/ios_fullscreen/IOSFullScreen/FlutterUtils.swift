//
//  FlutterUtils.swift
//  IOSFullScreen
//
//  Created by 王润霖 on 2022/11/1.
//

import Foundation
import UIKit
import Flutter
import FlutterPluginRegistrant
import Photos

struct ChatInfo: Codable {
    var sdkappid: String = "1400187352"
    var userSig: String = "eJwtjNEKgjAYRt9l1yH-Nrc1oZtAFiMKppG3gtN*oppmIUTvnqnf3XcOnA-J91n09h1JCIuArKaPlb-3WOOEKUAsuOSLe1bXMgSsSEJjALpWXLDZ9HjzI5VSMQ2KiZn6IWA3cgn-LQ1sxrDP09aEBz8O5rQtnDlc2rPNito1u5d2QQffc2WstGW6Id8ftfwweg__"
    var userID: String = "10045363"
}

public extension Encodable {
    func toJSONString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else{ return "" }
        guard let jsonStr = String(data: data, encoding: .utf8) else{ return "" }
        return jsonStr
    }
}

class FlutterUtils: NSObject {

    static let shared = FlutterUtils()
    
    var chatMethodChannel : FlutterMethodChannel?
    var callingMethodChannel : FlutterMethodChannel?
    var chatFlutterEngine : FlutterEngine?
    var callingFlutterEngine : FlutterEngine?
    
    var chatInfo: ChatInfo = ChatInfo()
    var mainView: UIViewController?
    
    // Make sure the class has only one instance
    // Should not init or copy outside
    private override init() {
        super.init()
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Flutter - Chat
        chatFlutterEngine = appDelegate.flutterEngines.makeEngine(withEntrypoint: "chatMain", libraryURI: nil)
        GeneratedPluginRegistrant.register(with: chatFlutterEngine!)
        chatMethodChannel = FlutterMethodChannel(name: "com.tencent.chat/add-to-ios",
                                                 binaryMessenger: chatFlutterEngine!.binaryMessenger)
        chatMethodChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if let strongSelf = self {
                switch(call.method) {
                case "requestChatInfo":
                    strongSelf.reportChatInfo()
                case "launchChat":
                    strongSelf.launchChatFunc()
                default:
                    print("Unrecognized method name: \(call.method)")
                }
            }
        })
        
        // Flutter - Calling
        
        
        
    }
    
    override func copy() -> Any {
        return self // FlutterUtils.shared
    }
    
    override func mutableCopy() -> Any {
        return self // FlutterUtils.shared
    }
    
    func initViewController(mainViewController: UIViewController){
        self.mainView = mainViewController
    }
    
    func reportChatInfo() {
        chatMethodChannel?.invokeMethod("reportChatInfo", arguments: chatInfo.toJSONString())
    }
    
    func launchChatFunc(){
        if self.chatFlutterEngine != nil && self.chatFlutterEngine!.viewController == nil {
            let flutterViewController = FlutterViewController(engine: self.chatFlutterEngine!, nibName: nil, bundle: nil)
            mainView?.present(flutterViewController, animated: true, completion: nil)
        }
    }
    
    func triggerNotification(msg: String){
        launchChatFunc()
        chatMethodChannel?.invokeMethod("notification", arguments: msg)
    }
}
