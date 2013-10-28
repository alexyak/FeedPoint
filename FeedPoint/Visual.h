//
//  Visual.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/20/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Visual : NSObject

@property (strong, nonatomic) NSString* edgeCacheUrl;
@property (nonatomic, assign)  int  height;
@property (nonatomic, assign)  int  width;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* contentType;

@end
