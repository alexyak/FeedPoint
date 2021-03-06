//
//  PagingViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/2/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "PagingViewController.h"
#import "TodayViewController.h"
#import "FPMainViewController.h"
#import "TodayListViewController.h"
//#import "IonIcons.h"
#import "FeedPointAppDelegate.h"
#import "FeedListViewController.h"
#import "FAKIonIcons.h"
#import "FAKIcon.h"


@implementation PagingViewController

@synthesize scrollView, pageControl;
//@synthesize imageArray;
@synthesize viewArray;

- (void) navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    //if (!self.poppedInCode) {
    // back button was tapped
    //}
    
    // set to false ready for the next pop
    //self.poppedInCode = FALSE;
}


-(void) ReloadData{
    
    //[self viewDidLoad];
    for (UIViewController *controller in viewArray)
    {
        [controller viewDidLoad];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    //249,242,231
    self.toolbar.backgroundColor = [[UIColor alloc] initWithRed:249.0 /255 green:242.0 /255 blue:231.0 /255 alpha:1.0];

    
    self.navigationController.navigationBar.backgroundColor = [[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    viewArray = [[NSMutableArray alloc] init];
    
    [self.navigationItem setTitle:@"Spotlight"];
    self.toolbar.hidden = YES;

    //UIFont *ionIconsFont = [IonIcons fontWithSize:30.0f];
    
    
    
    UIBarButtonItem *button = self.menuButton;
    
    //button.image = [IonIcons imageWithIcon:icon_navicon
    //                             iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
    //                              iconSize:30.0f
    //                             imageSize:CGSizeMake(30.0f, 30.0f)];
    
    FAKIcon *shareIcon = [FAKIonIcons naviconIconWithSize:30.0];
    [shareIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    button.image = [shareIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];

    
    
    //UIBarButtonItem *button = self.settingsButton;
    
    //self.settingsButton.image = [IonIcons imageWithIcon:icon_ios7_gear_outline
    //                             iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
    //                              iconSize:30.0f
    //                             imageSize:CGSizeMake(30.0f, 30.0f)];
    
    
    FAKIcon *settingsIcon = [FAKIonIcons ios7GearOutlineIconWithSize:30.0];
    [settingsIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
    self.settingsButton.image = [settingsIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];

    
    //[self.settingsButton setTitle: @"Settings"];
    
    
        //[button
     
     
     //self.scrollView.contentOffset = CGPointMake(0,32);
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    
    TodayViewController *todayController = [[TodayViewController alloc] initWithNibName:@"TodayViewController" bundle:nil];
 
    [self.viewArray addObject:(todayController)];
    
    //todayController.todayImage = [UIImage imageNamed:[imageArray objectAtIndex:0]];
    //todayController.todayTitle = @"This is some new title";
    //todayController.todaySource = @"Engadget";
    //todayController.todayDate = @"Mon 14, 2013";
    
    [todayController.view setFrame:frame];
    [self.scrollView addSubview:todayController.view];
    
    frame.origin.x = frame.size.width;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    frame.size.height = frame.size.height - 40;
    
    TodayListViewController *todayListViewController = [[TodayListViewController alloc] initWithNibName:@"TodayListViewController" bundle:nil];
    
    todayListViewController.parentController = self;
    
    [self.viewArray addObject:(todayListViewController)];
    [self.scrollView addSubview:todayListViewController.view];
    
    [todayListViewController.view setFrame:frame];
   
    frame.origin.x = frame.size.width * 2;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    frame.size.height = frame.size.height - 40;
    
    FPMainViewController *listViewController = [[FPMainViewController alloc] initWithNibName:@"FPMainViewController" bundle:nil];

    [self.viewArray addObject:(listViewController)];
    [self.scrollView addSubview:listViewController.view];

    [listViewController.view setFrame:frame];
    
    
    frame.origin.x = frame.size.width * 3;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    frame.size.height = frame.size.height - 40;
    
    FeedListViewController *feedListView = [[FeedListViewController alloc] initWithNibName:@"FeedListViewController" bundle:nil];
    
     feedListView.parentController = self;
    
    [self.viewArray addObject:(feedListView)];
    [self.scrollView addSubview:feedListView.view];
   
    
    [feedListView.view setFrame:frame];

   
   
    
    
    //Set the content size of our scrollview according to the total width of our imageView objects.
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 4, scrollView.frame.size.height);
    
    self.pageControl.numberOfPages = 4;
    self.scrollView.delegate = self;
	
    
   FeedPointAppDelegate* app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
   [app showWait];
}

- (IBAction)settingsButtonClicked: (id)sender
{
    
}

- (IBAction)menuButtonClicked: (id)sender
{
    
}


-(BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	//if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
//CGFloat pageWidth = self.scrollView.frame.size.width;
	//	int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	//	self.pageControl.currentPage = page;
	//}
    
    
    if (!pageControlBeingUsed)
    {
        NSLog(@"current page: %d", self.pageControl.currentPage );

        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
        if (self.pageControl.currentPage == 0)
        {
            [self.navigationItem setTitle:@"Spotlight"];
            self.toolbar.hidden = YES;
        }
        else if (self.pageControl.currentPage == 1){
            [self.navigationItem setTitle:@"Today"];
            self.toolbar.hidden = NO;
        }
        else if (self.pageControl.currentPage == 2)
        {
            [self.navigationItem setTitle:@"Categories"];
            self.toolbar.hidden = NO;
        }
        else if (self.pageControl.currentPage == 3)
        {
            [self.navigationItem setTitle:@"Uncategorized"];
             self.toolbar.hidden = NO;
            
        }
        
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
    
    NSLog(@"current page: %d", self.pageControl.currentPage );
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    if (self.pageControl.currentPage == 0)
    {
        [self.navigationItem setTitle:@"Spotlight"];
        self.toolbar.hidden = YES;
    }
    else if (self.pageControl.currentPage == 1){
        [self.navigationItem setTitle:@"Today"];
        self.toolbar.hidden = NO;
    }
    else if (self.pageControl.currentPage == 2)
    {
        [self.navigationItem setTitle:@"Categories"];
        self.toolbar.hidden = NO;
    }
    else if (self.pageControl.currentPage == 3)
    {
        [self.navigationItem setTitle:@"Uncategorized"];
        self.toolbar.hidden = NO;
        
    }

}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.scrollView = nil;
	self.pageControl = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
