//
//  FPMainViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedData.h"

@interface FPMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(void) ReloadData;

-(void) populateGroups: (NSArray*) allItems unreadCounts: (NSArray*) unreadItems;

-(void) setFeedImage:(FeedData*) feedData;

- (void)startIconDownload:(FeedData *)appRecord forIndexPath:(NSIndexPath *)indexPath;

-(NSArray*) getImagesInHTML: (NSString*) html;

- (IBAction)sectionButtonClicked: (id)sender;

@property (nonatomic, retain) IBOutlet UITableView *tableView;



@end
