//
//  SubscriptionItem.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/18/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Category.h"

@interface SubscriptionItem : NSObject


@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSMutableArray* categories;
@property (strong, nonatomic) NSString* updated;

@end
