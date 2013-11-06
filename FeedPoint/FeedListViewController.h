//
//  FeedListViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/3/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedData.h"

@interface FeedListViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) FeedData *feedData;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* menuButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* markButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* shareButton;

@end
