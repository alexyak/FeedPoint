//
//  PagingViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/2/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingViewController : UIViewController<UIScrollViewDelegate> {
	UIScrollView* scrollView;
	UIPageControl* pageControl;
	
	BOOL pageControlBeingUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) IBOutlet UIToolbar* toolbar;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* menuButton;
//@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

- (IBAction)changePage;

-(void) ReloadData;

@end
