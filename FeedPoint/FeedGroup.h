//
//  FeedGroup.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/20/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedGroup : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSMutableArray* items;
@property (nonatomic, assign) int updatedCount;

@end
