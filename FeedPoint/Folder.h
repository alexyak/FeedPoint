//
//  Folder.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/19/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubscriptionItem.h"

@interface Folder : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSMutableArray* items;


@end
