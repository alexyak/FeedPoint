//
//  PagingScrollViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/13/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "PagingScrollViewController.h"
#import "PageViewController.h"
//#import "IonIcons.h"
#import "FeedItem.h"
#import "FeedPointAppDelegate.h"
#import "FeedData.h"
#import "FeedListViewController.h"
#import "FAKIcon.h"
#import "FAKIonIcons.h"


@interface PagingScrollViewController (){
    FeedPointAppDelegate *app;
    NSString* continuation;
    FeedListViewController* feedList;
    UIButton *listButton;
    NSInteger _minReusablePageIndex;
    NSInteger currentPageIndex;
    BOOL loading;
    BOOL manualScrolling;
    BOOL goingBack;
    NSMutableDictionary* controllerArray;
    UIImage* listButtonImage;
}

@end

@implementation PagingScrollViewController

@synthesize scrollView;

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UIWebView* wb =  webView;
}

-(BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    //if (!self.poppedInCode) {
        // back button was tapped
    //}
    
    // set to false ready for the next pop
    //self.poppedInCode = FALSE;
}

- (void)displayPage:(NSInteger)pageIndex
{
    [self setupScrollViewForDisplayingPage:pageIndex skip:FALSE];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if ( numberOfPages < self.numberOfReusableViews )
    {
        self.numberOfReusableViews = numberOfPages;
    }
    _numberOfPages = numberOfPages;
}

-(void)showItem: (NSInteger)newPageIndex
{
    scrollView.hidden = NO;
    listButton.hidden = NO;
    [self setupScrollViewForDisplayingPage:newPageIndex skip:FALSE];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:listButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(listButtonClicked:)];
    
    [[self navigationItem] setRightBarButtonItem:doneButton];
    //if (currentPage.pageIndex != newPageIndex)
	//{
	//	PageViewController *swapController = currentPage;
	//	currentPage = nextPage;
	//	nextPage = swapController;
	//}
    
	//[currentPage updateWebView:YES];
}

- (void)setupScrollViewForDisplayingPage:(NSInteger)pageIndex skip: (BOOL)skipOffset
{
    //if (pageIndex == currentPageIndex && currentPageIndex > 0)
    //    return;
    
    NSInteger minPageIndex = MAX(0, pageIndex - (_numberOfReusableViews - 1) / 2.0);
    NSInteger maxPageIndex = MIN(_numberOfPages, pageIndex + (_numberOfReusableViews - 1) / 2.0);
    
    NSLog(@"minPageIndex:%i maxPageIndex:%i", minPageIndex, maxPageIndex);
    
    // remove unused views
    
    for ( NSNumber *index in _scrollViewAvailablePages.allKeys )
    {
        if ( index.integerValue < minPageIndex || index.integerValue > maxPageIndex )
        {
            [_scrollViewAvailablePages[index] removeFromSuperview];
            [_scrollViewAvailablePages removeObjectForKey:index];
            [controllerArray removeObjectForKey:index];
        }
    }
    
    // add in new views
    for ( NSInteger i = minPageIndex; i <= maxPageIndex; i++ )
    {
        UIView *viewForPage = _scrollViewAvailablePages[@(i)];
        if ( viewForPage == nil )
        {
            //UIView* viewController = [self viewForScrollView: i];
            viewForPage = [self viewForScrollView: i];
            //
            //[scrollView addSubview:viewController.view];
            
            //viewController.myWebView.delegate = self;
            //[viewController setIndex:i];
            [_scrollViewAvailablePages setObject:viewForPage forKey:@(i)];
        }
        
        viewForPage.frame = CGRectMake((i - minPageIndex) * scrollView.frame.size.width, 0, viewForPage.frame.size.width, viewForPage.frame.size.height);
    }
    
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * (maxPageIndex - minPageIndex + 1), scrollView.frame.size.height);
    
    if (!skipOffset)
    {
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * (pageIndex - minPageIndex), 0);
    }
    else
    {
        //[self.scrollView setContentOffset: CGPointMake(scrollView.frame.size.width * (pageIndex - minPageIndex), 0) animated:FALSE];
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * (pageIndex - minPageIndex), 0);

    }

    
    currentPageIndex = pageIndex;
    _minReusablePageIndex = minPageIndex;
   
}

-(UIView*) viewForScrollView: (NSInteger)i
{
    PageViewController* viewController = [[PageViewController alloc] initWithNibName:@"PageViewController" bundle:nil];
    viewController.pagingController = self;
    viewController.dataArray = self.dataArray;
    FeedData* feedData = [[self dataArray] objectAtIndex:i];
    FeedItem* feedItem = feedData.items[0];
    [scrollView addSubview: viewController.view];
     [viewController setIndex:i];
    [self.navigationItem setTitle:feedItem.origin.title];
    [controllerArray setObject:viewController forKey:@(i)];
    return viewController.view;
}


- (void)viewDidLoad
{
    app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
    
    self.navigationController.navigationBar.topItem.title = @"";
    controllerArray = [NSMutableDictionary dictionary];
    
    
    feedList = [[FeedListViewController alloc] initWithNibName:@"FeedListViewController" bundle:nil];
    
    
    manualScrolling = FALSE;
    goingBack = FALSE;
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 64;
    frame.size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - 104);
    
    //feedList.parentViewController = self;
    
    [self addChildViewController:feedList];
    
    [self.view addSubview :feedList.view];
    [feedList.view setFrame:frame];
    
    feedList.view.hidden = YES;
    
    FAKIcon *listIcon = [FAKIonIcons dragIconWithSize:28.0];
    [listIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    listButtonImage = [listIcon imageWithSize: CGPointMake(0, 0) size: CGSizeMake(28.0f, 28.0f)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:listButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(listButtonClicked:)];
    
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    
    UIBarButtonItem *backButton = self.backButton;
    
    FAKIcon *backIcon = [FAKIonIcons ios7ArrowLeftIconWithSize:30.0];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
    backButton.image = [backIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];
    

    UIBarButtonItem *forwardButton = self.forwardButton;
    
    FAKIcon *forwardIcon = [FAKIonIcons ios7ArrowRightIconWithSize:30.0];
    [forwardIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
    forwardButton.image = [forwardIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];
    
    
    
    UIBarButtonItem *markButton = self.markButton;
    
   // [self.markButton addTarget:self action:@selector(markAsUnreadClicked) forControlEvents:UIControlEventTouchUpInside];
    
    FAKIcon *markIcon = [FAKIonIcons ios7CheckmarkOutlineIconWithSize:30.0];
    [markIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
    markButton.image = [markIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];
    

    
    UIBarButtonItem *shareButton = self.shareButton;
    
    FAKIcon *shareIcon = [FAKIonIcons ios7UploadOutlineIconWithSize:30.0];
    [shareIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
    shareButton.image = [shareIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];
    
    
    self.numberOfReusableViews = 5;
    _scrollViewAvailablePages = [@{} mutableCopy];
    
    if (self.dataArray == nil)
    {
        self.dataArray = [[NSMutableArray alloc] init];
        [self loadFeedItems: self.feedData];
        
    }
    else
    {
        feedList.dataArray = self.dataArray;
        self.numberOfPages = [self.dataArray count];
        if (self.selectedIndex > 0)
            [self displayPage:self.selectedIndex];
        else
            [self displayPage:0];
	}

}

-(void)initPages
{
    NSInteger widthCount = [[self dataArray] count];
	if (widthCount == 0)
	{
		widthCount = 3;
	}
	
    scrollView.contentSize =
    CGSizeMake(
               scrollView.frame.size.width * widthCount,
               scrollView.frame.size.height);

}

- (IBAction)listButtonClicked: (id)sender
{
    //scrollView.hidden = YES;
    [self.view bringSubviewToFront:feedList.view];
    
    feedList.view.hidden = NO;
    
    [self slideViewUpDown: feedList.view viewOut:scrollView direction:YES];
    
    [feedList selectItem:currentPageIndex];
    
    self.navigationItem.rightBarButtonItem = nil;
    //UIBarButtonItem* button = (UIBarButtonItem*) sender;
    //button.image. = YES;
}

- (void)slideViewUpDown: (UIView*)viewIn viewOut: (UIView*)viewOut direction:(BOOL)isUp {
    CGRect frame = viewIn.frame;
    CGFloat origY = 64.0f;
    
    frame.origin.y = (isUp) ? (-1)*viewIn.frame.size.height : viewIn.frame.size.height;
    viewIn.frame = frame;
    
    [UIView beginAnimations:nil context: (void*)viewOut];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(animationDone: finished: context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    frame.origin.y = origY;
    viewIn.frame = frame;
    [UIView commitAnimations];
}

- (void)animationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    
    UIView* view = (__bridge UIView*)context;
    view.hidden = YES;
}


- (IBAction)markAsUnreadClicked: (id)sender
{
    
    FeedData* feedData = [self.dataArray objectAtIndex:currentPageIndex];
    FeedItem* currentFeedItem = [feedData.items objectAtIndex:0];
    
    
    if (currentFeedItem != nil && currentFeedItem.isRead)
    {
        [self markAsUnRead: currentFeedItem];
    }
    
    //button.hidden = YES;
}


- (IBAction)shareClicked: (id)sender
{
    //scrollView.hidden = YES;
    //feedList.view.hidden = NO;
    //[feedList selectItem:currentPageIndex];
    
    //UIButton* button = (UIButton*) sender;
    //button.hidden = YES;
}


- (IBAction)backClicked: (id)sender
{
    NSInteger pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width + _minReusablePageIndex - 1;
    goingBack = TRUE;
    manualScrolling = TRUE;
    NSInteger prevPageIndex = scrollView.contentOffset.x / scrollView.frame.size.width - 1;
    if (prevPageIndex > -1)
        [self.scrollView setContentOffset: CGPointMake(scrollView.frame.size.width * prevPageIndex, 0) animated:TRUE];
}

- (IBAction)forwardClicked: (id)sender
{
    NSInteger pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width + _minReusablePageIndex + 1;
    
    manualScrolling = TRUE;
    NSInteger nextPage = scrollView.contentOffset.x / scrollView.frame.size.width + 1;
    
    if (nextPage < self.dataArray.count)
        [self.scrollView setContentOffset: CGPointMake(scrollView.frame.size.width * nextPage, 0) animated:TRUE];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    NSInteger pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width + _minReusablePageIndex;
    
   
    
    if (manualScrolling && currentPageIndex != pageIndex && pageIndex > 0)
    {
         NSLog(@"scrollViewDidScroll: pageIndex: %i", pageIndex);
        
         manualScrolling = FALSE;
        
        if (goingBack)
        {
            //pageIndex++;
            goingBack = FALSE;
        }
        
        [self setupScrollViewForDisplayingPage:pageIndex skip:TRUE];
        
        FeedData* feedData = [self.dataArray objectAtIndex:pageIndex];
        FeedItem* currentFeedItem = [feedData.items objectAtIndex:0];
        
        
        if (currentFeedItem != nil && !currentFeedItem.isRead)
        {
            [self markAsRead: currentFeedItem];
        }
        
        //currentPageIndex = pageIndex;
        
        
        FAKIcon *markIcon = [FAKIonIcons ios7CheckmarkOutlineIconWithSize:30.0];
        [markIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
        self.markButton.image = [markIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];
    
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width + _minReusablePageIndex;
    
    NSLog(@"scrollViewDidEndDecelerating: pageIndex: %i", pageIndex);
    
    [self setupScrollViewForDisplayingPage:pageIndex skip:FALSE];
    
    FeedData* feedData = [self.dataArray objectAtIndex:pageIndex];
    FeedItem* currentFeedItem = [feedData.items objectAtIndex:0];
    
    
    if (currentFeedItem != nil && !currentFeedItem.isRead)
    {
        [self markAsRead: currentFeedItem];
    }
    
    currentPageIndex = pageIndex;
    
    
    FAKIcon *markIcon = [FAKIonIcons ios7CheckmarkOutlineIconWithSize:30.0];
    [markIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
    self.markButton.image = [markIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];
    

    
    
    if (pageIndex > [self.dataArray count] - 5 && !loading)
    {
        loading = TRUE;
        [self loadFeedItems: self.feedData];
    }

}

-(void)markAsRead: (FeedItem*) item
{
    [app.feedService setAsRead:item.id complete:^(BOOL result) {
        if (result)
            item.isRead = true;
        else
            item.isRead = false;
    }];
}

-(void)markAsUnRead: (FeedItem*) item
{
    [app.feedService setAsUnRead:item.id complete:^(BOOL result) {
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                  
                    //self.markButton.image = [IonIcons imageWithIcon:icon_ios7_circle_outline
                    //                              iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
                    //                               iconSize:30.0f
                     //                             imageSize:CGSizeMake(30.0f, 30.0f)];
                
                
                FAKIcon *markIcon = [FAKIonIcons ios7CircleOutlineIconWithSize:30.0];
                [markIcon addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]];
                self.markButton.image = [markIcon imageWithSize: CGSizeMake(30.0f, 30.0f)];
                

                    item.isRead = false;
              });

        }
        
        else
            item.isRead = true;
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadFeedItems : (FeedData *) feedData
{
    
    int count = feedData.updatedCount;
    
    
    if (feedData.updatedCount > 21)
    {
        count = feedData.updatedCount - self.dataArray.count;
        if (count > 21)
        {
            count = 20;
        }
    }
    
    
    [app.feedService getFeedAsync:feedData.id top:count continuation:continuation sort:TRUE complete:^(FeedStream *result) {
        if (result.items.count > 0)
        {
            continuation = result.continuation;
            
            for(FeedItem *item in result.items)
            {
                FeedData * feedData = [[FeedData alloc] init];
                
                feedData.updated = [self setUpdatedDate:item.published];
                
                feedData.title = item.title;
                feedData.source = item.origin.title;
                feedData.id = item.origin.streamId;
                feedData.items = [[NSMutableArray alloc] init];
                [feedData.items addObject:item];
                
                if (item.visual != nil)
                {
                    if ([item.visual.url caseInsensitiveCompare: @"none"] != NSOrderedSame)
                        feedData.imageUrl = item.visual.url;
                    else
                    {
                        NSArray* imgs = [self getImagesInHTML: item.content.content];
                        if ([imgs count] > 0)
                        {
                            feedData.imageUrl = imgs[0];
                        }
                    }
                }
                else
                {
                    NSArray* imgs = [self getImagesInHTML: item.content.content];
                    if ([imgs count] > 0)
                    {
                        feedData.imageUrl = imgs[0];
                    }
                }
                
                
                [self.dataArray addObject:feedData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!loading)
                {
                    feedList.dataArray = self.dataArray;
                    feedList.feedData = feedData;
                    feedList.continuation = continuation;
                    [feedList viewDidLoad];
                    
                    self.numberOfPages = [self.dataArray count];
                    [self displayPage:0];
                }
                else
                {
                    self.numberOfPages = [self.dataArray count];
                    feedList.dataArray = self.dataArray;
                     feedList.continuation = continuation;
                    [feedList.tableView reloadData];
                }
                
                loading = FALSE;
                
            });
            
            
        }
        
    }];
    
}

-(NSString*)setUpdatedDate: (NSDate*) updatedDate
{
    NSDate *now = [NSDate date];
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:updatedDate];
    
    int hours = secondsBetween / 3600;
    int minutes = secondsBetween / 60;
    int numberOfDays = secondsBetween / 86400;
    
    NSCalendar       *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *updateDateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:updatedDate];
    
    NSDate *updatedDateOnly = [calendar dateFromComponents:updateDateComponents];
    
    
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:now];
    
    NSDate *nowDateOnly = [calendar dateFromComponents:nowComponents];
    
    if ([nowDateOnly isEqualToDate:updatedDateOnly])
    {
        if (hours == 0)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];
            NSString* result = [formatter stringFromDate:updatedDate];
            
            result = [result stringByAppendingString:[NSString stringWithFormat:@" (%i minutes ago)", minutes]];
            return result;
        }
        else if (hours > 1)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];
            NSString* result = [formatter stringFromDate:updatedDate];
            
            result = [result stringByAppendingString:[NSString stringWithFormat:@" (%i hours ago)", hours]];
            return result;
        }
        else
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];
            NSString* result = [formatter stringFromDate:updatedDate];
            
            result = [result stringByAppendingString:[NSString stringWithFormat:@" (%i hour ago)", hours]];
            return result;
        }
    }
    else if (numberOfDays == 1 || numberOfDays == 0)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy"];
        NSString* result = [formatter stringFromDate:updatedDate];
        
        result = [result stringByAppendingString:@" (yesterday)"];
        return result;
    }
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy"];
        NSString* result = [formatter stringFromDate:updatedDate];
        
        result = [result stringByAppendingString:[NSString stringWithFormat:@" (%i days ago)", numberOfDays]];
        
        return result;
    }
    
    return @"";
    
}


-(NSArray*) getImagesInHTML: (NSString*) rawHTML
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    if(rawHTML!=nil&&[rawHTML length]!=0) {
        NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"<\\s*?img\\s+[^>]*?\\s*src\\s*=\\s*([\"\'])((\\\\?+.)*?)\\1[^>]*?>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *imagesHTML = [regex matchesInString:rawHTML options:0 range:NSMakeRange(0, [rawHTML length])];
        
        
        for (NSTextCheckingResult *image in imagesHTML) {
            NSString *imageHTML = [rawHTML substringWithRange:image.range];
            
            // NSRegularExpression* regex2 = [[NSRegularExpression alloc] initWithPattern:@"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:nil];
            
            NSRegularExpression* regex2 = [[NSRegularExpression alloc] initWithPattern:@"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))" options:NSRegularExpressionCaseInsensitive error:nil];
            
            
            //\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))
            
            NSArray *imageSource=[regex2 matchesInString:imageHTML options:0 range:NSMakeRange(0, [imageHTML length])];
            
            
            NSString *imageSourceURLString=nil;
            for (NSTextCheckingResult *result in imageSource) {
                imageSourceURLString = [imageHTML substringWithRange:result.range];
            }
            
            if(imageSourceURLString==nil) {
                //DebugLog(@"No image found.");
            } else {
                NSLog(@"*** image found: %@", imageSourceURLString);
                //NSURL *imageURL=[NSURL URLWithString:imageSourceURLString];
                // if(imageURL!=nil) {
                [images addObject:imageSourceURLString];
                //  }
            }
        }
    }
    return images;
    
}



@end
