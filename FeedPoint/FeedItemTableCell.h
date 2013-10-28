//
//  FeedItemTableCell.h
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedItemTableCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *updatedDateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@property (nonatomic, assign) BOOL showImage;



@end
