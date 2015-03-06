//
//  DVCapturePreviewView.h
//  Together
//
//  Created by Nikolay Morev on 6/26/12.
//  Copyright (c) 2012 kolia@denivip.ru. All rights reserved.
//

@import UIKit;
@import AVFoundation;

extern NSString * const NHSCapturePreviewViewUpdatePointOfInterest;

/**
 An instance of NHSCapturePreviewView is a subclass of UIView which layer is used by NHSBroadcastManager to show video from camera.
 */
@interface NHSCapturePreviewView : UIView

/**
 A preview layer which is used to show the video stream.
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/**
 Current focus point in the video frame coordinate system.
 */
@property (nonatomic, readonly) CGPoint focusPoint;

/**
 This method sets new point of interest for focusing.
 
 @param tapPoint Point on NHSCapturePreviewView in it's frame coordinate system. New focusPoint will automatically be evaluated with tapPoint.
 */
- (void)showFocusAtPoint:(CGPoint)tapPoint;

/**
 Call this method to force the focus layer to disappear.
 */
- (void)hideFocus;
@end
