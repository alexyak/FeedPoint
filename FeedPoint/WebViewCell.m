//
//  WebViewCell.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/3/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "WebViewCell.h"

@interface WebViewCell ()

@end

@implementation WebViewCell

@synthesize webView = _webView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"WebViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
         
    }
    
    //[self.webView loadHTMLString:@"" baseURL: nil];
    
    return (WebViewCell*)self;
}

- (void)prepareForReuse
{
    self.item = nil;
}

-(void)layoutSubviews
{
    //self.webView = nil;
    //self.webView  = [[UIWebView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 546.0f)];
    //[self.webView loadHTMLString:@"<html></html>" baseURL: nil];
    //[self updateCell];
    
}

-(void) clear{
   [self.webView loadHTMLString:@"<html></html>" baseURL: nil];
    //self.webView = nil;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay]; // force drawRect:
}

-(void)updateCell {
    
    if (self.item == nil)
    {
        [self.webView loadHTMLString:@"<html></html>" baseURL: nil];
        return;
    }
    
    FeedItem *currentItem = self.item;
    
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
    
    self.html = html;
    
    [self.webView loadHTMLString:html baseURL: nil];
    
    
}
@end
