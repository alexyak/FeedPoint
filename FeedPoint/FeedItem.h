//
//  FeedItem.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/25/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Content.h"
#import "Origin.h"
#import "Visual.h"

@interface FeedItem : NSObject
    
    //NSString *id;
    //NSString *title;
    //NSString *unread;
    //NSString *published;
    //NSString *updated;
    //NSString *crawled;
    //NSString *author;
    //NSString *engagement;

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* unread;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSDate* published;
@property (strong, nonatomic) NSDate* updated;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* engagement;
@property (strong, nonatomic) NSString* alternateUrl;
@property (strong, nonatomic) NSString* canonicalUrl;
@property (strong, nonatomic) Content* content;
@property (strong, nonatomic) Content* summary;
@property (strong, nonatomic) Origin* origin;
@property (strong, nonatomic) NSMutableArray* categories;
@property (strong, nonatomic) NSMutableArray* tags;
@property (strong, nonatomic) Visual* visual;
@property (nonatomic) BOOL isRead;

@end
