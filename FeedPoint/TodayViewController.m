//
//  TodayViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/14/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "TodayViewController.h"
#import "FeedPointAppDelegate.h"
#import "IconDownloader.h"


@interface TodayViewController ()

@end

@implementation TodayViewController


-(void) ReloadData{
    [self viewDidLoad];

}
//@synthesize imageView = _imageView;
//@synthesize titleLabel = _titleLabel;
//@synthesize button = _button;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (IBAction)titleClick: (id)sender{
    UIAlertView *messageAlert = [[UIAlertView alloc]
     initWithTitle:@"Row Selected" message:@"Button Clicked" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [messageAlert show];
    
    //   UIAlertView *messageAlert = [[UIAlertView alloc]
    //;                               initWithTitle:@"Row Selected" message:[tableData objectAtIndex:indexPath.row] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Custom initialization
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    FeedPointAppDelegate *app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
    
    if (app.feedService.TodayItems && app.feedService.TodayItems.count > 0)
    {
        
        
        FeedData *feedData = [app.feedService.TodayItems objectAtIndex:0];
        int index = 0;
        
        while(!feedData.imageUrl && index < app.feedService.TodayItems.count)
        {
            feedData =[app.feedService.TodayItems objectAtIndex:index];
            index++;
        }
        
        feedData.imageFullSize = YES;
        
        //if(feedData.image)
        //{
        //    self.imageView.image = feedData.image;
        //}
        //else{
            [self getImage: feedData];
        //}
        
        
        self.view.clipsToBounds = YES;
        
        self.titleLabel.text = feedData.title;
        self.sourceLabel.text = feedData.source;
        self.dateLabel.text = feedData.updated;

    }
    
}

-(void)getImage: (FeedData*) appRecord{
    IconDownloader *iconDownloader = [[IconDownloader alloc] init];
    iconDownloader.appRecord = appRecord;
    [iconDownloader setCompletionHandler:^(IconDownloader *instance){
        
        //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:instance.appRecord.indexPath];
        
        // Display the newly loaded image
        self.imageView.image = instance.appRecord.image;
        
        // Remove the IconDownloader from the in progress list.
        // This will result in it being deallocated.
        //[self.imageDownloadsInProgress removeObjectForKey:instance.appRecord.indexPath];
        
    }];
    [iconDownloader startDownload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
