//
//  FPWebViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSItem.h"

@interface FPWebViewController : UIViewController <UIWebViewDelegate>{
    UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL* link;
@property (strong, nonatomic) RSSItem* item;

@end
