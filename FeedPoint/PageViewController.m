//
//  PageViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/13/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "PageViewController.h"
#import "FeedData.h"
#import "FeedItem.h"
#import "FPWebViewController.h"
#import "PagingScrollViewController.h"
#import "FAKIcon.h"
#import "FAKIonIcons.h"

@interface PageViewController ()
{
    FeedItem* item;
}

@end

@implementation PageViewController

//@synthesize mywebView;

@synthesize pageIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // [webView setFrame: CGRectMake(0,0,webView.bounds.size.width, webView.bounds.size.height - 60)];
        
    }
    
    
    
    return self;
}


 
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *absoluteUrl = url.absoluteString;
    
    if ([absoluteUrl hasPrefix:@"http://"] || [absoluteUrl hasPrefix:@"https://"])
    {
        FPWebViewController *webViewController = [[FPWebViewController alloc] initWithNibName:@"FPWebViewController" bundle:nil];
        webViewController.link = url;
        
        PagingScrollViewController* pagingController = (PagingScrollViewController*)self.pagingController;
        pagingController.scrollView.scrollEnabled = NO;

        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(doneClose)];
        [[pagingController navigationItem] setRightBarButtonItem:doneButton];

        
        [self presentViewController:webViewController
                           animated:TRUE completion:^{
                               
                              //pagingController.scrollView.scrollEnabled = YES;
                               
                           }];
        
        
        return FALSE;
    }
    
    return TRUE;
    
}

-(void)doneClose
{
    PagingScrollViewController* pagingController = (PagingScrollViewController*)self.pagingController;
    pagingController.scrollView.scrollEnabled = YES;
    
    //self.pageIndex++;
    
    // [mywebView loadHTMLString:@"<html></html>" baseURL: nil];
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        [pagingController showItem:pageIndex];
    } ];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)setIndex:(NSInteger)newPageIndex
{
	
    FeedData *pageData = [[self dataArray] objectAtIndex:newPageIndex];
    FeedItem *newItem = pageData.items[0];
    
    NSLog(@"setIndex:%d", newPageIndex);
    
    if (newItem.id != item.id)
    //{
        pageIndex = newPageIndex;
	
    
        if (pageIndex >= 0 && pageIndex < [[self dataArray] count])
        {
            FeedData *pageData = [[self dataArray] objectAtIndex:pageIndex];
            item = pageData.items[0];
           // self.titleLabel.text = item.title;
            
            [self updateWebView:FALSE];
        
            self.navigationItem.title = pageData.title;
        
        }
    //}
    
}

- (void)updateWebView:(BOOL)force
{
	if (item == nil)
    {
        [mywebView loadHTMLString:@"<html></html>" baseURL: nil];
        return;
    }
    
    //[mywebView performSelector:@selector(_setDrawInWebThread:) withObject:@YES];
    
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
        [html appendFormat: @"<div id='title'><a href='%@'>%@</a></div>", currentItem.alternateUrl, currentItem.title];
    else
        [html appendFormat:@"<div id='title'>%@</div>", currentItem.title];
    
    if (currentItem.author != nil)
    {
        [html appendFormat: @"<div id='Author'>%@</div>", currentItem.author];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, d MMM yyyy hh:mm a"];
    
    [html appendFormat: @"<div id='date'>%@</div>", [formatter stringFromDate:currentItem.published]];
    
    //if(force)
    //{
        [html appendString:currentItem.content.content];
    //}

    [html appendString:@"</body>"];
    [html appendString:@"</html>"];
    
    //self.html = html;
    
    [mywebView loadHTMLString:html baseURL: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //mywebView.delegate = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     //mywebView.delegate = self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
   // if (mywebView != nil)
        mywebView.delegate = self;
}

- (void)dealloc
{
    //id<UIWebViewDelegate> del = self.myWebView.delegate;
    
    //self.myWebView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
