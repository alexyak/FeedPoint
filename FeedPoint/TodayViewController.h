//
//  TodayViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/14/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagingViewController.h"

@interface TodayViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* sourceLabel;
@property (nonatomic, retain) IBOutlet UILabel* dateLabel;
@property (nonatomic, retain) IBOutlet UIButton* button;

@property (strong, nonatomic) NSString* todayTitle;
@property (strong, nonatomic) NSString* todaySource;
@property (strong, nonatomic) NSString* todayDate;
@property (strong, nonatomic) UIImage* todayImage;



-(IBAction) titleClick:(id)sender;

-(void) ReloadData;

@end

