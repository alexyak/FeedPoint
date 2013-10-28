//
//  FeedPointAppDelegate.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPMainViewController.h"
#import "FeedService.h"
#import "Token.h"


@class PagingViewController;

@interface FeedPointAppDelegate : UIResponder <UIApplicationDelegate>{
    //UIWindow *window;
    PagingViewController *viewController;
}


@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FPMainViewController *mainViewController;

@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) PagingViewController *viewController;

@property (nonatomic, retain) FeedService *feedService;

-(void)saveToken: (Token*) token;

-(Token*) getToken;

@end
