//
//  FPWebViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "FPWebViewController.h"
#import "FeedData.h"

@interface FPWebViewController ()

@end

@implementation FPWebViewController

@synthesize webView = _webView;


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
    //NSString *html = @"<html><body>HELLO FROM ME!!!</body></html>";
    //[self.webView loadHTMLString:html baseURL: nil];
    //NSURL *url = [NSURL URLWithString:@"http://www.bing.com"];
    FeedData *currentItem = [self item];
    
    NSMutableString *html = [NSMutableString stringWithString:@"<html>" ];
    
    //html.AppendLine("<head>");
    //html.Append("<meta name=\"viewport\" initial-scale=1.0; maximum-scale=1.0; user-scalable=no\"/>");
    
    [html appendString:@"<head>"];
    [html appendString:@"<meta name='viewport' initial-scale=1.0; maximum-scale=1.0; user-scalable=no />"];
    [html appendString:@"<style>"];
    [html appendString:@"#Author{font-size: 18pt;word-wrap: break-word;clear: both;display: block;font-weight : normal; color: black;margin: 0 0 10px 0px;}"];
    [html appendString:@"#date{font-size: 16pt;line-height: 26px;color: Gray;}"];
    [html appendString:@"#title{font-size: 36pt; font-weight: bold; word-wrap: break-word;clear: both;display: color: black;margin: 0 0 10px 0px;}"];
    [html appendString:@"a {color:#006699; text-decoration: none} a:link{color:#006699;}"];
    [html appendString:@"</style>"];
    [html appendString:@"</head>"];
    [html appendString:@"<body style='padding: 20px; font-family: Helvetica Neue; font-size: 30px;'>"];
   // if (currentItem.link != nil)
   //     [html appendFormat: @"<div id='title'><a href='%@'>%@</a></div>", currentItem.link.path, currentItem.title];
   // else
   //     [html appendFormat:@"<div id='title'>%@</div>", currentItem.title];
    
  //  if (currentItem.author != nil)
  //  {
   //     [html appendFormat: @"<div id='Author'>%@</div>", currentItem.author];
   // }
   // [html appendFormat: @"<div id='date'>%@</div>", currentItem.pubDateFormatted];
    
    [html appendString:currentItem.description];
    [html appendString:@"</body>"];
    [html appendString:@"</html>"];
    
    
    //NSURLRequest *request = [NSURLRequest requestWithURL: [currentItem.link];
    //[self.webView loadRequest:request];
    [self.webView loadHTMLString:html baseURL: nil];
    
    // Do any additional setup after loading the view from its nib.
}
                             


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
