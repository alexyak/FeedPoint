//
//  PagingScrollViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/13/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedData.h"
#import "PageViewController.h"

@interface PagingScrollViewController : UIViewController<UIScrollViewDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate> {
	UIScrollView* scrollView;
    //PageViewController *prevPage;
    //PageViewController *currentPage;
	//PageViewController *nextPage;
    
    //int currentIndex;
    //int nextIndex;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) FeedData* feedData;
@property (nonatomic, assign) NSInteger  selectedIndex;


@property (nonatomic, assign) BOOL externalNavigated;

@property (nonatomic, strong) NSIndexPath* currentIndexPath;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* menuButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* markButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* shareButton;

- (IBAction)shareClicked: (id)sender;

-(void)showItem: (NSInteger)newPageIndex;



//BEGIN NEW STUFF

//@property (nonatomic, assign) id<ISPageScrollViewDataSource> dataSource;
@property (nonatomic, assign) NSInteger numberOfReusableViews;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, readonly) NSMutableDictionary *scrollViewAvailablePages;



//END NEW STUFF

@end
