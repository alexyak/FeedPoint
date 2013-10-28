//
//  FeedData.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/19/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedData : NSObject

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* source;
@property (strong, nonatomic) NSMutableArray* items;
@property (nonatomic, assign) int updatedCount;
@property (strong, nonatomic) NSString* updated;
@property (strong, nonatomic) NSString* imageUrl;
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL *imageFullSize;

@end
