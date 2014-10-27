//
//  Copyright (c) 2014 MS-OpenTech All rights reserved.
//

#import "ViewController.h"
#import "ProjectTableViewController.h"
#import "office365-base-sdk/Credentials.h"
#import <office365-base-sdk/LoginClient.h>
#import <QuartzCore/QuartzCore.h>
@interface ViewController ()
            

@end

@implementation ViewController
            
ADAuthenticationContext* authContext;
NSString* authority;
NSString* redirectUriString;
NSString* resourceId;
NSString* clientId;
Credentials* credentials;
NSString* token;

//ViewController actions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    
    //AzureAD account details
    authority = [NSString alloc];
    resourceId = [NSString alloc];
    clientId = [NSString alloc];
    redirectUriString = [NSString alloc];
    
    authority = @"https://xxx.xxx/xxx";
    redirectUriString = @"http://xxx/xxx";
    resourceId = @"https://xxx.xxx";
    clientId = @"xxx-xxx-xxx-xxx";
    
    token = [NSString alloc];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)Login:(id)sender {
    [self performLogin:FALSE];
}

- (void) performLogin : (BOOL) clearCache{
    
    LoginClient *client = [[LoginClient alloc] initWithParameters:clientId:redirectUriString:resourceId:authority];
    [client login:clearCache completionHandler:^(NSString *t, NSError *e) {
        if(e == nil)
        {
            token = t;
            
            ProjectTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"projectList"];
            controller.token = t;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            NSString *errorMessage = [@"Login failed. Reason: " stringByAppendingString: e.description];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
            [alert show];
        }        
    }];
}

- (IBAction)Clear:(id)sender {
    NSError *error;
    LoginClient *client = [[LoginClient alloc] initWithParameters: clientId: redirectUriString:resourceId :authority];
    
    [client clearCredentials: &error];
    
    if(error != nil){
        NSString *errorMessage = [@"Clear credentials failed. Reason: " stringByAppendingString: error.description];
        [self showOkOnlyAlert:errorMessage : @"Error"];
    }
    else
    {
        [self showOkOnlyAlert:@"Clear credentials success." : @"Success"];
    }
}

-(void) showOkOnlyAlert : (NSString*) message : (NSString*) title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end
