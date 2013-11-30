//
//  PageViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/13/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedData.h"
#import "WebViewController.h"
#import "PagingScrollViewController.h"

@interface PageViewController : UIViewController<UIWebViewDelegate>
{
	NSInteger pageIndex;
	IBOutlet UIWebView *mywebView;
}

@property NSInteger pageIndex;

- (void)updateWebView:(BOOL)force;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) FeedData* feedData;
@property (nonatomic, strong) UIViewController* pagingController;

@property (nonatomic, retain) UIWebView *myWebView;

-(void)setIndex: (NSInteger)newPageIndex;


@end
