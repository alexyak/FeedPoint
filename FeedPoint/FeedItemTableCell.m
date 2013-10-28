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
    if (!self.showImage)
    {
        //NSLog(@"before: %f", self.titleLabel.bounds.origin.x);
    
        //self.titleLabel.bounds = CGRectMake(0, 7, self.bounds.size.width - 10, self.bounds.size.height - 10);
        
       // NSLog(@"after: %f", self.titleLabel.bounds.origin.x);
    
        //self.nameLabel.bounds = CGRectMake(0, 7, self.bounds.size.width - 10, self.bounds.size.height - 10);
        //self.updatedDateLabel.bounds = CGRectMake(0, 7, self.bounds.size.width - 10, self.bounds.size.height - 10);
     
        //self.imageView.hidden = YES;
    }
    else
    {
        //self.imageView.hidden = NO;
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder");
    
    self = [super initWithCoder: aDecoder];
    if (self)
    {
       
    }
    return self;
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
