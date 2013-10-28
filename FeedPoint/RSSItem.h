//
//  RSSItem.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/30/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSItem : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSURL* link;
@property (strong, nonatomic) NSAttributedString* cellMessage;
@property (strong, nonatomic) NSDate* pubDate;
@property (strong, nonatomic) NSString* pubDateFormatted;
@property (strong, nonatomic) NSString* author;

@end
