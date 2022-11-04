#
# Generated file, do not edit.
#

Pod::Spec.new do |s|
  s.name             = 'FlutterPluginRegistrant'
  s.version          = '0.0.1'
  s.summary          = 'Registers plugins with your Flutter app'
  s.description      = <<-DESC
Depends on all your plugins, and provides a function to register them.
                       DESC
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'BSD' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.ios.deployment_target = '11.0'
  s.source_files =  "Classes", "Classes/**/*.{h,m}"
  s.source           = { :path => '.' }
  s.public_header_files = './Classes/**/*.h'
  s.static_framework    = true
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.dependency 'Flutter'
  s.dependency 'camera_avfoundation'
  s.dependency 'disk_space'
  s.dependency 'file_picker'
  s.dependency 'firebase_core'
  s.dependency 'firebase_messaging'
  s.dependency 'flutter_apns_only'
  s.dependency 'flutter_image_compress'
  s.dependency 'flutter_local_notifications'
  s.dependency 'flutter_plugin_record_plus'
  s.dependency 'fluttertoast'
  s.dependency 'image_gallery_saver'
  s.dependency 'image_picker_ios'
  s.dependency 'open_file'
  s.dependency 'package_info_plus'
  s.dependency 'path_provider_ios'
  s.dependency 'permission_handler_apple'
  s.dependency 'photo_manager'
  s.dependency 'plain_notification_token'
  s.dependency 'shared_preferences_ios'
  s.dependency 'sqflite'
  s.dependency 'tencent_im_sdk_plugin'
  s.dependency 'tencent_trtc_cloud'
  s.dependency 'tim_ui_kit_push_plugin'
  s.dependency 'url_launcher_ios'
  s.dependency 'video_player_avfoundation'
  s.dependency 'video_thumbnail'
  s.dependency 'wakelock'
end
