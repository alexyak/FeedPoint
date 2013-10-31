//
//  NoImageTableCell.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 29/10/2013.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "NoImageTableCell.h"

@implementation NoImageTableCell

@synthesize titleLabel = _titleLabel;
@synthesize nameLabel = _nameLabel;
@synthesize updatedDateLabel = _updatedDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
