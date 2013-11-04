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

-(void)layoutSubviews
{
    
    CGFloat height = [self heightOfString:self.titleLabel.text withFont:self.titleLabel.font width: self.titleLabel.bounds.size.width];
    NSLog(@"height: %f", height);
    
    NSLog(@"original y: %f", self.nameLabel.bounds.origin.y);
    
    if (height <= 20)
    {
        //if (self.showImage)
        //    [self.nameLabel setFrame:CGRectMake(102, 30, self.nameLabel.bounds.size.width, self.nameLabel.bounds.size.height )];
        //else
            [self.nameLabel setFrame:CGRectMake(10, 32, self.nameLabel.bounds.size.width, self.nameLabel.bounds.size.height )];
    }
    
}

- (CGFloat)heightOfString:(NSString *)text withFont:(UIFont *)font width: (int) width
{
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: font
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size.height;
}



@end
