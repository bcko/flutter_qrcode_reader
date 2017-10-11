// Copyright 2017 Johan Henselmans. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "QRCodeReaderPlugin.h"
static NSString *const CHANNEL_NAME = @"qrcode_reader";
static FlutterMethodChannel *channel;

@interface QRCodeReaderPlugin()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) UIView *viewPreview;
@property (nonatomic, strong) UIButton *buttonStop;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
-(BOOL)startReading;
-(void)stopReading;
@property (nonatomic, retain) UIViewController *viewController;

@end

@implementation QRCodeReaderPlugin {
    FlutterResult _result;
    UIViewController *_viewController;
    
}
float height;
float width;
float landscapeheight;
float portraitheight;


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL_NAME
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    QRCodeReaderPlugin* instance = [[QRCodeReaderPlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
    
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"readQRCode" isEqualToString:call.method]) {
        [self showQRCodeView:call];
        _result = result;
    } else if ([@"stopReading" isEqualToString:call.method]) {
        [self stopReading];
        result(@"stopped");
    }else {
        result(FlutterMethodNotImplemented);
    }
}


- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        [self loadViewQRCode];
        [self viewQRCodeDidLoad];
    }
    return self;
}


- (void)showQRCodeView:(FlutterMethodCall*)call {
    [ self startReading];
}


//-(void)loadView
-(void)loadViewQRCode
{
    //NSLog(@"loading QRCodeView");
    // At that moment I is not correct the layout do to the fact that I can not find out
    // what the orientation is.
    // I just take the lowest value, and with rotation all will still be visible.
    height = [UIScreen mainScreen].applicationFrame.size.height;
    width = [UIScreen mainScreen].applicationFrame.size.width;
    if (height < width){
        width = height;
    } else {
        height = width;
    }
}

//- (void)viewDidLoad {
//[super viewDidLoad];
- (void)viewQRCodeDidLoad {
    //TODO: make sure the orientation info of the view is available
    if (_viewController.interfaceOrientation == UIInterfaceOrientationPortrait || _viewController.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        portraitheight =  [UIScreen mainScreen].applicationFrame.size.height;
        landscapeheight = [UIScreen mainScreen].applicationFrame.size.width;
    } else {
        landscapeheight =  [UIScreen mainScreen].applicationFrame.size.height;
        portraitheight = [UIScreen mainScreen].applicationFrame.size.width;
    }
    // Normally the subviews are loaded from a nib, but we do it all programmatically in Flutter style.
    _viewPreview = [[UIView alloc] initWithFrame:CGRectMake(width/4, height/4, width/2, height/2) ];
    _viewPreview.backgroundColor = [UIColor blackColor];
    [_viewController.view addSubview:_viewPreview];
    _buttonStop =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _buttonStop.frame =  CGRectMake(width/2-width/4-(@"Stop".length)/2, (height/2)+(height/4), width/4, height/10);
    [_buttonStop setTitle:@"Stop"forState:UIControlStateNormal];
    [_buttonStop addTarget:self action:@selector(stopReading) forControlEvents:UIControlEventTouchUpInside];

    [_viewController.view addSubview:_buttonStop];

    _captureSession = nil;
    _isReading = NO;
    
}


//TODO: make sure that in the case of a rotation, the layout is rerendered.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation) || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        //self.view = portraitView;
        [self changeTheViewToPortrait:YES andDuration:duration];

    }
    else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        //self.view = landscapeView;
        [self changeTheViewToPortrait:NO andDuration:duration];
    }
}

- (void) changeTheViewToPortrait:(BOOL)portrait andDuration:(NSTimeInterval)duration{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    
    if(portrait){
//        NSLog(@"portrait");
        //change the view and subview frames for the portrait view
        height = portraitheight;
        width  = landscapeheight;
    }
    else{
//        NSLog(@"landscape");
        height = landscapeheight;
        width  = portraitheight;
        //change the view and subview  frames for the landscape view
    }
    _viewPreview.frame = CGRectMake(width/4, height/4, width/2, height/2) ;
    _buttonStop.frame =  CGRectMake(width/2-width/4-(@"Stop".length)/2, (height/2)+(height/4), width/4, height/10);

    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)startReading {
    if (_isReading) return NO;
    _isReading = YES;

    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    return YES;
}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
//            NSLog(@"result of scan: %@", [metadataObj stringValue]);
            _result([metadataObj stringValue]);
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
            
        }
    }
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
    _isReading = NO;
    _result(@"stopped");
}




@end


