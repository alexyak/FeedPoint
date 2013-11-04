//
//  FPWebViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "FPWebViewController.h"
#import "FeedData.h"
#import "IonIcons.h"

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
    
    
    UIBarButtonItem *menuButton = self.menuButton;
    menuButton.image = [IonIcons imageWithIcon:icon_navicon
                                 iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                  iconSize:30.0f
                                 imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *backButton = self.backButton;
    backButton.image = [IonIcons imageWithIcon:icon_ios7_arrow_left
                                     iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *forwardButton = self.forwardButton;
    forwardButton.image = [IonIcons imageWithIcon:icon_ios7_arrow_right
                                     iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *markButton = self.markButton;
    markButton.image = [IonIcons imageWithIcon:icon_ios7_checkmark_outline
                                        iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                         iconSize:30.0f
                                        imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *shareButton = self.shareButton;
    shareButton.image = [IonIcons imageWithIcon:icon_ios7_upload_outline
                                     iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];



    
    //self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor]    icon_ios7_upload_outline;
    //NSString *html = @"<html><body>HELLO FROM ME!!!</body></html>";
    //[self.webView loadHTMLString:html baseURL: nil];
    //NSURL *url = [NSURL URLWithString:@"http://www.bing.com"];
    FeedItem *currentItem = [self item];
    
    
    [self.navigationItem setTitle:currentItem.origin.title];

    
    NSMutableString *html = [NSMutableString stringWithString:@"<html>" ];
    
    [html appendString:@"<head>"];
    [html appendString:@"<meta name='viewport' initial-scale=1.0; maximum-scale=1.0; user-scalable=no />"];
    [html appendString:@"<style>"];
    [html appendString:@"#Author{font-size: 28pt;word-wrap: break-word;clear: both;display: block;font-weight : normal; color: black;margin: 0 0 15px 0px;}"];
    [html appendString:@"#date{font-size: 28pt;line-height: 26px;color: Gray; margin: 0 0 30px 0px;}"];
    [html appendString:@"#title{font-size: 46pt; font-weight: semibold; line-height: 1.1; word-wrap: break-word;clear:  both;display: color: black;margin: 0 0 10px 0px;}"];
    [html appendString:@"a {color:#006699; text-decoration: none} a:link{color:#006699;}"];
    [html appendString:@"</style>"];
    [html appendString:@"</head>"];
    [html appendString:@"<body style='padding: 20px; font-family: Helvetica Neue; line-height: 1.5; font-size: 38px; word-wrap: break-word;clear: both;display: block;'>"];
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
