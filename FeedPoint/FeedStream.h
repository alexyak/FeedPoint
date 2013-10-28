//
//  FeedStream.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/20/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@interface FeedStream : NSObject

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* continuation;
@property (strong, nonatomic) NSMutableArray* items;
@property (strong, nonatomic) NSMutableArray* alternate;
@property (strong, nonatomic) NSString* updated;
@property (strong, nonatomic) Feed* self;

@end
