//
//  FeedService.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/25/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnreadItems.h"
#import "RSSItem.h"
#import "FeedStream.h"

typedef void (^RSSLoaderCompleteBlock)(NSString* title, NSArray* results);

typedef void (^SubscriptionsCompleteBlock)(NSArray* results);

typedef void (^UnreadItemsCompleteBlock)(UnreadItems* unreadItems);

typedef void (^FeedCompleteBlock)(FeedStream* results);


@interface FeedService : NSObject
{
    
}

-(void)fetchRssWithURL:(NSURL*)url complete:(RSSLoaderCompleteBlock)c;

-(void)getSubscriptions: (NSString*) uri complete:(SubscriptionsCompleteBlock)c;

-(void)getFeed: (NSString*) uri top: (int)t continuation: (NSString*) cont sort: (BOOL) old complete:(FeedCompleteBlock) callback;

-(void)getTodayFeed: (NSString*) userId top: (int)t continuation: (NSString*) cont sort: (BOOL) old complete:(FeedCompleteBlock) callback;

//- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier NS_AVAILABLE_IOS(6_0);

-(void)getUnreadCounts: (UnreadItemsCompleteBlock)callback;

-(NSMutableURLRequest*) getRequest: (NSString*) uri;


@property (nonatomic, retain) NSString *AuthToken;
@property (nonatomic, retain) NSString *UserId;

@property (nonatomic, retain) NSMutableArray *TodayItems;

@end
    