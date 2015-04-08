//
//  CameraViewController.m
//  Nine00SecondsSDKExample
//
//  Created by Mikhail Grushin on 24.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import "DVGCameraViewController.h"
#import "Nine00SecondsSDK.h"

@interface DVGCameraViewController () <NHSBroadcastManagerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *recButton;
@property (strong, nonatomic) IBOutlet UILabel *sentLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadClock;

@property (nonatomic, strong) NHSBroadcastManager *broadcastManager;
@property (nonatomic, strong) NHSCapturePreviewView *previewView;

@property (nonatomic, strong) NHSStream *stream;
@property (nonatomic, strong) NSTimer *uploadTimer;
@end

@implementation DVGCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Camera";
    
    self.broadcastManager = [NHSBroadcastManager sharedManager];
    self.broadcastManager.delegate = self;
    self.previewView = self.broadcastManager.previewView;
    [self.view insertSubview:self.previewView belowSubview:self.recButton];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
    [self.previewView addGestureRecognizer:recognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.broadcastManager startPreview];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.previewView.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NHSBroadcastManager sharedManager] stopPreview];
    self.broadcastManager.delegate = nil;
    
    [self.uploadTimer invalidate];
    self.uploadTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NHSBroadcastManager sharedManager] stopPreview];
    
    [self.uploadTimer invalidate];
    self.uploadTimer = nil;
}

#pragma mark - Broadcasting actions

- (void)startBroadcast {
    [[NHSBroadcastManager sharedManager] startBroadcasting];
}

- (void)stopBroadcast {
    [[NHSBroadcastManager sharedManager] stopBroadcasting];
}

#pragma mark - Private interface

- (BOOL)isLandscape
{
    // При форсированном переключении ориентации size class не совпадает с interfaceOrientation.
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    if ([self respondsToSelector:@selector(traitCollection)]) { // iOS 8
        isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    }
    
    return isLandscape;
}

- (UIInterfaceOrientation)cameraInterfaceOrientation
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation;
    if (UIDeviceOrientationIsValidInterfaceOrientation(deviceOrientation)) {
        switch (deviceOrientation) {
            case UIDeviceOrientationLandscapeRight:
                interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                interfaceOrientation = UIInterfaceOrientationLandscapeRight;
                break;
                
            default:
                interfaceOrientation = (UIInterfaceOrientation)deviceOrientation;
                break;
        }
    }
    else {
        interfaceOrientation = ([self isLandscape] && !UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? UIInterfaceOrientationLandscapeRight : self.interfaceOrientation);
    }
    
    return interfaceOrientation;
}

#pragma mark - Actions

- (IBAction)tapRec:(id)sender {
    if (self.recButton.isSelected) {
        [self stopBroadcast];
    } else {
        [self startBroadcast];
    }
}

- (void)uploadTimerAction {
    if (self.uploadClock.alpha) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.stream.createdAt];
        
        int seconds = ((int)time)%60;
        int minutes = time/60;
        int milliseconds = (int)((time - minutes - seconds)*100);
        
        self.uploadClock.text = [NSString stringWithFormat:@"%02d:%02d:%02d", minutes, seconds, milliseconds];
    }
    
    self.sentLabel.text = [NSString stringWithFormat:@"KB sent : %.0f", self.broadcastManager.currentStreamBytesSent/1000.f];
}

- (void)tapToFocus:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [recognizer locationInView:self.previewView];
        [self.previewView showFocusAtPoint:tapPoint];
    }
}

#pragma mark - Broadcast delegate

- (void)broadcastManager:(NHSBroadcastManager *)manager didStartBroadcastWithStream:(NHSStream *)stream {
    if (stream) {
        NSLog(@"Started streaming: Stream %@", stream);
        self.recButton.selected = YES;
        self.stream = stream;
        
        self.sentLabel.text = @"KB sent : 0";
        
        self.uploadTimer = [NSTimer timerWithTimeInterval:.1f target:self selector:@selector(uploadTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.uploadTimer forMode:NSDefaultRunLoopMode];
        
        [UIView animateWithDuration:.25f animations:^{
            self.sentLabel.alpha = 1.f;
            self.uploadClock.alpha = 1.f;
        }];
    }
}

- (void)broadcastManagerDidFailToCreateStream:(NHSBroadcastManager *)manager withError:(NSError *)error {
    NSLog(@"Failed to create stream : %@", error);
}

- (void)broadcastManagerDidFailToStartRecording:(NHSBroadcastManager *)manager {
    NSLog(@"Failed to start recording");
}

- (void)broadcastManagerDidStopRecording:(NHSBroadcastManager *)manager {
    NSLog(@"Stopped recording");
    self.recButton.selected = NO;
    
    [UIView animateWithDuration:.25f animations:^{
        self.uploadClock.alpha = 0.f;
    }];
}

- (void)broadcastManager:(NHSBroadcastManager *)manager didStopBroadcastOfStream:(NHSStream *)stream {
    NSLog(@"Stopped broadcasting");
    
    [self.uploadTimer invalidate];
    [UIView animateWithDuration:.25f animations:^{
        self.sentLabel.alpha = 0.f;
    }];
}

- (UIInterfaceOrientation)broadcastManagerCameraInterfaceOrientation:(NHSBroadcastManager *)manager {
    return [self cameraInterfaceOrientation];
}

@end
