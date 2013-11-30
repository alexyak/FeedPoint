//
//  FeedListViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/3/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedData.h"
#import "PagingViewController.h"
#import "FeedPointAppDelegate.h"

@interface FeedListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, DataAvailableDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) FeedData *feedData;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* menuButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* markButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* shareButton;

@property (strong, nonatomic) PagingViewController* parentController;

-(void)selectItem:(NSInteger)index;

@property (nonatomic, strong) NSString* continuation;

@end
