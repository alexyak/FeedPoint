//
//  URLParser.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/17/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject {
    NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end
