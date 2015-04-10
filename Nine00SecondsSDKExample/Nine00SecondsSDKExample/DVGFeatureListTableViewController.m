//
//  DVGFeatureListTableViewController.m
//  Nine00SecondsSDKExample
//
//  Created by Mikhail Grushin on 10.04.15.
//  Copyright (c) 2015 DENIVIP Group. All rights reserved.
//

#import "DVGFeatureListTableViewController.h"
#import "DVGStreamsMapViewController.h"
@import CoreLocation;

@interface DVGFeatureListTableViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@end

@implementation DVGFeatureListTableViewController

- (void)loadView {
    [super loadView];
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
            [CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapSegue"]) {
        DVGStreamsMapViewController *mapVC = (DVGStreamsMapViewController *)segue.destinationViewController;
        mapVC.initialCoordinates = self.userLocation;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count) {
        CLLocation *location = [locations firstObject];
        self.userLocation = location.coordinate;
        
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized ||
        status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
}

@end
