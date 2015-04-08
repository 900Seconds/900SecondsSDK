//
//  DVGStreamsMapViewController.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 10.11.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import "DVGStreamsMapViewController.h"
#import "Nine00SecondsSDK.h"
#import "NHSStream+MapKit.h"
#import "DVGStreamAnnotationView.h"
#import "DVGClusterAnnotationView.h"
#import "DVGStreamOverlayRenderer.h"
#import <kingpin/KPClusteringController.h>
#import <kingpin/KPAnnotation.h>
#import "DVGMKAnnotationUtilities.h"
#import "DVGStreamSelectionViewController.h"
#import "DVGStreamsDataController.h"
#import "AFHTTPRequestOperation.h"
@import MapKit;

@interface DVGStreamsMapViewController ()
<MKMapViewDelegate,
CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *playerBackgroundView;
// Only for requesting authorization.
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL didSnapToInitialLocation;
@property (copy, nonatomic) NSArray *streams;
@property (copy, nonatomic) NSArray *visibleStreams;
@property (nonatomic) NSInteger maxPopularity;
@property (nonatomic) NSDate *maxAgeDate;
@property (weak, nonatomic) AFHTTPRequestOperation *fetchRequestOperation;
@property (nonatomic, strong) NHSStream *selectedStream;
@property (nonatomic, strong) KPClusteringController *clusteringController;

@property (nonatomic, strong) NHSStreamPlayerController *playerController;

@end

@implementation DVGStreamsMapViewController

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _locationManager.delegate = nil;
    [_fetchRequestOperation cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initial location: Helsinki
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(60.171097, 24.941569), MKCoordinateSpanMake(0.5, 0.5));
    [self setNeedsToRefreshData];

    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.playerController && self.selectedStream) {
        [self.playerController hidePlayer];
        [self showPlayerWithStream:self.selectedStream];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
        [CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
    else {
        self.mapView.showsUserLocation = YES;
    }

    [self setNeedsToRefreshData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapList"]) {
        DVGStreamSelectionViewController *controller = segue.destinationViewController;
        
        DVGStreamsDataController *dataController = [[DVGStreamsDataController alloc] init];
        dataController.type = DVGStreamsDataControllerTypeLocation;
        dataController.coordinate = self.mapView.centerCoordinate;
        dataController.radius = [self radiusFromCurrentSpan];
        dataController.sinceDate = nil;

        controller.dataController = dataController;
        dataController.delegate = controller;
    }
}

- (void)showPlayerWithStream:(NHSStream *)stream {
    self.playerController = [[NHSStreamPlayerController alloc] initWithStream:stream];
    UIView *playerView = self.playerController.view;
    playerView.alpha = 0.f;
    playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 40.f, 200.f);
    
    playerView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view addSubview:playerView];
    
    [UIView animateWithDuration:.25f animations:^{
        self.playerBackgroundView.alpha = 1.f;
        playerView.alpha = 1.f;
    }];
}

#pragma mark -

- (void)snapToUserLocationAnimated:(BOOL)animated
{
    if (self.didSnapToInitialLocation) return;

    CLLocation *userLocation = self.mapView.userLocation.location;
    if (userLocation) {
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.5, 0.5));
        [self.mapView setRegion:region animated:animated];
        self.didSnapToInitialLocation = YES;
    }
}

- (void)setNeedsToRefreshData
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshData) object:nil];
    [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.25];
}

- (void)refreshData
{
    CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
    if (!CLLocationCoordinate2DIsValid(coordinate)) return;

    // Don't refresh if player is visible or it will screw up streams list
    if (self.presentedViewController) return;

    [self.fetchRequestOperation cancel];

    float radius = [self radiusFromCurrentSpan];
    @weakify(self);
    self.fetchRequestOperation = [[NHSBroadcastManager sharedManager] fetchStreamsNearCoordinate:coordinate withRadius:radius sinceDate:nil withCompletion:^(NSArray *streamsArray, NSError *error) {
        @strongify(self);
        if (streamsArray) {
            self.streams = streamsArray;
        }
    }];

    // Schedule next refresh in case the user stays inactive.
    [self performSelector:@selector(refreshData) withObject:nil afterDelay:30.0];
}

- (void)setStreams:(NSArray *)streams
{
    _streams = [streams copy];

    self.maxPopularity = 0;
    self.maxAgeDate = [NSDate date];
    for (NHSStream *stream in _streams) {
        if (stream.popularity > self.maxPopularity) self.maxPopularity = stream.popularity;
        if ([stream.createdAt compare:self.maxAgeDate] == NSOrderedAscending) self.maxAgeDate = stream.createdAt;
    }

    [self.clusteringController setAnnotations:_streams];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlays:_streams level:MKOverlayLevelAboveRoads];
}

- (float)radiusFromCurrentSpan {
    MKMapRect mapRect = self.mapView.visibleMapRect;
    
    MKMapPoint westPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
    MKMapPoint eastPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
    
    MKMapPoint northPoint = MKMapPointMake(MKMapRectGetMidX(mapRect), MKMapRectGetMinY(mapRect));
    MKMapPoint southPoint = MKMapPointMake(MKMapRectGetMidX(mapRect), MKMapRectGetMaxY(mapRect));
    
    CLLocationDistance latitudeDistance = MKMetersBetweenMapPoints(westPoint, eastPoint);
    CLLocationDistance longitudeDistance = MKMetersBetweenMapPoints(northPoint, southPoint);
    
    return MAX(latitudeDistance, longitudeDistance);
}

#pragma mark - Actions

- (IBAction)playerTapToClose:(id)sender {
    if (self.playerController) {
        [UIView animateWithDuration:.25f animations:^{
            self.playerController.view.alpha = 0.f;
            self.playerBackgroundView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.playerController hidePlayer];
            self.playerController = nil;
        }];
    }
}

#pragma mark - DVGPlayerViewControllerDelegate

//- (NSArray *)visibleStreams
//{
//    if (!_visibleStreams) {
//        NSSet *kingpinAnnotations = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
//        NSMutableSet *annotations = [NSMutableSet set];
//        for (id<MKAnnotation> annotation in kingpinAnnotations) {
//            if ([annotation isKindOfClass:[KPAnnotation class]]) {
//                [annotations addObjectsFromArray:[((KPAnnotation *)annotation).annotations allObjects]];
//            }
//        }
//
//        _visibleStreams = [annotations allObjects];
//    }
//    return _visibleStreams;
//}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        self.locationManager.delegate = nil;
        self.locationManager = nil;
        self.mapView.showsUserLocation = YES;
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *view;
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;
        if ([kingpinAnnotation isCluster]) {
            DVGClusterAnnotationView *pin = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ClusterAnnotation"];
            if (pin == nil) {
                pin = [[DVGClusterAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:@"ClusterAnnotation"];
                pin.canShowCallout = NO;
            }
            pin.annotation = kingpinAnnotation;

            float maxPopularity = 0.0, maxAge = 0.0;
            for (NHSStream *stream in kingpinAnnotation.annotations) {
                float popularity = self.maxPopularity == 0 ? 1.f : (float)stream.popularity / self.maxPopularity;
                if (maxPopularity < popularity) maxPopularity = popularity;
                float age = [stream.createdAt timeIntervalSinceDate:self.maxAgeDate] / [[NSDate date] timeIntervalSinceDate:self.maxAgeDate];
                if (maxAge < age) maxAge = age;
            }

            pin.popularity = maxPopularity;
            pin.age = maxAge;
            view = pin;
        }
        else {
            NHSStream *stream = (id)[kingpinAnnotation.annotations anyObject];
            DVGStreamAnnotationView *pin = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"StreamAnnotation"];
            if (!pin) {
                pin = [[DVGStreamAnnotationView alloc] initWithAnnotation:stream reuseIdentifier:@"StreamAnnotation"];
                pin.canShowCallout = NO;
                pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            }
            pin.annotation = stream;
            pin.blinking = stream.live;
            pin.popularity = self.maxPopularity == 0 ? 1.f : (float)stream.popularity / self.maxPopularity;
            pin.age = [stream.createdAt timeIntervalSinceDate:self.maxAgeDate] / [[NSDate date] timeIntervalSinceDate:self.maxAgeDate];
            
            view = pin;
        }
    }

    return view;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *overlayRenderer;
    if ([overlay isKindOfClass:[NHSStream class]]) {
        NHSStream *stream = (id)overlay;
        DVGStreamOverlayRenderer *renderer = [[DVGStreamOverlayRenderer alloc] initWithOverlay:overlay];
        renderer.popularity = self.maxPopularity == 0 ? 1.f : (float)stream.popularity / self.maxPopularity;
        overlayRenderer = renderer;
    }

    return overlayRenderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self snapToUserLocationAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.clusteringController refresh:YES];
    [self setNeedsToRefreshData];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    id<MKAnnotation> annotation = view.annotation;
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;
        if ([kingpinAnnotation isCluster]) {
            NSArray *annotations = [kingpinAnnotation.annotations allObjects];
            MKMapRect mapRect = DVGMKAnnotationsBoundingMapRect(annotations);
            [self.mapView setVisibleMapRect:mapRect
                                edgePadding:UIEdgeInsetsMake(20.f, 20.f, 20.f, 20.f)
                                   animated:YES];
        }
        else {
            NHSStream *stream = (id)[kingpinAnnotation.annotations anyObject];
            self.selectedStream = stream;
            self.selectedStreamCenter = [view.superview convertPoint:view.center toView:nil];
//            [self performSegueWithIdentifier:@"Player" sender:self];
            [self showPlayerWithStream:self.selectedStream];
        }
    }

    [mapView deselectAnnotation:annotation animated:NO];
}

@end
