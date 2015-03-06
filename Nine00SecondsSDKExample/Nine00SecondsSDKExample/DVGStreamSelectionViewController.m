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
<DVGStreamsDataControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

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
    [self.refreshControl endRefreshing];

    if (self.dataController.streams.count) {
        self.tableView.backgroundView = nil;
    }
    else {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];

        self.tableView.backgroundView = activityIndicator;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataController.streams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
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

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NHSStream *stream = self.dataController.streams[indexPath.row];
    NHSStreamPlayerViewController *streamPlayer = [[NHSStreamPlayerViewController alloc] initWithStream:stream];
    [self presentMoviePlayerViewControllerAnimated:streamPlayer];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NHSStream *stream = self.dataController.streams[indexPath.row];
    return !stream.live;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataController removeStreamAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)streamsDataControllerDidUpdateStreams:(DVGStreamsDataController *)controller
{
    [self configureView];
    [self.tableView reloadData];
}

@end
