//
//  UnreadItems.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/19/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnreadItems : NSObject

@property (nonatomic, assign)  int max;
@property (strong, nonatomic) NSMutableArray* unreadcounts;

@end
