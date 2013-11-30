//
//  CustomWebViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/11/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedData.h"

@interface CustomWebViewController : UIViewController<UIScrollViewDelegate> {
	UIScrollView* scrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) FeedData* feedData;

@end
