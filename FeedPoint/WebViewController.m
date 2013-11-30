//
//  WebViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/3/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewCell.h"
#import "FeedData.h"
#import "FeedListViewController.h"
#import "FeedPointAppDelegate.h"

@interface WebViewController ()
{
    FeedPointAppDelegate *app;
    NSString* continuation;
    int currentIndex;
    NSIndexPath* currentIndexPath;
    int lastContentOffset;
    //WebViewCell *cell;
    NSMutableArray *webCells;
    FeedListViewController* feedList;
    FeedItem* currentFeedItem;
}


@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)setupCollectionView {
    [self.collectionView registerClass:[WebViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    //flowLayout.itemSize = CGSizeMake(100, 250);
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
}




- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if (lastContentOffset < (int)scrollView.contentOffset.x) {
        //left
        
    }
    else
    {
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem: currentIndexPath.row + 1 inSection:0];
        
        //int count = [self.collectionView numberOfItemsInSection :0];
        
        
        int count = [self.collectionView numberOfItemsInSection:0 ];
        
        if (currentIndex + 1 <= count)
        {
            WebViewCell* cell = (WebViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:newIndexPath];
            
            cell.item = nil;
            
            //[self.collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
            
           // cell = (WebViewCell *)[self.collectionView cellForItemAtIndexPath:newIndexPath];
            
            
            //[self.collectionView indexPathsForSelectedItems
            
            //FeedItem *feedItem = [((FeedData*)[self.dataArray objectAtIndex:newIndexPath.row]).items objectAtIndex:0];
            
            //cell.item = feedItem;
            
            //[self.navigationItem setTitle:feedItem.origin.title];
            
            //[cell updateCell];
            
            //[cell clear];
            
        }
       
        
        

        
    }
    
    lastContentOffset = (int)scrollView.contentOffset.x;
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    WebViewCell *webCell = (WebViewCell *)cell;
    webCell.item = nil;
    NSLog(@"didEndDisplaying: %d", indexPath.row);
    [webCell updateCell];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
    //return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (currentFeedItem != nil && !currentFeedItem.isRead)
    {
        [self markAsRead: currentFeedItem];
    }
    
    currentIndexPath = indexPath;
    WebViewCell *cell = (WebViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    //NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WebViewCell" owner:self options:nil ];
    //WebViewCell *cell = [nib objectAtIndex:0 ];
    //[collectionView reloadItemsAtIndexPaths: @[indexPath]];
    
    //[cell setNeedsDisplay];
    //int row = indexPath.row;
    
    currentFeedItem = [((FeedData*)[self.dataArray objectAtIndex:indexPath.row]).items objectAtIndex:0];
    
    cell.item = currentFeedItem;
    
    [self.navigationItem setTitle:currentFeedItem.origin.title];
    
    [cell updateCell];
   
    return cell;
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

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //CGSize size = self.collectionView.frame.size;
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    //return  self.collectionView.frame.size;
}

- (CGSize)collectionViewContentSize
{
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger pages = ceil(itemCount / 16.0);
    
    return CGSizeMake(320 * pages, self.collectionView.frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    webCells = [NSMutableArray array];
    
    
    app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
    
    feedList = [[FeedListViewController alloc] initWithNibName:@"FeedListViewController" bundle:nil];

    //feedList.view.hidden = YES;
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - 40);
    
    feedList.view.hidden = YES;
    
    [self.view addSubview :feedList.view];
    
    /*
    UIBarButtonItem *menuButton = self.menuButton;
    menuButton.image = [IonIcons imageWithIcon:icon_navicon
                                     iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *backButton = self.backButton;
    backButton.image = [IonIcons imageWithIcon:icon_ios7_arrow_left
                                     iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *forwardButton = self.forwardButton;
    forwardButton.image = [IonIcons imageWithIcon:icon_ios7_arrow_right
                                        iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
                                         iconSize:30.0f
                                        imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *markButton = self.markButton;
    markButton.image = [IonIcons imageWithIcon:icon_ios7_checkmark_outline
                                     iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *shareButton = self.shareButton;
    shareButton.image = [IonIcons imageWithIcon:icon_ios7_upload_outline
                                      iconColor:[[UIColor alloc] initWithRed:0.0 /255 green:168.0 /255 blue:198.0 /255 alpha:1.0]
                                       iconSize:30.0f
                                      imageSize:CGSizeMake(30.0f, 30.0f)];
    

    [self setupCollectionView];
    
    
    UIImage *buttonImage = [IonIcons imageWithIcon:icon_ios7_browsers_outline
                                          iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                           iconSize:20.0f
                                          imageSize:CGSizeMake(20.0f, 20.0f)];
    
    
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    
    
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    */
    
    //UIButton* fakeButton = (UIButton *) [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:icon_ios7_browsers_outline
  //                                                                                       iconColor:[[UIColor alloc] initWithRed:12.0 /255// green:95.0 /255 blue:254.0 /255 alpha:1.0]
      //                                                                                    iconSize:20.0f
        //                                                                                 imageSize:CGSizeMake(20.0f, 20.0f)]];
    
    
   // UIBarButtonItem *fakeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    
   // [aButton addTarget:self action:@selector(browserButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    //self.navigationItem.rightBarButtonItem = fakeButtonItem;
    
    //UIBarButtonItem *fakeButtonItem = [[UIBarButtonItem alloc] init];

    //fakeButtonItem.title = @"List";
    
   // self.navigationItem.rightBarButtonItem = fakeButtonItem;
    
    if (self.dataArray == nil)
    {
        self.dataArray = [[NSMutableArray alloc] init];
        [self loadFeedItems: self.feedData];
    }

}

- (IBAction)browserButtonClicked: (id)sender
{
    self.collectionView.hidden = YES;
    feedList.view.hidden = NO;
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
    
    
    [app.feedService getFeed:feedData.id top:count continuation:continuation sort:TRUE complete:^(FeedStream *result) {
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
                [self.collectionView reloadData ];
                //app.feedService.TodayItems = items;
                //PagingViewController* parent =(PagingViewController*) self.parentController;
                //TodayViewController* todayView = (TodayViewController*)[parent.viewArray objectAtIndex:0];
                //[todayView viewDidLoad];
                
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
    else if (numberOfDays == 1)
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
