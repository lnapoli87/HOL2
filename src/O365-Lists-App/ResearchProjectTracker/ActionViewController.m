//
//  Copyright (c) 2014 MS-OpenTech All rights reserved.
//

#import "ProjectTableExtensionViewCell.h"
#import "office365-base-sdk/Credentials.h"
#import <office365-base-sdk/LoginClient.h>
#import <office365-base-sdk/OAuthentication.h>
#import <QuartzCore/QuartzCore.h>
#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

ADAuthenticationContext* authContext;
NSString* authority;
NSString* redirectUriString;
NSString* resourceId;
NSString* clientId;
Credentials* credentials;
NSString* token;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    authority = [NSString alloc];
    resourceId = [NSString alloc];
    clientId = [NSString alloc];
    redirectUriString = [NSString alloc];
    authority = @"https://login.windows.net/common";
    resourceId = @"https://foxintergen.sharepoint.com";
    clientId = @"13b04d26-95fc-4fb4-a67e-c850e07822a8";
    redirectUriString = @"http://android/complete";
    token = [NSString alloc];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                
                __weak ActionViewController *sself = self;
                
                [itemProvider loadItemForTypeIdentifier: (NSString *) kUTTypeURL
                                                options: 0
                                      completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
                                          
                                          if (item != nil) {
                                              NSURL *url = item;
                                              sself.sharedUrl = [url absoluteString];
                                              
                                              [sself.urlTxt performSelectorOnMainThread : @ selector(setText : ) withObject:[url absoluteString] waitUntilDone:YES];
                                    
                                          }
                                          
                                      }];
                
            }
        }
    }
    
    [self performLogin:FALSE];
}

- (void) performLogin : (BOOL) clearCache{
    
    LoginClient *client = [[LoginClient alloc] initWithParameters:clientId:redirectUriString:resourceId:authority];
    [client login:clearCache completionHandler:^(NSString *t, NSError *e) {
        if(e == nil)
        {
            token = t;
            
            [self loadData];
        }
        else
        {
            self.projectTable.hidden = true;
            self.selectProjectLbl.hidden = true;
            self.successMsg.hidden = false;
            self.successMsg.text = @"Login from the Research Project Tracker App before adding a Reference";
            self.successMsg.textColor = [UIColor redColor];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}


-(void)loadData{
}


-(void)getProjectsFromList:(UIActivityIndicatorView *) spinner{
}


-(void)createProjectList:(UIActivityIndicatorView *) spinner{
}

- (IBAction)Login:(id)sender {
    [self performLogin:FALSE];
}

- (IBAction)Clear:(id)sender {
    NSError *error;
    LoginClient *client = [[LoginClient alloc] initWithParameters: clientId: redirectUriString:resourceId :authority];
    
    [client clearCredentials: &error];
}



//Table actions
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"ProjectListCell";
    ProjectTableExtensionViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    cell.ProjectName.text = @"aProject";
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
}

@end
