//
//  CustomWebViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/11/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "CustomWebViewController.h"
#import "FeedData.h"
#import "FeedPointAppDelegate.h"
#import "FeedItem.h"
#import "WebViewCell.h"

@interface CustomWebViewController ()
{
    NSMutableArray *viewArray;
    FeedPointAppDelegate *app;
    NSString* continuation;
    int prevIndex;
	int currIndex;
	int nextIndex;

}

@end

@implementation CustomWebViewController

@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
                //[self.collectionView reloadData ];
                [self loadPageWithId:0 onPage: 0];
                [self loadPageWithId:1 onPage: 1];
                [self loadPageWithId:2 onPage: 2];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    viewArray = [NSMutableArray array];
    
    app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);

    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    
    //WebViewCell *webView1 = [[WebViewCell alloc] initWithFrame:frame];
    UIWebView *webView1 = [[UIWebView alloc] init];
    webView1.scalesPageToFit = YES;
    [viewArray addObject:webView1];
    [self.scrollView addSubview:webView1];
    [webView1 setFrame:frame];
    
    frame.origin.x = frame.size.width;
    UIWebView *webView2 = [[UIWebView alloc] init];
     //WebViewCell *webView2 = [[WebViewCell alloc] initWithFrame:frame];
    webView2.scalesPageToFit = YES;
    [viewArray addObject:webView2];
    [self.scrollView addSubview:webView2];
    [webView2 setFrame:frame];

    frame.origin.x = frame.size.width * 2;
    UIWebView *webView3= [[UIWebView alloc] init];
     //WebViewCell *webView3 = [[WebViewCell alloc] initWithFrame:frame];
    webView3.scalesPageToFit = YES;
    [viewArray addObject:webView3];
    [self.scrollView addSubview:webView3];
    [webView3 setFrame:frame];
    
    frame.origin.x = frame.size.width * 3;
    UIWebView *webView4 = [[UIWebView alloc] init];
    //WebViewCell *webView3 = [[WebViewCell alloc] initWithFrame:frame];
    webView4.scalesPageToFit = YES;
    [viewArray addObject:webView4];
    [self.scrollView addSubview:webView4];
    [webView4 setFrame:frame];
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 4, scrollView.frame.size.height);
    
	//[scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width,0,self.scrollView.frame.size.width,self.scrollView.frame.size.width) animated:NO];
    
    if (self.dataArray == nil)
    {
        self.dataArray = [[NSMutableArray alloc] init];
        [self loadFeedItems: self.feedData];
    }
    else
    {
        [self loadPageWithId:0 onPage: 0];
        [self loadPageWithId:1 onPage: 1];
        [self loadPageWithId:2 onPage: 2];

    }
    
}

- (void)loadPageWithId:(int)index onPage:(int)page {
	// load data for page
    /*
	switch (page) {
		case 0:
            
			pageOneDoc.text = [documentTitles objectAtIndex:index];
			break;
		case 1:
			pageTwoDoc.text = [documentTitles objectAtIndex:index];
			break;
		case 2:
			pageThreeDoc.text = [documentTitles objectAtIndex:index];
			break;
	}
     */
    FeedData* feedData = [self.dataArray objectAtIndex:index];
    //WebViewCell* webViewCell =[viewArray objectAtIndex:page];
    
     UIWebView* webViewCell =[viewArray objectAtIndex:page];
                          
    [self updateWebView:feedData.items[0] webView: webViewCell];
     
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    CGFloat pageWidth = scrollView.frame.size.width;
    
    
    
    NSNumber *offset = [NSNumber numberWithDouble: scrollView.contentOffset.x / pageWidth];
    
    NSDecimal decimal = offset.decimalValue;
    if (decimal._length != 1)
        return;
    
    int newPage = scrollView.contentOffset.x / pageWidth;
    
    //CGFloat offset = scrollView.contentOffset.x / pageWidth + 1;
    
    
    
    //currIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    double result = newPage % 2;
    
    NSLog(@"newPage:%d modResult:%f", newPage, result);
    
	if (newPage > currIndex && result == 0)
    {
        
        UIWebView* webViewCell =[viewArray objectAtIndex:0];
        CGRect frame;
        CGSize size = scrollView.contentSize;
        frame.origin.x = scrollView.contentSize.width;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        [self loadPageWithId:newPage + 1 onPage:0];
        [webViewCell setFrame:frame];
        
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + self.scrollView.frame.size.width , scrollView.frame.size.height);
        
    }
    
    currIndex = newPage;
    
}


//- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
	// All data for the documents are stored in an array (documentTitles).
	// We keep track of the index that we are scrolling to so that we
	// know what data to load for each page.
//	if(scrollView.contentOffset.x > scrollView.frame.size.width) {
		// We are moving forward. Load the current doc data on the first page.
//		[self loadPageWithId:currIndex onPage:0];
		// Add one to the currentIndex or reset to 0 if we have reached the end.
//		currIndex = (currIndex >= [self.dataArray count]-1) ? 0 : currIndex + 1;
//		[self loadPageWithId:currIndex onPage:1];
		// Load content on the last page. This is either from the next item in the array
		// or the first if we have reached the end.
//		nextIndex = (currIndex >= [self.dataArray count]-1) ? 0 : currIndex + 1;
//		[self loadPageWithId:nextIndex onPage:2];
//	}
//	if(scrollView.contentOffset.x < scrollView.frame.size.width) {
		// We are moving backward. Load the current doc data on the last page.
//		[self loadPageWithId:currIndex onPage:2];
		// Subtract one from the currentIndex or go to the end if we have reached the beginning.
//		currIndex = (currIndex == 0) ? [self.dataArray count]-1 : currIndex - 1;
//		[self loadPageWithId:currIndex onPage:1];
		// Load content on the first page. This is either from the prev item in the array
		// or the last if we have reached the beginning.
//		prevIndex = (currIndex == 0) ? [self.dataArray count]-1 : currIndex - 1;
//		[self loadPageWithId:prevIndex onPage:0];
//	}
	
	// Reset offset back to middle page
//	[scrollView scrollRectToVisible:CGRectMake(320,0,320,416) animated:NO];
//}


-(BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}


-(void)updateWebView: (FeedItem*) item webView: (UIWebView*) webView {
    
    if (item == nil)
    {
        [webView loadHTMLString:@"<html></html>" baseURL: nil];
        return;
    }
    
    FeedItem *currentItem = item;
    
    NSMutableString *html = [NSMutableString stringWithString:@"<html>" ];
    
    [html appendString:@"<head>"];
    [html appendString:@"<meta name='viewport' initial-scale=1.0; maximum-scale=1.0; user-scalable=no />"];
    [html appendString:@"<style>"];
    [html appendString:@"#Author{font-size: 28pt;word-wrap: break-word;clear: both;display: block;font-weight : normal; color: black;margin: 0 0 15px 0px;}"];
    [html appendString:@"#date{font-size: 28pt;line-height: 26px;color: Gray; margin: 0 0 30px 0px;}"];
    [html appendString:@"#title{font-size: 46pt; font-weight: bold; line-height: 1.1; word-wrap: break-word;clear:  both;display: color: black;margin: 0 0 10px 0px;}"];
    [html appendString:@"a {color:#006699; text-decoration: none} a:link{color:#006699;}"];
    [html appendString:@"</style>"];
    [html appendString:@"</head>"];
    [html appendString:@"<body style='padding: 20px; font-family: Helvetica Neue; line-height: 1.5; font-size: 3em !important; word-wrap: break-word;clear: both;display: block;'>"];
    
    if (currentItem.origin != nil)
        [html appendFormat: @"<div id='title'><a href='%@'>%@</a></div>", currentItem.origin.htmlUrl, currentItem.title];
    else
        [html appendFormat:@"<div id='title'>%@</div>", currentItem.title];
    
    if (currentItem.author != nil)
    {
        [html appendFormat: @"<div id='Author'>%@</div>", currentItem.author];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zz"];
    
    [html appendFormat: @"<div id='date'>%@</div>", [formatter stringFromDate:currentItem.published]];
    
    [html appendString:currentItem.content.content];
    [html appendString:@"</body>"];
    [html appendString:@"</html>"];
    
    //self.html = html;
    
    [webView loadHTMLString:html baseURL: nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
