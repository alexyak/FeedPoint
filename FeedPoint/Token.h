//
//  Token.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/25/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Token : NSObject

@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* accessToken;

@end
