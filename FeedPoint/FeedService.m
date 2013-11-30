//
//  FeedService.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/25/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "FeedService.h"
#import "RSSItem.h"
#import "RXMLElement.h"
#import "SubscriptionItem.h"
#import "Category.h"
#import "UnreadItems.h"
#import "UnreadItem.h"
#import "FeedStream.h"
#import "FeedItem.h"
#import "Visual.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@implementation FeedService

-(void)getTodayFeed: (NSString*) userId top: (int)t continuation: (NSString*) cont sort: (BOOL) old complete:(FeedCompleteBlock) callback
{

    NSString* category = @"/";
    category = [category stringByAppendingFormat: @"%@/category/global.all", userId];
    
    NSString * categoryEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                         NULL,
                                                                                         (CFStringRef)category,
                                                                                         NULL,
                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                         kCFStringEncodingUTF8 );
    
    

    NSString* param = [@"count=" stringByAppendingString: [NSString stringWithFormat:@"%i", t]];
    
    if (cont != nil)
    {
        param = [param stringByAppendingString:[@"&continuation=" stringByAppendingString:cont ]];
    }
    
    if (old)
    {
        param = [param stringByAppendingString:@"&ranked=old&unreadOnly=true"];
    }
    else
    {
        param = [param stringByAppendingString:@"&ranked=newest&unreadOnly=true"];
    }

    
    
    NSString* finalUrl = @"http://cloud.feedly.com/v3/streams/user";
    
    finalUrl = [finalUrl stringByAppendingString:categoryEncoded];
    
    finalUrl = [finalUrl stringByAppendingString:@"/contents?"];
    finalUrl = [finalUrl stringByAppendingString:param];
    
    NSMutableURLRequest *request = [self getRequest:finalUrl];
    FeedStream *feedStream = [[FeedStream alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data)
        {
            NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@", stringData);
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data //1
                                  options:kNilOptions
                                  error:&error];
            
            
            
            
            feedStream.id = [json objectForKey:@"id"];
            feedStream.title = [json objectForKey:@"title"];
            
            feedStream.alternate = [[NSMutableArray alloc]init];
            feedStream.items = [[NSMutableArray alloc]init];
            
            NSDictionary *alternates = [json objectForKey:@"alternate"];
            for(NSDictionary *item in alternates){
                Feed* alternate = [[Feed alloc] init];
                alternate.href = [item objectForKey:@"href"];
                alternate.linkType = [item objectForKey:@"type"];
                [feedStream.alternate addObject:alternate];
            }
            
            NSDictionary *items = [json objectForKey:@"items"];
            
            for(NSDictionary *item in items){
                FeedItem* feedItem = [[FeedItem alloc] init];
                feedItem.id = [item objectForKey:@"id"];
                feedItem.title = [item objectForKey:@"title"];
                feedItem.author = [item objectForKey:@"author"];
                feedItem.categories = [[NSMutableArray alloc] init];
                
                NSDictionary *origin = [item objectForKey:@"origin"];
                
                if (origin)
                {
                    Origin* originItem = [[Origin alloc]init];
                    originItem.title = [origin objectForKey:@"title"];
                    originItem.htmlUrl = [origin objectForKey:@"htmlUrl"];
                    originItem.streamId = [origin objectForKey:@"streamId"];
                    feedItem.origin = originItem;
                }
                
                NSDictionary *categories = [item objectForKey:@"categories"];
                
                for(NSDictionary *category in categories)
                {
                    FeedCategory* feedCategory = [[FeedCategory alloc] init];
                    
                    feedCategory.id = [category objectForKey:@"id"];
                    feedCategory.label = [category objectForKey:@"label"];
                    [feedItem.categories addObject:feedCategory];
                    
                }
                
                if ([item objectForKey:@"tags"] != nil)
                {
                    NSDictionary *tags = [item objectForKey:@"tags"];
                    
                    feedItem.tags = [[NSMutableArray alloc] init];
                    
                    for(NSDictionary *tag in tags)
                    {
                        FeedCategory* feedTag = [[FeedCategory alloc] init];
                        
                        feedTag.id = [tag objectForKey:@"id"];
                        feedTag.label = [tag objectForKey:@"label"];
                        [feedItem.tags addObject:feedTag];
                        
                    }
                }
                
                for(NSDictionary *category in categories)
                {
                    FeedCategory* feedCategory = [[FeedCategory alloc] init];
                    
                    feedCategory.id = [category objectForKey:@"id"];
                    feedCategory.label = [category objectForKey:@"label"];
                    [feedItem.categories addObject:feedCategory];
                    
                }
                
                
                if ([item objectForKey:@"content"] != nil)
                {
                    NSDictionary *itemContent = [item objectForKey:@"content"];
                    
                    Content* content = [[Content alloc] init];
                    content.content = [itemContent objectForKey:@"content"];
                    feedItem.content = content;
                }
                else
                {
                    NSDictionary *itemContent = [item objectForKey:@"summary"];
                    
                    Content* content = [[Content alloc] init];
                    content.content = [itemContent objectForKey:@"content"];
                    feedItem.content = content;
                }
                
                if ([item objectForKey:@"visual"] != nil)
                {
                    NSDictionary *visual = [item objectForKey:@"visual"];
                    Visual* visualItem = [[Visual alloc]init];
                    visualItem.url = [visual objectForKey:@"url"];
                    visualItem.width = [[visual objectForKey:@"width"] intValue];
                    visualItem.height = [[visual objectForKey:@"height"] intValue];
                    visualItem.contentType = [visual objectForKey:@"contentType"];
                    feedItem.visual = visualItem;
                }
                
                //NSTimeInterval* iterval = [NSTimeInterval in
                double publishedInt = [[item objectForKey:@"published"] doubleValue] / 1000;
                feedItem.published = [NSDate dateWithTimeIntervalSince1970:publishedInt];
                
                
                [feedStream.items addObject:feedItem];
            }
            
            
            
        }
        
        callback(feedStream);
    }];
    
    /*
    NSMutableURLRequest *request = [self getRequest:finalUrl];
    NSURLResponse *response = nil;
    NSError *outError = [[NSError alloc] init];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
    
    FeedStream *feedStream = [[FeedStream alloc] init];
    
    if (data)
    {
        NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", stringData);
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data //1
                              options:kNilOptions
                              error:&error];
        
        
        
        
        feedStream.id = [json objectForKey:@"id"];
        feedStream.title = [json objectForKey:@"title"];
        
        feedStream.alternate = [[NSMutableArray alloc]init];
        feedStream.items = [[NSMutableArray alloc]init];
        
        NSDictionary *alternates = [json objectForKey:@"alternate"];
        for(NSDictionary *item in alternates){
            Feed* alternate = [[Feed alloc] init];
            alternate.href = [item objectForKey:@"href"];
            alternate.linkType = [item objectForKey:@"type"];
            [feedStream.alternate addObject:alternate];
        }
        
        NSDictionary *items = [json objectForKey:@"items"];
        
        for(NSDictionary *item in items){
            FeedItem* feedItem = [[FeedItem alloc] init];
            feedItem.id = [item objectForKey:@"id"];
            feedItem.title = [item objectForKey:@"title"];
            feedItem.author = [item objectForKey:@"author"];
            feedItem.categories = [[NSMutableArray alloc] init];
            
            NSDictionary *origin = [item objectForKey:@"origin"];
            
            if (origin)
            {
                Origin* originItem = [[Origin alloc]init];
                originItem.title = [origin objectForKey:@"title"];
                originItem.htmlUrl = [origin objectForKey:@"htmlUrl"];
                originItem.streamId = [origin objectForKey:@"streamId"];
                               feedItem.origin = originItem;
            }
            
            NSDictionary *categories = [item objectForKey:@"categories"];
            
            for(NSDictionary *category in categories)
            {
                FeedCategory* feedCategory = [[FeedCategory alloc] init];
                
                feedCategory.id = [category objectForKey:@"id"];
                feedCategory.label = [category objectForKey:@"label"];
                [feedItem.categories addObject:feedCategory];
                
            }
            
            if ([item objectForKey:@"tags"] != nil)
            {
                NSDictionary *tags = [item objectForKey:@"tags"];
                
                feedItem.tags = [[NSMutableArray alloc] init];
                
                for(NSDictionary *tag in tags)
                {
                    FeedCategory* feedTag = [[FeedCategory alloc] init];
                    
                    feedTag.id = [tag objectForKey:@"id"];
                    feedTag.label = [tag objectForKey:@"label"];
                    [feedItem.tags addObject:feedTag];
                    
                }
            }
            
            for(NSDictionary *category in categories)
            {
                FeedCategory* feedCategory = [[FeedCategory alloc] init];
                
                feedCategory.id = [category objectForKey:@"id"];
                feedCategory.label = [category objectForKey:@"label"];
                [feedItem.categories addObject:feedCategory];
                
            }
            
            
            if ([item objectForKey:@"content"] != nil)
            {
                NSDictionary *itemContent = [item objectForKey:@"content"];
                
                Content* content = [[Content alloc] init];
                content.content = [itemContent objectForKey:@"content"];
                feedItem.content = content;
            }
            else
            {
                NSDictionary *itemContent = [item objectForKey:@"summary"];
                
                Content* content = [[Content alloc] init];
                content.content = [itemContent objectForKey:@"content"];
                feedItem.content = content;
            }
            
            if ([item objectForKey:@"visual"] != nil)
            {
                NSDictionary *visual = [item objectForKey:@"visual"];
                Visual* visualItem = [[Visual alloc]init];
                visualItem.url = [visual objectForKey:@"url"];
                visualItem.width = [[visual objectForKey:@"width"] intValue];
                visualItem.height = [[visual objectForKey:@"height"] intValue];
                visualItem.contentType = [visual objectForKey:@"contentType"];
                feedItem.visual = visualItem;
            }
            
            //NSTimeInterval* iterval = [NSTimeInterval in
            double publishedInt = [[item objectForKey:@"published"] doubleValue] / 1000;
            feedItem.published = [NSDate dateWithTimeIntervalSince1970:publishedInt];
            
            
            [feedStream.items addObject:feedItem];
        }
        
        
        
    }
    
    callback(feedStream);

    */
}


-(void)getFeedAsync: (NSString*) url top: (NSInteger)t continuation: (NSString*) cont sort: (BOOL) old complete:(FeedCompleteBlock) callback
{
   
    
    NSString * urlEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)url,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 );
    
    NSString* param = [@"count=" stringByAppendingString: [NSString stringWithFormat:@"%i", t]];
    
    if (cont != nil)
    {
        param = [param stringByAppendingString:[@"&continuation=" stringByAppendingString:cont ]];
    }
    
    if (old)
    {
        param = [param stringByAppendingString:@"&ranked=old&unreadOnly=true"];
    }
    else
    {
        param = [param stringByAppendingString:@"&ranked=newest&unreadOnly=true"];
    }
    
    NSString* finalUrl = @"http://cloud.feedly.com/v3/streams/";
    
    finalUrl = [finalUrl stringByAppendingString:urlEncoded];
    
    finalUrl = [finalUrl stringByAppendingString:@"/contents?"];
    finalUrl = [finalUrl stringByAppendingString:param];
    
    NSMutableURLRequest *request = [self getRequest:finalUrl];
    FeedStream *feedStream = [[FeedStream alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data)
        {
            NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@", stringData);
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data //1
                                  options:kNilOptions
                                  error:&error];
            
            
            
            
            feedStream.id = [json objectForKey:@"id"];
            feedStream.title = [json objectForKey:@"title"];
            
            feedStream.continuation = [json objectForKey:@"continuation"];
            
            feedStream.alternate = [[NSMutableArray alloc]init];
            feedStream.items = [[NSMutableArray alloc]init];
            
            NSDictionary *alternates = [json objectForKey:@"alternate"];
            for(NSDictionary *item in alternates){
                Feed* alternate = [[Feed alloc] init];
                alternate.href = [item objectForKey:@"href"];
                alternate.linkType = [item objectForKey:@"type"];
                [feedStream.alternate addObject:alternate];
            }
            
            NSDictionary *items = [json objectForKey:@"items"];
            
            for(NSDictionary *item in items){
                FeedItem* feedItem = [[FeedItem alloc] init];
                feedItem.id = [item objectForKey:@"id"];
                feedItem.title = [item objectForKey:@"title"];
                feedItem.author = [item objectForKey:@"author"];
                feedItem.categories = [[NSMutableArray alloc] init];
                
                NSDictionary *origin = [item objectForKey:@"origin"];
                
                if (origin)
                {
                    Origin* originItem = [[Origin alloc]init];
                    originItem.title = [origin objectForKey:@"title"];
                    originItem.htmlUrl = [origin objectForKey:@"htmlUrl"];
                    originItem.streamId = [origin objectForKey:@"streamId"];
                    
                    feedItem.origin = originItem;
                }
                
                NSArray * alternate = [item objectForKey:@"alternate"];
                if (alternate)
                {
                    NSDictionary* first = [alternate objectAtIndex:0];
                    feedItem.alternateUrl = [first objectForKey:@"href"];
                }
                
                NSArray * canonical = [item objectForKey:@"canonical"];
                if (canonical)
                {
                    NSDictionary* first = [canonical objectAtIndex:0];
                    feedItem.canonicalUrl = [first objectForKey:@"href"];
                    
                }
                
                NSDictionary *categories = [item objectForKey:@"categories"];
                
                for(NSDictionary *category in categories)
                {
                    FeedCategory* feedCategory = [[FeedCategory alloc] init];
                    
                    feedCategory.id = [category objectForKey:@"id"];
                    feedCategory.label = [category objectForKey:@"label"];
                    [feedItem.categories addObject:feedCategory];
                    
                }
                
                if ([item objectForKey:@"tags"] != nil)
                {
                    NSDictionary *tags = [item objectForKey:@"tags"];
                    
                    feedItem.tags = [[NSMutableArray alloc] init];
                    
                    for(NSDictionary *tag in tags)
                    {
                        FeedCategory* feedTag = [[FeedCategory alloc] init];
                        
                        feedTag.id = [tag objectForKey:@"id"];
                        feedTag.label = [tag objectForKey:@"label"];
                        [feedItem.tags addObject:feedTag];
                        
                    }
                }
                
                for(NSDictionary *category in categories)
                {
                    FeedCategory* feedCategory = [[FeedCategory alloc] init];
                    
                    feedCategory.id = [category objectForKey:@"id"];
                    feedCategory.label = [category objectForKey:@"label"];
                    [feedItem.categories addObject:feedCategory];
                    
                }
                
                
                if ([item objectForKey:@"content"] != nil)
                {
                    NSDictionary *itemContent = [item objectForKey:@"content"];
                    
                    Content* content = [[Content alloc] init];
                    content.content = [itemContent objectForKey:@"content"];
                    feedItem.content = content;
                }
                else
                {
                    NSDictionary *itemContent = [item objectForKey:@"summary"];
                    
                    Content* content = [[Content alloc] init];
                    content.content = [itemContent objectForKey:@"content"];
                    feedItem.content = content;
                }
                
                if ([item objectForKey:@"visual"] != nil)
                {
                    NSDictionary *visual = [item objectForKey:@"visual"];
                    Visual* visualItem = [[Visual alloc]init];
                    visualItem.url = [visual objectForKey:@"url"];
                    visualItem.width = [[visual objectForKey:@"width"] intValue];
                    visualItem.height = [[visual objectForKey:@"height"] intValue];
                    visualItem.contentType = [visual objectForKey:@"contentType"];
                    feedItem.visual = visualItem;
                }
                
                //NSTimeInterval* iterval = [NSTimeInterval in
                double publishedInt = [[item objectForKey:@"published"] doubleValue] / 1000;
                feedItem.published = [NSDate dateWithTimeIntervalSince1970:publishedInt];
                
                
                [feedStream.items addObject:feedItem];
            }
            
            
            
        }
        
        callback(feedStream);
    }];
    /*
    NSURLResponse *response = nil;
    NSError *outError = [[NSError alloc] init];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
    
    FeedStream *feedStream = [[FeedStream alloc] init];
    
    if (data)
    {
        NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", stringData);
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data //1
                              options:kNilOptions
                              error:&error];
        
        
        

        feedStream.id = [json objectForKey:@"id"];
        feedStream.title = [json objectForKey:@"title"];
        
        feedStream.continuation = [json objectForKey:@"continuation"];
        
        feedStream.alternate = [[NSMutableArray alloc]init];
        feedStream.items = [[NSMutableArray alloc]init];
        
        NSDictionary *alternates = [json objectForKey:@"alternate"];
        for(NSDictionary *item in alternates){
            Feed* alternate = [[Feed alloc] init];
            alternate.href = [item objectForKey:@"href"];
            alternate.linkType = [item objectForKey:@"type"];
            [feedStream.alternate addObject:alternate];
        }
        
        NSDictionary *items = [json objectForKey:@"items"];
        
        for(NSDictionary *item in items){
            FeedItem* feedItem = [[FeedItem alloc] init];
            feedItem.id = [item objectForKey:@"id"];
            feedItem.title = [item objectForKey:@"title"];
            feedItem.author = [item objectForKey:@"author"];
            feedItem.categories = [[NSMutableArray alloc] init];
            
            NSDictionary *origin = [item objectForKey:@"origin"];
            
            if (origin)
            {
                Origin* originItem = [[Origin alloc]init];
                originItem.title = [origin objectForKey:@"title"];
                originItem.htmlUrl = [origin objectForKey:@"htmlUrl"];
                originItem.streamId = [origin objectForKey:@"streamId"];

                feedItem.origin = originItem;
            }
            
            NSArray * alternate = [item objectForKey:@"alternate"];
            if (alternate)
            {
                NSDictionary* first = [alternate objectAtIndex:0];
                feedItem.alternateUrl = [first objectForKey:@"href"];
            }
            
            NSArray * canonical = [item objectForKey:@"canonical"];
            if (canonical)
            {
                NSDictionary* first = [canonical objectAtIndex:0];
                feedItem.canonicalUrl = [first objectForKey:@"href"];
                
            }
            
            NSDictionary *categories = [item objectForKey:@"categories"];
            
            for(NSDictionary *category in categories)
            {
                FeedCategory* feedCategory = [[FeedCategory alloc] init];

                feedCategory.id = [category objectForKey:@"id"];
                feedCategory.label = [category objectForKey:@"label"];
                [feedItem.categories addObject:feedCategory];
                
            }
            
            if ([item objectForKey:@"tags"] != nil)
            {
                 NSDictionary *tags = [item objectForKey:@"tags"];
                
                feedItem.tags = [[NSMutableArray alloc] init];
                
                for(NSDictionary *tag in tags)
                {
                    FeedCategory* feedTag = [[FeedCategory alloc] init];
                    
                    feedTag.id = [tag objectForKey:@"id"];
                    feedTag.label = [tag objectForKey:@"label"];
                    [feedItem.tags addObject:feedTag];
                    
                }
            }
            
            for(NSDictionary *category in categories)
            {
                FeedCategory* feedCategory = [[FeedCategory alloc] init];
                
                feedCategory.id = [category objectForKey:@"id"];
                feedCategory.label = [category objectForKey:@"label"];
                [feedItem.categories addObject:feedCategory];
                
            }
            
            
            if ([item objectForKey:@"content"] != nil)
            {
                NSDictionary *itemContent = [item objectForKey:@"content"];
                
                Content* content = [[Content alloc] init];
                content.content = [itemContent objectForKey:@"content"];
                feedItem.content = content;
            }
            else
            {
                NSDictionary *itemContent = [item objectForKey:@"summary"];
                
                Content* content = [[Content alloc] init];
                content.content = [itemContent objectForKey:@"content"];
                feedItem.content = content;
            }
            
            if ([item objectForKey:@"visual"] != nil)
            {
                NSDictionary *visual = [item objectForKey:@"visual"];
                Visual* visualItem = [[Visual alloc]init];
                visualItem.url = [visual objectForKey:@"url"];
                visualItem.width = [[visual objectForKey:@"width"] intValue];
                visualItem.height = [[visual objectForKey:@"height"] intValue];
                visualItem.contentType = [visual objectForKey:@"contentType"];
                feedItem.visual = visualItem;
            }
            
            //NSTimeInterval* iterval = [NSTimeInterval in
            double publishedInt = [[item objectForKey:@"published"] doubleValue] / 1000;
            feedItem.published = [NSDate dateWithTimeIntervalSince1970:publishedInt];
            
            
            [feedStream.items addObject:feedItem];
        }
        
            
        
    }
    
    callback(feedStream);
    */
    
}

-(void)getFeed: (NSString*) url top: (NSInteger)t continuation: (NSString*) cont sort: (BOOL) old complete:(FeedCompleteBlock) callback
{
    
    
    NSString * urlEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                         NULL,
                                                                                         (CFStringRef)url,
                                                                                         NULL,
                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                         kCFStringEncodingUTF8 );
    
    NSString* param = [@"count=" stringByAppendingString: [NSString stringWithFormat:@"%i", t]];
    
    if (cont != nil)
    {
        param = [param stringByAppendingString:[@"&continuation=" stringByAppendingString:cont ]];
    }
    
    if (old)
    {
        param = [param stringByAppendingString:@"&ranked=old&unreadOnly=true"];
    }
    else
    {
        param = [param stringByAppendingString:@"&ranked=newest&unreadOnly=true"];
    }
    
    NSString* finalUrl = @"http://cloud.feedly.com/v3/streams/";
    
    finalUrl = [finalUrl stringByAppendingString:urlEncoded];
    
    finalUrl = [finalUrl stringByAppendingString:@"/contents?"];
    finalUrl = [finalUrl stringByAppendingString:param];
    
    NSMutableURLRequest *request = [self getRequest:finalUrl];
    //FeedStream *feedStream = [[FeedStream alloc] init];
    
    /*
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data)
        {
            NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@", stringData);
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data //1
                                  options:kNilOptions
                                  error:&error];
            
            
            
            
            feedStream.id = [json objectForKey:@"id"];
            feedStream.title = [json objectForKey:@"title"];
            
            feedStream.continuation = [json objectForKey:@"continuation"];
            
            feedStream.alternate = [[NSMutableArray alloc]init];
            feedStream.items = [[NSMutableArray alloc]init];
            
            NSDictionary *alternates = [json objectForKey:@"alternate"];
            for(NSDictionary *item in alternates){
                Feed* alternate = [[Feed alloc] init];
                alternate.href = [item objectForKey:@"href"];
                alternate.linkType = [item objectForKey:@"type"];
                [feedStream.alternate addObject:alternate];
            }
            
            NSDictionary *items = [json objectForKey:@"items"];
            
            for(NSDictionary *item in items){
                FeedItem* feedItem = [[FeedItem alloc] init];
                feedItem.id = [item objectForKey:@"id"];
                feedItem.title = [item objectForKey:@"title"];
                feedItem.author = [item objectForKey:@"author"];
                feedItem.categories = [[NSMutableArray alloc] init];
                
                NSDictionary *origin = [item objectForKey:@"origin"];
                
                if (origin)
                {
                    Origin* originItem = [[Origin alloc]init];
                    originItem.title = [origin objectForKey:@"title"];
                    originItem.htmlUrl = [origin objectForKey:@"htmlUrl"];
                    originItem.streamId = [origin objectForKey:@"streamId"];
                    
                    feedItem.origin = originItem;
                }
                
                NSArray * alternate = [item objectForKey:@"alternate"];
                if (alternate)
                {
                    NSDictionary* first = [alternate objectAtIndex:0];
                    feedItem.alternateUrl = [first objectForKey:@"href"];
                }
                
                NSArray * canonical = [item objectForKey:@"canonical"];
                if (canonical)
                {
                    NSDictionary* first = [canonical objectAtIndex:0];
                    feedItem.canonicalUrl = [first objectForKey:@"href"];
                    
                }
                
                NSDictionary *categories = [item objectForKey:@"categories"];
                
                for(NSDictionary *category in categories)
                {
                    FeedCategory* feedCategory = [[FeedCategory alloc] init];
                    
                    feedCategory.id = [category objectForKey:@"id"];
                    feedCategory.label = [category objectForKey:@"label"];
                    [feedItem.categories addObject:feedCategory];
                    
                }
                
                if ([item objectForKey:@"tags"] != nil)
                {
                    NSDictionary *tags = [item objectForKey:@"tags"];
                    
                    feedItem.tags = [[NSMutableArray alloc] init];
                    
                    for(NSDictionary *tag in tags)
                    {
                        FeedCategory* feedTag = [[FeedCategory alloc] init];
                        
                        feedTag.id = [tag objectForKey:@"id"];
                        feedTag.label = [tag objectForKey:@"label"];
                        [feedItem.tags addObject:feedTag];
                        
                    }
                }
                
                for(NSDictionary *category in categories)
                {
                    FeedCategory* feedCategory = [[FeedCategory alloc] init];
                    
                    feedCategory.id = [category objectForKey:@"id"];
                    feedCategory.label = [category objectForKey:@"label"];
                    [feedItem.categories addObject:feedCategory];
                    
                }
                
                
                if ([item objectForKey:@"content"] != nil)
                {
                    NSDictionary *itemContent = [item objectForKey:@"content"];
                    
                    Content* content = [[Content alloc] init];
                    content.content = [itemContent objectForKey:@"content"];
                    feedItem.content = content;
                }
                else
                {
                    NSDictionary *itemContent = [item objectForKey:@"summary"];
                    
                    Content* content = [[Content alloc] init];
                    content.content = [itemContent objectForKey:@"content"];
                    feedItem.content = content;
                }
                
                if ([item objectForKey:@"visual"] != nil)
                {
                    NSDictionary *visual = [item objectForKey:@"visual"];
                    Visual* visualItem = [[Visual alloc]init];
                    visualItem.url = [visual objectForKey:@"url"];
                    visualItem.width = [[visual objectForKey:@"width"] intValue];
                    visualItem.height = [[visual objectForKey:@"height"] intValue];
                    visualItem.contentType = [visual objectForKey:@"contentType"];
                    feedItem.visual = visualItem;
                }
                
                //NSTimeInterval* iterval = [NSTimeInterval in
                double publishedInt = [[item objectForKey:@"published"] doubleValue] / 1000;
                feedItem.published = [NSDate dateWithTimeIntervalSince1970:publishedInt];
                
                
                [feedStream.items addObject:feedItem];
            }
            
            
            
        }
        
        callback(feedStream);
    }];
     */
    
     NSURLResponse *response = nil;
     NSError *outError = [[NSError alloc] init];
     
     NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
     
     FeedStream *feedStream = [[FeedStream alloc] init];
     
     if (data)
     {
     NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     
     NSLog(@"%@", stringData);
     
     NSError* error;
     NSDictionary* json = [NSJSONSerialization
     JSONObjectWithData:data //1
     options:kNilOptions
     error:&error];
     
     
     
     
     feedStream.id = [json objectForKey:@"id"];
     feedStream.title = [json objectForKey:@"title"];
     
     feedStream.continuation = [json objectForKey:@"continuation"];
     
     feedStream.alternate = [[NSMutableArray alloc]init];
     feedStream.items = [[NSMutableArray alloc]init];
     
     NSDictionary *alternates = [json objectForKey:@"alternate"];
     for(NSDictionary *item in alternates){
     Feed* alternate = [[Feed alloc] init];
     alternate.href = [item objectForKey:@"href"];
     alternate.linkType = [item objectForKey:@"type"];
     [feedStream.alternate addObject:alternate];
     }
     
     NSDictionary *items = [json objectForKey:@"items"];
     
     for(NSDictionary *item in items){
     FeedItem* feedItem = [[FeedItem alloc] init];
     feedItem.id = [item objectForKey:@"id"];
     feedItem.title = [item objectForKey:@"title"];
     feedItem.author = [item objectForKey:@"author"];
     feedItem.categories = [[NSMutableArray alloc] init];
     
     NSDictionary *origin = [item objectForKey:@"origin"];
     
     if (origin)
     {
     Origin* originItem = [[Origin alloc]init];
     originItem.title = [origin objectForKey:@"title"];
     originItem.htmlUrl = [origin objectForKey:@"htmlUrl"];
     originItem.streamId = [origin objectForKey:@"streamId"];
     
     feedItem.origin = originItem;
     }
     
     NSArray * alternate = [item objectForKey:@"alternate"];
     if (alternate)
     {
     NSDictionary* first = [alternate objectAtIndex:0];
     feedItem.alternateUrl = [first objectForKey:@"href"];
     }
     
     NSArray * canonical = [item objectForKey:@"canonical"];
     if (canonical)
     {
     NSDictionary* first = [canonical objectAtIndex:0];
     feedItem.canonicalUrl = [first objectForKey:@"href"];
     
     }
     
     NSDictionary *categories = [item objectForKey:@"categories"];
     
     for(NSDictionary *category in categories)
     {
     FeedCategory* feedCategory = [[FeedCategory alloc] init];
     
     feedCategory.id = [category objectForKey:@"id"];
     feedCategory.label = [category objectForKey:@"label"];
     [feedItem.categories addObject:feedCategory];
     
     }
     
     if ([item objectForKey:@"tags"] != nil)
     {
     NSDictionary *tags = [item objectForKey:@"tags"];
     
     feedItem.tags = [[NSMutableArray alloc] init];
     
     for(NSDictionary *tag in tags)
     {
     FeedCategory* feedTag = [[FeedCategory alloc] init];
     
     feedTag.id = [tag objectForKey:@"id"];
     feedTag.label = [tag objectForKey:@"label"];
     [feedItem.tags addObject:feedTag];
     
     }
     }
     
     for(NSDictionary *category in categories)
     {
     FeedCategory* feedCategory = [[FeedCategory alloc] init];
     
     feedCategory.id = [category objectForKey:@"id"];
     feedCategory.label = [category objectForKey:@"label"];
     [feedItem.categories addObject:feedCategory];
     
     }
     
     
     if ([item objectForKey:@"content"] != nil)
     {
     NSDictionary *itemContent = [item objectForKey:@"content"];
     
     Content* content = [[Content alloc] init];
     content.content = [itemContent objectForKey:@"content"];
     feedItem.content = content;
     }
     else
     {
     NSDictionary *itemContent = [item objectForKey:@"summary"];
     
     Content* content = [[Content alloc] init];
     content.content = [itemContent objectForKey:@"content"];
     feedItem.content = content;
     }
     
     if ([item objectForKey:@"visual"] != nil)
     {
     NSDictionary *visual = [item objectForKey:@"visual"];
     Visual* visualItem = [[Visual alloc]init];
     visualItem.url = [visual objectForKey:@"url"];
     visualItem.width = [[visual objectForKey:@"width"] intValue];
     visualItem.height = [[visual objectForKey:@"height"] intValue];
     visualItem.contentType = [visual objectForKey:@"contentType"];
     feedItem.visual = visualItem;
     }
     
     //NSTimeInterval* iterval = [NSTimeInterval in
     double publishedInt = [[item objectForKey:@"published"] doubleValue] / 1000;
     feedItem.published = [NSDate dateWithTimeIntervalSince1970:publishedInt];
     
     
     [feedStream.items addObject:feedItem];
     }
     
     
     
     }
     
     callback(feedStream);
    
    
}


-(void)getUnreadCounts: (UnreadItemsCompleteBlock) callback{
    
    NSMutableURLRequest *request = [self getRequest:@"http://cloud.feedly.com/v3/markers/counts"];
    
    NSURLResponse *response = nil;
    NSError *outError = [[NSError alloc] init];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
    UnreadItems *result = [[UnreadItems alloc] init];
    
    
    if (data){
        dispatch_async(kBgQueue, ^{
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data //1
                                  options:kNilOptions
                                  error:&error];
            
           // NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //NSLog(stringData);
            
            result.max = [[json objectForKey:@"max"] intValue];
            
            result.unreadcounts = [NSMutableArray array];
            
            NSDictionary *unreadCounts = [json objectForKey:@"unreadcounts"];
            
            for(NSDictionary *item in unreadCounts){
                UnreadItem *unreadItem = [[UnreadItem alloc] init];
                unreadItem.id = [item objectForKey:@"id"];
                unreadItem.updated = [item objectForKey:@"updated"];
                NSString *countString = [item objectForKey:@"count"];
                unreadItem.count = [countString intValue];
                
                [result.unreadcounts addObject:unreadItem];
            }
            
            callback(result);
        });
    }
    
}


-(void)getSubscriptions: (NSString*) uri complete:(SubscriptionsCompleteBlock)c{
    
    NSURL *url  = [NSURL URLWithString:@"http://cloud.feedly.com/v3/subscriptions"];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    NSString* oAuth = @"OAuth ";
    
    [request setValue: [oAuth stringByAppendingString: self.AuthToken] forHTTPHeaderField:@"Authorization"];
     
    NSURLResponse *response = nil;
    NSError *outError = [[NSError alloc] init];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
    NSMutableArray *result = [NSMutableArray array];
    
    
    if (data){
            dispatch_async(kBgQueue, ^{
                
                NSError* error;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:data //1
                                      options:kNilOptions
                                      error:&error];
                
                NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                //NSLog(stringData);


                for(NSDictionary *item in json){
                    
                    SubscriptionItem *subItem = [[SubscriptionItem alloc] init];
                    
                    subItem.id = [item objectForKey:@"id"];
                    subItem.title = [item objectForKey:@"title"];
                    subItem.updated = [item objectForKey:@"updated"];
                    subItem.categories = [NSMutableArray array];
                    NSDictionary *categories = [item objectForKey:@"categories"];
                    
                    for(NSDictionary *category in categories){
                        FeedCategory *categoryItem = [[FeedCategory alloc] init];
                        categoryItem.id = [category objectForKey:@"id"];
                        categoryItem.label = [category objectForKey:@"label"];
                        [subItem.categories addObject:categoryItem];
                    }
                    [result addObject: subItem];
                }
                
                c(result);
            });
        }
    
}


-(void)setAsRead: (NSString*) itemId complete: (EmptyCompleteBlock)callback
{
    NSString* param = @"{\"action\":\"markAsRead\",";
    
    param = [param stringByAppendingString:@"\"type\":\"entries\","];
    param = [param stringByAppendingString: [NSString stringWithFormat:@"\"entryIds\":[\"%@\"]}", itemId]];
    
    NSMutableURLRequest *request = [self getRequest:@"http://cloud.feedly.com/v3/markers"];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *requestBodyData = [param dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    
    
    //NSURLResponse *response = nil;
    //NSError *outError = [[NSError alloc] init];
    
    //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
    
   // [NSURLConnection sendAsynchronousRequest:request queue:<#(NSOperationQueue *)#> completionHandler:<#^(NSURLResponse *response, NSData *data, NSError *connectionError)handler#>
     
     [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         if (data){
             dispatch_async(kBgQueue, ^{
                 NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 if ([stringData compare:@""] == NSOrderedSame)
                     callback(TRUE);
                 else
                     callback(FALSE);
             });
         }
         
    }];
     
    
}

-(void)setAsUnRead: (NSString*) itemId complete: (EmptyCompleteBlock)callback
{
    NSString* param = @"{\"action\":\"keepUnread\",";
    
    param = [param stringByAppendingString:@"\"type\":\"entries\","];
    param = [param stringByAppendingString: [NSString stringWithFormat:@"\"entryIds\":[\"%@\"]}", itemId]];
    
    NSMutableURLRequest *request = [self getRequest:@"http://cloud.feedly.com/v3/markers"];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *requestBodyData = [param dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    
    
    NSURLResponse *response = nil;
    NSError *outError = [[NSError alloc] init];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
    if (data){
        dispatch_async(kBgQueue, ^{
            NSString * stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"setAsUnread:%@", stringData);
            
            if ([stringData compare:@""] == NSOrderedSame)
                callback(TRUE);
            else
                callback(FALSE);
        });
    }
}

-(NSMutableURLRequest*) getRequest: (NSString*) uri{
    
    NSURL *url  = [NSURL URLWithString:uri];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    NSString* oAuth = @"OAuth ";
    
    [request setValue: [oAuth stringByAppendingString: self.AuthToken] forHTTPHeaderField:@"Authorization"];

    return request;
}

@end
