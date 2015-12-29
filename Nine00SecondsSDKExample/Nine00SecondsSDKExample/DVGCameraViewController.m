//
//  CameraViewController.m
//  Nine00SecondsSDKExample
//
//  Created by Mikhail Grushin on 24.12.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGCameraViewController.h"
#import "Nine00SecondsSDK.h"

@interface DVGCameraViewController () <NHSBroadcastManagerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *recButton;
@property (strong, nonatomic) IBOutlet UILabel *sentLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadClock;

@property (nonatomic, strong) NHSBroadcastManager *broadcastManager;
@property (nonatomic, strong) UIView *previewView;

@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (nonatomic, strong) NHSStream *stream;
@property (nonatomic, strong) NSTimer *uploadTimer;
@end

@implementation DVGCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Camera";
    
    self.broadcastManager = [NHSBroadcastManager sharedManager];
    self.broadcastManager.qualityPreset = NHSStreamingQualityPreset640HighBitrate;
    self.broadcastManager.delegate = self;
    self.previewView = [self.broadcastManager createPreviewViewWithRect:self.view.bounds];
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
    [self.broadcastManager stopPreview:NO];
    self.broadcastManager.delegate = nil;
    
    [self.uploadTimer invalidate];
    self.uploadTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.broadcastManager stopPreview:YES];
    [self.uploadTimer invalidate];
    self.uploadTimer = nil;
}

#pragma mark - Broadcasting actions
- (IBAction)toggleFilter:(id)sender {
    static int scotcher = 0;
    NSArray* validFilters = @[
                          @[@"No filter",@(NHSStreamingFilterNoFilter), [NSNull null]],
                          @[@"Sepia",@(NHSStreamingFilterSepia), [NSNull null]],
                          @[@"Black`n`White",@(NHSStreamingFilterSaturation), [NSNull null]],
                          @[@"Colorized",@(NHSStreamingFilterColorLookup), @{@"image":[UIImage imageNamed:@"lookup_amatorka.png"]}],
                          @[@"Blur",@(NHSStreamingFilterBlur), @{@"blurRadiusAsFractionOfImageWidth":@(0.02)}],
                          @[@"Vignette",@(NHSStreamingFilterVignette), @{@"vignetteStart":@(0.3), @"vignetteEnd":@(0.75)}],
                          @[@"Pixellate",@(NHSStreamingFilterPixellate), @{@"fractionalWidthOfAPixel":@(0.02)}]
                          ];
    scotcher = (scotcher+1)%[validFilters count];
    NHSStreamingFilter filter = [[[validFilters objectAtIndex:scotcher] objectAtIndex:1] intValue];
    NSDictionary* params = [[validFilters objectAtIndex:scotcher] objectAtIndex:2];
    [self.filterButton setTitle:[[validFilters objectAtIndex:scotcher] objectAtIndex:0] forState:UIControlStateNormal];
    [self.broadcastManager setupCameraFilter:filter withParams:(id)params == [NSNull null]?nil:params];
}

- (void)startBroadcast {
    self.sentLabel.text = @"KB sent : 0";
    self.uploadClock.text = @"Starting...";
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
        if(time > 0){
            int seconds = ((int)time)%60;
            int minutes = time/60;
            //int milliseconds = (int)((time - minutes - seconds)*100);
            
            self.uploadClock.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        }
    }
    
    self.sentLabel.text = [NSString stringWithFormat:@"KB sent : %.0f", self.broadcastManager.currentStreamBytesSent/1000.f];
}

- (void)tapToFocus:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [recognizer locationInView:self.previewView];
        [[NHSBroadcastManager sharedManager] showFocusAreaAt:tapPoint withPreview:self.previewView];
    }
}

#pragma mark - Broadcast delegate

- (void)broadcastManager:(NHSBroadcastManager *)manager didStartBroadcastWithStream:(NHSStream *)stream {
    if (stream) {
        NSLog(@"Started streaming: Stream %@", stream);
        self.recButton.selected = YES;
        self.stream = stream;

        self.uploadTimer = [NSTimer timerWithTimeInterval:.1f target:self selector:@selector(uploadTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.uploadTimer forMode:NSDefaultRunLoopMode];
        
        [UIView animateWithDuration:.25f animations:^{
            self.sentLabel.alpha = 1.f;
            self.uploadClock.alpha = 1.f;
        }];
    }
}

- (void)broadcastManager:(NHSBroadcastManager *)manager didCreatePreviewImageForStreamWithID:(NSString *)streamID image:(UIImage *)previewImage {
    NSLog(@"Stream %@ created preview image %.0fx%.0f", streamID, previewImage.size.width, previewImage.size.height);
}

- (void)broadcastManager:(NHSBroadcastManager *)manager didUpdateLocationForStreamWithID:(NSString *)streamID withCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"Stream %@ updated it's location to %f,%f", streamID, coordinate.latitude, coordinate.longitude);
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
