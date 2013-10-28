//
//  FeedPointAppDelegate.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 9/24/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "FeedPointAppDelegate.h"
#import "FPMainViewController.h"
#import "PagingViewController.h"
#import "LoginViewController.h"
#import "Token.h"

@implementation FeedPointAppDelegate

//@synthesize window;
@synthesize viewController;
@synthesize feedService;

-(void)saveToken: (Token*) token{
    
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [arrayPaths objectAtIndex:0];
    NSString *filePath = [docDirectory stringByAppendingString:@"/token.dat"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject: token.accessToken  forKey:@"token"];
    [dict setObject: token.userId  forKey:@"id"];
    
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        // Serialize the dictionary
        NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            
            NSLog(@"JSON: %@", jsonString);
            
            [jsonString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
            
        }
    }
    
    
}

-(Token*) getToken{
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [arrayPaths objectAtIndex:0];
    NSString *filePath = [docDirectory stringByAppendingString:@"/token.dat"];
    
    //NSString *token = [NSString stringWithContentsOfFile:filePath
    //                                                   encoding:NSUTF8StringEncoding error:nil];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (exists == FALSE)
        return nil;
    
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    Token* token = nil;
    
    // Verify object retrieved is dictionary
    if ([object isKindOfClass:[NSDictionary class]] && error == nil)
    {
        token = [[Token alloc] init];
        
        NSLog(@"dictionary: %@", object);
        
        token.accessToken = [object objectForKey:@"token"];
        token.userId = [object objectForKey:@"id"];
        
    }
    
    return token;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController =[[PagingViewController alloc] initWithNibName:@"PagingViewController" bundle:nil];
    
    //self.mainViewController = [[FPMainViewController alloc] initWithNibName:@"FPMainViewController" bundle:nil];
 
    self.navigationController = [[UINavigationController alloc] initWithRootViewController: self.viewController];
   
    LoginViewController *login =[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];

    
    
    [self.viewController.navigationItem setTitle:@"Today"];
    
    //[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    
    //self.viewController.view.scrollView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.bounds.size.height, 0,0,0);
    
    self.window.rootViewController = self.navigationController;
    
    self.feedService = [[FeedService alloc] init];
    
    Token* token = [self getToken];
    
    if (token == nil)
    {
        [self.navigationController pushViewController:login animated:TRUE];
    }
    else
    {
        self.feedService.AuthToken = token.accessToken;
        self.feedService.UserId = token.userId;
    }
    
    
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    [self.window clipsToBounds];
    
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
