//
//  QRCodeReaderPlugin.h
//  Runner
//
//  Created by Johan Henselmans on 09/10/2017.
//  Copyright © 2017 The Chromium Authors. All rights reserved.
//

#ifndef QRCodeReaderPlugin_h
#define QRCodeReaderPlugin_h


#endif /* QRCodeReaderPlugin_h */
#import <Flutter/Flutter.h>

static FlutterMethodChannel *channel;

@interface QRCodeReaderPlugin : NSObject<FlutterPlugin>
@property (nonatomic, retain) UIViewController *viewController;
//@property (nonatomic, retain) WebviewController *webviewController;
@end
