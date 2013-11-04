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

@property (nonatomic, retain) IBOutlet UILabel *label;

@property (strong, nonatomic) FeedItem* item;

@property (nonatomic, strong) NSString *title;

-(void)updateCell;

@end
