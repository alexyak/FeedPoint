//
//  WebViewCell.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/3/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"

@interface WebViewCell : UICollectionViewCell

@property (nonatomic, retain) IBOutlet UIWebView *webView;


@property (strong, nonatomic) FeedItem* item;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *html;

-(void)updateCell;

-(void) clear;

@end
