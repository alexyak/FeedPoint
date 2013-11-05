//
//  FPMainViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "FPMainViewController.h"
#import "FeedPointAppDelegate.h"
#import "FeedItemTableCell.h"
#import "FPWebViewController.h"
#import "FeedService.h"
#import "RSSItem.h"
#import "SubscriptionItem.h"
#import "UnreadItem.h"
#import "UnreadItems.h"
#import "FeedData.h"
#import "Category.h"
#import "Folder.h"
#import "FeedGroup.h"
#import "FeedItem.h"
#import "IconDownloader.h"
#import "IonIcons.h"
#import "FeedListViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FPMainViewController ()

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation FPMainViewController
{
    NSArray *tableData;
    NSArray *thumbnails;
    NSArray *prepTime;
    
    NSMutableArray *items;
    FeedPointAppDelegate *app;
    NSMutableDictionary *feedGroups;
    int currentSection;
    NSMutableDictionary *cachedImages;
}

-(void) ReloadData{
    
    [self viewDidLoad];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
      self.navigationItem.title = @"Engadget";
    
    items = [NSMutableArray array];
    cachedImages = [NSMutableDictionary dictionary];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
    
    if (app.feedService.AuthToken){
        
        [app.feedService getSubscriptions:@"test" complete:^(NSArray *results) {
            
            [app.feedService getUnreadCounts: ^(UnreadItems *unreadItems) {
                
                [self populateGroups:results unreadCounts:unreadItems.unreadcounts];
                
            }];
            
            
        }];
    }
    
}

-(void) setFeedImage:(FeedData*) feedData
{
    [app.feedService getFeed:feedData.id top:1 continuation:nil sort:TRUE complete:^(FeedStream *result) {
        if (result.items.count > 0)
        {
            FeedItem* item = (FeedItem*)[result.items objectAtIndex:0];
            
           // NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //[formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zz"];
            
            NSString* updatedDate = [self setUpdatedDate:item.published];
            updatedDate = [updatedDate stringByAppendingFormat:@" - %d unread items ", feedData.updatedCount];
                           
            feedData.updated = updatedDate;
            
            feedData.title = item.title;
            
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
        }
        
    }];
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

-(void)populateGroups: (NSArray *) allItems unreadCounts: (NSArray *) unreadItems
{
     dispatch_async(dispatch_get_main_queue(), ^{
         
    feedGroups = [NSMutableDictionary dictionary];
    NSMutableArray *unreadFeeds = [NSMutableArray array];
    
    for(SubscriptionItem *sub in allItems)
    {
        for(UnreadItem* unreadItem in unreadItems)
        {
            if ([sub.id compare: unreadItem.id] == NSOrderedSame)
            {
                if (unreadItem.count > 0)
                {
                    FeedData *feedData = [[FeedData alloc] init];
                    feedData.source = sub.title;
                    feedData.id  = sub.id;
                    feedData.updatedCount = unreadItem.count;
                    feedData.updated = sub.updated;
                    if (sub.categories.count > 0)
                    {
                        FeedCategory *category = [sub.categories objectAtIndex:0];
                        feedData.category = category.label;
                    }
                    
                    [unreadFeeds addObject:feedData];
                }
            }
        }
    }
    
    FeedGroup *feedGroupUncategorized = [[FeedGroup alloc] init];
    feedGroupUncategorized.title = @"Uncategorized";
    feedGroupUncategorized.items = [[NSMutableArray alloc] init];
    [feedGroups setObject:feedGroupUncategorized forKey:@"Uncategorized"];
    //[items addObject:feedGroupUncategorized];
    
    // Get folders first
    for(FeedData *feedData in unreadFeeds)
    {
        if (feedData.category)
        {
            if ([feedGroups objectForKey:feedData.category] == nil)
            {
                FeedGroup *feedGroup = [[FeedGroup alloc] init];
                feedGroup.title = feedData.category;
                feedGroup.items = [[NSMutableArray alloc] init];
                [self setFeedImage:feedData];
                [feedGroup.items addObject:feedData];
                [items addObject:feedGroup];
                feedGroup.updatedCount += feedData.updatedCount;
                [feedGroups setObject:feedGroup forKey:feedData.category];
                
                
            }
            else
            {
                FeedGroup *feedGroup = [feedGroups objectForKey:feedData.category];
                [self setFeedImage:feedData];
                feedGroup.updatedCount += feedData.updatedCount;
                [feedGroup.items addObject:feedData];
                //[items addObject:feedGroup];
            }
        }
        else
        {
            [feedGroupUncategorized.items addObject:feedData];
        }
    }
    
     [self.tableView reloadData ];
 });
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






- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (items.count > 0)
    {
        return items.count;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
   
    if (items.count > 0)
    {
        currentSection = section;
        FeedGroup *group = [items objectAtIndex:section];
        
        sectionName = group.title;
        sectionName = [sectionName stringByAppendingFormat:@" (%d)", group.updatedCount];
    }
    
    return sectionName;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [tableData count];
    if (items.count > 0)
    {
        FeedGroup *group = [items objectAtIndex:section];
        
        //NSArray *keyArray =  [feedGroups allKeys];
        //FeedGroup *group = [feedGroups objectForKey:[ keyArray objectAtIndex:section]];
        
        return group.items.count;

    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    
    
    FPWebViewController *webView = [[FPWebViewController alloc] initWithNibName:@"FPWebViewController" bundle:nil];
    RSSItem *item = [items objectAtIndex:indexPath.row];
    webView.item = item;
    
    //UINavigationController *navController = [self navigationController];
    
    UINavigationController* navController = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate).navigationController;
    
    [navController pushViewController:webView animated:YES];
    
    // Checked the selected row
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *feedItemIdentifier = @"FeedItemTableCell";
    static NSString *noImageIdentifier = @"NoImageTableCell";
    
    FeedItemTableCell *cell;
    
    //if (cell == nil) {
        
        //NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeedItemTableCell" owner:self options:nil ];
        
        
        //cell = [nib objectAtIndex:0 ];
    //}
    
    if (items.count > 0)
    {
        
        //NSArray *keyArray =  [feedGroups allKeys];
        //FeedGroup *group = [feedGroups objectForKey:[ keyArray objectAtIndex:currentSection]];
        
        FeedGroup *group = [items objectAtIndex:[indexPath section]];
        
        
        
        FeedData *feedItem = [group.items objectAtIndex:[indexPath row]];
        
        //cell.titleLabel.text = feedItem.title;
        //cell.nameLabel.text = feedItem.source;
        
        //cell.updatedDateLabel.text = feedItem.updated;
        
       // NSString *identifier = [NSString stringWithFormat:@"Cell%d%d",[indexPath section], indexPath.row];
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!feedItem.image)
        {
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 26)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
    
    UILabel *parentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width  , 26)];
    
    parentLabel.backgroundColor = [[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0];
    
	//UIButton *label = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, 26)];
    
    NSString *sectionName = [self tableView:tableView titleForHeaderInSection:section];
    sectionName = [sectionName stringByAppendingString:@"  "];

    
    UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeSystem];
    infoButton.frame = CGRectMake(10, 0, headerView.frame.size.width, 26); // x,y,width,height
    
    [infoButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
   
    
    infoButton.enabled = YES;
    infoButton.tag = section;
    
    [infoButton setTitle:sectionName forState: UIControlStateNormal];
    [infoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

	infoButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    infoButton.titleLabel.textAlignment = NSTextAlignmentLeft;
	infoButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UILabel* chevronLabel = [IonIcons labelWithIcon:icon_ios7_arrow_forward size: 22 color: [UIColor whiteColor]];
    
    CGFloat titleWidth = [self widthOfString:sectionName withFont:infoButton.titleLabel.font];
    
    
    
    //CGSize* titleSize = [sectionName sizeWithFont:infoButton.titleLabel.font
    //                              forWidth:headerView.frame.size.width - 30
     //                                 lineBreakMode:NSLineBreakByTruncatingTail];
    
    [chevronLabel setFrame:CGRectMake(titleWidth, 0, 26, 26)];
    
    
    tableView.backgroundColor = [[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0];

    //label.textAlignment = NSTextAlignmentCenter;
    //CGPointMake(tableView.center.x, ctv.center.y);
    //[parentLabel addSubview:infoButton];
    
    [headerView addSubview:parentLabel];
	[headerView addSubview:infoButton];
    [headerView addSubview:chevronLabel];
    
	return headerView;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (IBAction)sectionButtonClicked: (id)sender{
    
    FeedListViewController * feedList = [[FeedListViewController alloc] init];
    UIButton* button = (UIButton*)sender;
    
    FeedGroup *group = [items objectAtIndex:button.tag];
    
    feedList.feedData = [group.items objectAtIndex:0];
    
    UINavigationController* navController = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate).navigationController;
    
    [navController pushViewController:feedList animated:YES];
    
    //UIAlertView *messageAlert = [[UIAlertView alloc]
      //                           initWithTitle:@"Row Selected" message:@"Button Clicked" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    //[messageAlert show];
    
    //   UIAlertView *messageAlert = [[UIAlertView alloc]
    //;                               initWithTitle:@"Row Selected" message:[tableData objectAtIndex:indexPath.row] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
}

                      /*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionName;
    
    if (items.count > 0)
    {
        currentSection = section;
        FeedGroup *group = [items objectAtIndex:section];
        sectionName = group.title;
        sectionName = [sectionName stringByAppendingString:@">"];
    }

    
    // Create a custom title view.
    UIView *ctv;
    UILabel *titleLabel;
    
    // Set the name.
    //{...} // Code not relevant
    
    ctv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 640, 80)];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 640, 80)];
    
    titleLabel.text = @"Header >";
    titleLabel.tintColor = [UIColor blackColor];
    
    ctv.backgroundColor = [[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0];
    //ctv.tintColor = [UIColor whiteColor];
    // Config the label.
    //{...} // Code not relevant
    
    // Center the items.
    ctv.center = CGPointMake(tableView.center.x, ctv.center.y);
    titleLabel.center = ctv.center;
    
    // Add the label to the container view.
    [ctv addSubview:titleLabel];
    
    // Return the custom title view.
    return ctv;
    
}

*/
                      
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
            FeedGroup *group = [items objectAtIndex:[indexPath section]];
            FeedData *feedItem = [group.items objectAtIndex:[indexPath row]];
            
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
            
            //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:instance.appRecord.indexPath];
            
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
   // [tableData removeObjectAtIndex:indexPath.row];
    
    // Request table view to reload
    [tableView reloadData];
}

@end
