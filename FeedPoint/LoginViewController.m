//
//  LoginViewController.m
//  FeedPoint
//
//  Created by Alex Yakhnin on 10/17/13.
//  Copyright (c) 2013 Alex Yakhnin. All rights reserved.
//

#import "LoginViewController.h"
#import "URLParser.h"
#import "FeedPointAppDelegate.h"
#import "PagingViewController.h"
#import "Token.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webViewInstance.delegate = self;
    
    
    
    NSURL *url = [NSURL URLWithString:@"http://cloud.feedly.com/v3/auth/auth?client_id=feedpoint&redirect_uri=http%3A%2F%2Ffpservice.azurewebsites.net%2Flogin.html&scope=https%3A%2F%2Fcloud.feedly.com%2Fsubscriptions&response_type=code"];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    [self.webViewInstance loadRequest:request];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *url = webView.request.URL;
    //if (url.absoluteString.in)
        
    NSRange range = [url.absoluteString  rangeOfString:@"code="];
    if ( range.length > 0 ) {
        
        URLParser *parser = [[URLParser alloc] initWithURLString:url.absoluteString];
        NSString *authCode = [parser valueForVariable:@"code"];
        
        NSString *tokenUrl = @"http://cloud.feedly.com/v3/auth/token";
        
        //NSURLRequest *request = [NSURLRequest requestWithURL:tokenUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
        NSURLResponse *response = nil;
        NSError *outError = [[NSError alloc] init];
        
    
            
        // Create the request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tokenUrl]cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];

        // Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // Convert your data and set your request's HTTPBody property
        NSString *stringData = @"client_id=feedpoint&state=12345&client_secret=P035ZG1MB80E71BI66XN6MU4&grant_type=authorization_code&redirect_uri=http://fpservice.azurewebsites.net/login.html&code=";
        
        NSString *formData = [stringData stringByAppendingString: authCode];
        
        
        NSData *requestBodyData = [formData dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&outError];
        
        if (data){
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data //1
                                  options:kNilOptions
                                  error:&error];
            
            Token* token = [[Token alloc] init];
            
            token.accessToken = [json objectForKey:@"access_token"]; //2
            token.userId = [json objectForKey:@"id"];
            
            FeedPointAppDelegate *app = ((FeedPointAppDelegate*)[UIApplication sharedApplication].delegate);
            [app saveToken: token];
            
            UINavigationController* navController = app.navigationController;
            app.feedService.AuthToken = token.accessToken;
            app.feedService.UserId = token.userId;
            
            dispatch_async(kBgQueue, ^{
                
                [navController popViewControllerAnimated:TRUE];
                
                [app.viewController ReloadData];
            });
            
            
        }
     
    
    }

}



@end
