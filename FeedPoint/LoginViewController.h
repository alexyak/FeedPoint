//
//  LoginViewController.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/17/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UIWebViewDelegate>{
    UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webViewInstance;

@end
