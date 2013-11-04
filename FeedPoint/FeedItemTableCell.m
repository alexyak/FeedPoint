//
//  FeedItemTableCell.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "FeedItemTableCell.h"

@implementation FeedItemTableCell

@synthesize titleLabel = _titleLabel;
@synthesize nameLabel = _nameLabel;
@synthesize updatedDateLabel = _updatedDateLabel;
@synthesize imageView = _imageView;


-(void)layoutSubviews
{
    [super layoutSubviews];
    
        CGFloat height = [self heightOfString:self.titleLabel.text withFont:self.titleLabel.font width: self.titleLabel.bounds.size.width];
        NSLog(@"height: %f", height);
        
        NSLog(@"original y: %f", self.nameLabel.bounds.origin.y);
    
        if (height < 20)
        {
            //if (self.showImage)
                [self.nameLabel setFrame:CGRectMake(102, 32, self.nameLabel.bounds.size.width, self.nameLabel.bounds.size.height )];
            //else
            //    [self.nameLabel setFrame:CGRectMake(10, 28, self.nameLabel.bounds.size.width, self.nameLabel.bounds.size.height )];
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



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSLog(@"before: %f", self.titleLabel.bounds.origin.x);
        
        self.titleLabel.bounds = CGRectMake(5, 7, self.bounds.size.width - 10, self.bounds.size.height - 10);
        
        NSLog(@"after: %f", self.titleLabel.bounds.origin.x);
        self.nameLabel.bounds = CGRectMake(5, 7, self.bounds.size.width - 10, self.bounds.size.height - 10);
        self.updatedDateLabel.bounds = CGRectMake(5, 7, self.bounds.size.width - 10, self.bounds.size.height - 10);
        
        self.imageView.bounds = CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, 0, 0);
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
