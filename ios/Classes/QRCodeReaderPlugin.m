#import "QRCodeReaderPlugin.h"

static NSString *const CHANNEL_NAME = @"qrcode_reader";
static FlutterMethodChannel *channel;

@interface QRCodeReaderPlugin()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) UIView *viewPreview;
@property (nonatomic, strong) UIView *qrcodeview;
@property (nonatomic, strong) UIButton *buttonCancel;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
-(BOOL)startReading;
-(void)stopReading;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) UIViewController *qrcodeViewController;
@property (nonatomic) BOOL isFrontCamera;
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
    NSDictionary *args = (NSDictionary *)call.arguments;
    self.isFrontCamera = [[args objectForKey: @"frontCamera"] boolValue];

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
        _viewController.view.backgroundColor = [UIColor clearColor];
        _viewController.view.opaque = NO;
        [[ NSNotificationCenter defaultCenter]addObserver: self selector:@selector(rotate:)
                                              name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}


- (void)showQRCodeView:(FlutterMethodCall*)call {
    _qrcodeViewController = [[UIViewController alloc] init];
    [_viewController presentViewController:_qrcodeViewController animated:NO completion:nil];

    if (@available(iOS 13.0, *)) {
        [_qrcodeViewController setModalInPresentation:(true) ];
        // [_qrcodeViewController setModalPresentationStyle:(UIModalPresentationFullScreen) ];
    } else {
        // Fallback on earlier versions
    }

    [self loadViewQRCode];
    [self viewQRCodeDidLoad];
    [self startReading];
}


- (void)closeQRCodeView {
    [_qrcodeViewController dismissViewControllerAnimated:YES completion:^{
        [channel invokeMethod:@"onDestroy" arguments:nil];
    }];
}


-(void)loadViewQRCode {
    portraitheight = height = [UIScreen mainScreen].applicationFrame.size.height;
    landscapeheight = width = [UIScreen mainScreen].applicationFrame.size.width;
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
        landscapeheight = height;
        portraitheight = width;
    }
    _qrcodeview= [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height) ];
    _qrcodeview.opaque = NO;
    _qrcodeview.backgroundColor = [UIColor whiteColor];
    _qrcodeViewController.view = _qrcodeview;
}


- (void)viewQRCodeDidLoad {
    _viewPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height+height/10) ];
    _viewPreview.backgroundColor = [UIColor whiteColor];
    [_qrcodeViewController.view addSubview:_viewPreview];
    _buttonCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    if (@available(iOS 13.0, *)) {
        _buttonCancel.frame = CGRectMake(width/2-width/8, (height-height/20)-30, width/4, height/20);
    } else {
        // Fallback on earlier versions
        _buttonCancel.frame = CGRectMake(width/2-width/8, height-height/20, width/4, height/20);
    }

    [_buttonCancel setTitle:@"CANCEL"forState:UIControlStateNormal];
    [_buttonCancel addTarget:self action:@selector(stopReading) forControlEvents:UIControlEventTouchUpInside];
    [_qrcodeViewController.view addSubview:_buttonCancel];
    _captureSession = nil;
    _isReading = NO;

}

- (BOOL)startReading {
    if (_isReading) return NO;
    _isReading = YES;
    NSError *error;
    AVCaptureDevice *captureDevice;
    if ([self isFrontCamera]) {
        captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType: AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                                mediaType: AVMediaTypeVideo
                                                                                position: AVCaptureDevicePositionFront];
    } else {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }

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
            _result([metadataObj stringValue]);
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
        }
    }
}


- (void) rotate:(NSNotification *) notification{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == 1) {
        height = portraitheight;
        width = landscapeheight;

        if (@available(iOS 13.0, *)) {
            _buttonCancel.frame = CGRectMake(width/2-width/8, (height-height/20)-30, width/4, height/20);
        } else {
            // Fallback on earlier versions
            _buttonCancel.frame = CGRectMake(width/2-width/8, height-height/20, width/4, height/20);
        }
    } else {
        height = landscapeheight;
        width = portraitheight;
        _buttonCancel.frame = CGRectMake(width/2-width/8, height-height/10, width/4, height/20);
    }
    _qrcodeview.frame = CGRectMake(0, 0, width, height) ;
    _viewPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height+height/10) ];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_qrcodeViewController viewWillLayoutSubviews];
}


-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
    _isReading = NO;
    [self closeQRCodeView];
    _result(nil);
}


@end
