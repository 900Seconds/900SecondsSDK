//
//  DVGStreamSelectionViewController.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 03.10.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGStreamSelectionViewController.h"
#import "DVGStreamsDataController.h"
#import "Nine00SecondsSDK.h"
@import MediaPlayer;


@interface DVGStreamSelectionViewController ()


@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NHSStreamPlayerController *playerController;
@end

@implementation DVGStreamSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"List";
    
    if (!self.dataController) {
        DVGStreamsDataController *dataController = [[DVGStreamsDataController alloc] init];
        
        self.dataController = dataController;
        self.dataController.delegate = self;
    }

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    self.tableView.backgroundView = activityIndicator;
    [self.dataController refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
}

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterLongStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.doesRelativeDateFormatting = YES;
    }

    return _dateFormatter;
}

- (IBAction)refreshControlTriggered:(id)sender {
    [self.dataController refresh];
}

- (void)configureView
{
    if(self.tableView.backgroundView != nil){
        [self.refreshControl endRefreshing];
        self.tableView.backgroundView = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger c = self.dataController.streams.count;
    if(c<20){
        c = 20;
    }
    return c;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if(indexPath.row < [self.dataController.streams count]){
        NHSStream *stream = self.dataController.streams[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@",
                               [self.dateFormatter stringFromDate:stream.createdAt],
                               stream.live ? @" (LIVE)" : @""];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.25f;
        
        cell.detailTextLabel.text = stream.streamID;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.minimumScaleFactor = 0.25f;
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.f];
    }else{
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.playerController){
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    }
    if(indexPath.row < [self.dataController.streams count]){
        NHSStream *stream = self.dataController.streams[indexPath.row];
        [self showPlayerWithStream:stream];
    }
}

- (void)showPlayerWithStream:(NHSStream *)stream {
    self.playerController = [[NHSStreamPlayerController alloc] initWithStream:stream];
    UIView *playerView = self.playerController.view;
    playerView.alpha = 0.f;
    playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 40.f, 200.f);
    
    playerView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.superview addSubview:playerView];
    
    [UIView animateWithDuration:.25f animations:^{
        //self.playerBackgroundView.alpha = 1.f;
        playerView.alpha = 1.f;
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < [self.dataController.streams count]){
        NHSStream *stream = self.dataController.streams[indexPath.row];
        return !stream.live;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.row < [self.dataController.streams count]){
            [self.dataController removeStreamAtIndex:indexPath.row];
        }
    }
}

- (void)streamsDataControllerDidUpdateStreams:(DVGStreamsDataController *)controller
{
    self.title = [NSString stringWithFormat:@"List (%ld)", [self.dataController.streams count]];
    [self configureView];
    [self.tableView reloadData];
}

@end
