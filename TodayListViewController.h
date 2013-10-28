//
//  TodayListViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/17/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagingViewController.h"

@interface TodayListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


-(void) ReloadData;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@property (strong, nonatomic) PagingViewController* parentController;

@end
