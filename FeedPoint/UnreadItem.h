//
//  UnreadItem.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/19/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnreadItem : NSObject

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* updated;
@property (nonatomic, assign)  int count;

@end
