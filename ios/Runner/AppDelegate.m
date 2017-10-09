#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* qrcode_readerChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"qrcode_reader"
                                            binaryMessenger:controller];
    
    [qrcode_readerChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // TODO
    }];

    
    [qrcode_readerChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"readQRCode" isEqualToString:call.method]) {
            int qrcode = [self getQRCode];
            
            if (qrcode == -1) {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                           message:@"QRCode unavailable"
                                           details:nil]);
            } else {
                result(@(qrcode));
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


- (int)getQRCode {
    UIDevice* device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        return -1;
    } else {
        return (int)(device.batteryLevel * 100);
    }
}

@end
