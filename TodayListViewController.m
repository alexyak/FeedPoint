 //
//  TodayListViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/17/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "TodayListViewController.h"
#import "FeedItemTableCell.h"
#import "FeedService.h"
#import "FeedItem.h"
#import "FeedPointAppDelegate.h"
#import "IconDownloader.h"
#import "PagingViewController.h"
#import "TodayViewController.h"
#import "FPWebViewController.h"
#import "WebViewController.h"

@interface TodayListViewController ()



@end

@implementation TodayListViewController
{
     FeedPointAppDelegate *app;
     NSMutableArray *items;
}



-(void) ReloadData{
    [self viewDidLoad];

}

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
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
 
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
    
    if (app.feedService.AuthToken){
        
        [self loadLatestFeeds];
           }
}

- (void)loadLatestFeeds
{
    items = [[NSMutableArray alloc] init];
    
    [app.feedService getTodayFeed:app.feedService.UserId top:20 continuation:nil sort:TRUE complete:^(FeedStream *results) {
        if (results.items.count > 0)
        {
            for(FeedItem *item in results.items)
            {
                FeedData * feedData = [[FeedData alloc] init];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zz"];
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
                 app.feedService.TodayItems = items;
                 PagingViewController* parent =(PagingViewController*) self.parentController;
                 TodayViewController* todayView = (TodayViewController*)[parent.viewArray objectAtIndex:0];
                 [todayView viewDidLoad];
                 
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    
    
    //FPWebViewController *webView = [[FPWebViewController alloc] initWithNibName:@"FPWebViewController" bundle:nil];
    //FeedData *item = [items objectAtIndex:indexPath.row];
    //webView.item = [item.items objectAtIndex:0];
    
   // UINavigationController* navController = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate).navigationController;
    
   // [navController pushViewController:webView animated:YES];
    
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    FeedData *item = [items objectAtIndex:indexPath.row];
    webViewController.dataArray = items;
    
    UINavigationController* navController = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate).navigationController;
    
    [navController pushViewController:webViewController animated:YES];
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    // [tableData removeObjectAtIndex:indexPath.row];
    
    // Request table view to reload
    [tableView reloadData];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)loadImagesForOnscreenRows
{
    if (items.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            //AppRecord *appRecord = [items objectAtIndex:indexPath.row];
            //FeedGroup *group = [items objectAtIndex:[indexPath section]];
            FeedData *feedItem = [items objectAtIndex:[indexPath row]];
            
              // [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            if (!feedItem.image)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:feedItem forIndexPath:indexPath];
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
            
           // UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:instance.appRecord.indexPath];
            
            // Display the newly loaded image
            //cell.imageView.image = instance.appRecord.image;
            
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


@end
