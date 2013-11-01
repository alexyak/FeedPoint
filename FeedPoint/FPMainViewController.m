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
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zz"];
            feedData.updated = [formatter stringFromDate:item.published];
            
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
                [feedGroups setObject:feedGroup forKey:feedData.category];
                
            }
            else
            {
                FeedGroup *feedGroup = [feedGroups objectForKey:feedData.category];
                [self setFeedImage:feedData];
                [feedGroup.items addObject:feedData];
                //[items addObject:feedGroup];
            }
        }
        else
        {
            [feedGroupUncategorized.items addObject:feedData];
        }
    }
    
    //[items initWithArray:[feedGroups allValues]];
    
    //UITableView* tableView = (UITableView*)self.view;
    
    [self.tableView reloadData ];
     });
   /*
    NSMutableDictionary *folderTemp = [NSMutableDictionary dictionary];
    
    NSArray *keyArray =  [folders allKeys];
    int count = [keyArray count];
    for (int i=0; i < count; i++)
    {
        Folder *folder = [folders objectForKey:[ keyArray objectAtIndex:i]];
        FeedGroup *feedGroup =[[FeedGroup alloc] init];
        feedGroup.title = folder.name;
        feedGroup.items = [[NSMutableArray alloc] init];
        */
    
        /*
        for(UnreadItem *unreadItem in unreadItems)
        {
            if (folder.item!= nil)
            {
                if ([folder.item.id caseInsensitiveCompare: unreadItem.id])
                {
                    FeedData *feedData = [[FeedData alloc] init];
                    feedData.title = folder.item.title;
                    feedData.id  = folder.item.id;
                    feedData.updatedCount = unreadItem.count;
                    
                    if (feedData.updatedCount > 0){
                        [feedGroup.items addObject:feedData];
                    }
                }
            }
        }
         */
        
        
    
        //[feedGroup.items addObject:fe
    //}
}





- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Mark Unread";
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
    return 78;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    
    
    FPWebViewController *webView = [[FPWebViewController alloc] initWithNibName:@"FPWebViewController" bundle:nil];
    //FeedData *item = [items objectAtIndex:indexPath.row];
    //webView.item = item;
    
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
    static NSString *simpleTableIdentifier = @"FeedItemTableCell";
    
    //FeedItemTableCell *cell = (FeedItemTableCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    FeedItemTableCell *cell;
    
    //if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeedItemTableCell" owner:self options:nil ];
        
        
        cell = [nib objectAtIndex:0 ];
    //}
    
    if (items.count > 0)
    {
        
        //NSArray *keyArray =  [feedGroups allKeys];
        //FeedGroup *group = [feedGroups objectForKey:[ keyArray objectAtIndex:currentSection]];
        
        FeedGroup *group = [items objectAtIndex:[indexPath section]];
        
        
        
        FeedData *feedItem = [group.items objectAtIndex:[indexPath row]];
        
        cell.titleLabel.text = feedItem.title;
        cell.nameLabel.text = feedItem.source;
        
        cell.updatedDateLabel.text = feedItem.updated;
        
       // NSString *identifier = [NSString stringWithFormat:@"Cell%d%d",[indexPath section], indexPath.row];
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!feedItem.image)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:feedItem forIndexPath:indexPath];
            }
            
            cell.showImage = YES;
            
           
            // if a download is deferred or in progress, return a placeholder image
            //cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.imageView.image = feedItem.image;
            
            cell.showImage = NO;
            
            
            //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight]; //or left
            
            
            
            //cell.titleLabel.bounds = CGRectMake(102, 7, cell.bounds.size.width - 109, cell.bounds.size.height - 10);
            //cell.nameLabel.bounds = CGRectMake(102, 7, cell.bounds.size.width - 109, cell.bounds.size.height - 10);
            //cell.updatedDateLabel.bounds = CGRectMake(102, 7, cell.bounds.size.width - 109, cell.bounds.size.height - 10);
            
            //cell.imageView.bounds = CGRectMake(cell.imageView.bounds.origin.x, cell.imageView.bounds.origin.y, 89, 69);
        }

        
        /*
        if ([cachedImages valueForKey:identifier]) {
            cell.imageView.clipsToBounds = YES;
            [[cell imageView] setImage:[cachedImages valueForKey:identifier]];
        } else {
            dispatch_async(kBgQueue, ^{
                
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:feedItem.imageUrl]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (![cachedImages valueForKey:identifier])
                        {
                            NSLog(@"inside dispatch %@", identifier);
                            [cachedImages setValue:[UIImage imageWithData:imageData] forKey:identifier];
                            cell.imageView.clipsToBounds = YES;
                            [[cell imageView] setImage:[cachedImages valueForKey:identifier]];
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    });
                
                
                
                
            });
        }
       */
        
        //cell.imageImageView.image = feedItem.image;
        
        //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zz"];
        //cell.updatedDateLabel.text = feedItem.updated;
        
    }
   
    return cell;
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
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            // Display the newly loaded image
            //cell.imageView.image = instance.appRecord.image;
            
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
