//
//  WebViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 11/3/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewCell.h"
#import "FeedData.h"
#import "IonIcons.h"

@interface WebViewController ()



@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)setupCollectionView {
    [self.collectionView registerClass:[WebViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
    //return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WebViewCell *cell = (WebViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    FeedItem *feedItem = [((FeedData*)[self.dataArray objectAtIndex:indexPath.row]).items objectAtIndex:0];
    
    cell.item = feedItem;
    
    [self.navigationItem setTitle:feedItem.origin.title];
    
    [cell updateCell];
   
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //CGSize size = self.collectionView.frame.size;
    //CGSizeMake(320, 548);
    
    return self.collectionView.frame.size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *menuButton = self.menuButton;
    menuButton.image = [IonIcons imageWithIcon:icon_navicon
                                     iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *backButton = self.backButton;
    backButton.image = [IonIcons imageWithIcon:icon_ios7_arrow_left
                                     iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *forwardButton = self.forwardButton;
    forwardButton.image = [IonIcons imageWithIcon:icon_ios7_arrow_right
                                        iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                         iconSize:30.0f
                                        imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *markButton = self.markButton;
    markButton.image = [IonIcons imageWithIcon:icon_ios7_checkmark_outline
                                     iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                      iconSize:30.0f
                                     imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *shareButton = self.shareButton;
    shareButton.image = [IonIcons imageWithIcon:icon_ios7_upload_outline
                                      iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                       iconSize:30.0f
                                      imageSize:CGSizeMake(30.0f, 30.0f)];
    

    [self setupCollectionView];
    
    UIButton* fakeButton = (UIButton *) [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:icon_ios7_albums_outline
                                                                                         iconColor:[[UIColor alloc] initWithRed:12.0 /255 green:95.0 /255 blue:254.0 /255 alpha:1.0]
                                                                                          iconSize:30.0f
                                                                                         imageSize:CGSizeMake(30.0f, 30.0f)]];
    UIBarButtonItem *fakeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:fakeButton];
    self.navigationItem.rightBarButtonItem = fakeButtonItem;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
