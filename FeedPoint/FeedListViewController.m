//
//  FeedListViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/3/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "FeedListViewController.h"

#import "FeedPointAppDelegate.h"
#import "FeedItem.h"
#import "FeedData.h"
#import "IconDownloader.h"
#import "FeedItemTableCell.h"
#import "NoImageTableCell.h"
#import "FPWebViewController.h"

@interface FeedListViewController ()
{
    NSMutableArray *items;
    
    FeedPointAppDelegate *app;
    NSString* continuation;
}

//FeedPointAppDelegate *app;


@end

@implementation FeedListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
    items = [[NSMutableArray alloc] init];
    
    if (app.feedService.AuthToken){
        
        [self loadFeedItems : self.feedData];
    }

}


- (void)loadFeedItems : (FeedData *) feedData
{
    
    int count = feedData.updatedCount;
    
    
    if (feedData.updatedCount > 21)
    {
        count = feedData.updatedCount - items.count;
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
                
                
                [items addObject:feedData];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData ];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 99;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
    
    [self loadMoreItems];
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
    [self loadMoreItems];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FPWebViewController *webView = [[FPWebViewController alloc] initWithNibName:@"FPWebViewController" bundle:nil];
    FeedData *item = [items objectAtIndex:indexPath.row];
    webView.item = [item.items objectAtIndex:0];
    
    UINavigationController* navController = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate).navigationController;
    
    [navController pushViewController:webView animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *feedItemIdentifier = @"FeedItemTableCell";
    static NSString *noImageIdentifier = @"NoImageTableCell";
    
    FeedItemTableCell * cell;
    
    if (items.count > 0)
    {
        
        FeedData *feedItem = [items objectAtIndex:indexPath.row];
        
        
        if (!feedItem.image)
        {
            //cell = [tableView dequeueReusableCellWithIdentifier:noImageIdentifier];
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:noImageIdentifier owner:self options:nil ];
            cell = [nib objectAtIndex:0 ];
            
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:feedItem forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.hidden = YES;
        }
        else
        {
            //cell = [tableView dequeueReusableCellWithIdentifier:feedItemIdentifier];
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:feedItemIdentifier owner:self options:nil ];
            cell = [nib objectAtIndex:0 ];
            
            cell.imageView.image = feedItem.image;
            cell.imageView.clipsToBounds = YES;
        }
        
        cell.titleLabel.text = feedItem.title;
        [cell.titleLabel sizeToFit];
        cell.nameLabel.text = feedItem.source;
        cell.updatedDateLabel.text = feedItem.updated;
        
    }
    return cell;
}

- (void)loadMoreItems
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    
    int lastCounter = [[visiblePaths objectAtIndex:visiblePaths.count - 1] row];
    
    if (lastCounter > (items.count - 5))
    {
        [self loadFeedItems: self.feedData];
    }
    
}


- (void)loadImagesForOnscreenRows
{
    if (items.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            FeedData *feedItem = [items objectAtIndex:[indexPath row]];
            
            if (!feedItem.image)
                // Avoid the app icon download if the app already has an icon
            {
                //[self startIconDownload:feedItem forIndexPath:indexPath];
            }
        }
    }
}


// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(FeedData *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"startIconDownload: %d %d", [indexPath section], [indexPath row]);
    //dispatch_async(dispatch_get_main_queue(), ^{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        appRecord.indexPath = indexPath;
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        [iconDownloader setCompletionHandler:^(IconDownloader *instance){
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:instance.appRecord.indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:appRecord.indexPath];
        
        [iconDownloader startDownload];
        
        
    }
    else
    {
        NSLog(@"startIconDownload skipped: %d %d", [indexPath section], [indexPath row]);
        
    }
    //     });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
