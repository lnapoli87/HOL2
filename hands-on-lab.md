Module XX: *Manage Lists in a O365 tenant with iOS*
==========================

##Overview

The lab lets students use an AzureAD account to manage lists in a O365 Sharepoint tenant with an iOS app.

##Objectives

- Learn how to create a client for O365 to manage lists and listsItems
- Learn how to sadd features to create, edit and delete lists and items within an iOS app.

##Prerequisites

- Apple Macintosh environment
- XCode 6 (from the AppStore - compatible with iOS8 sdk)
- XCode developer tools (it will install git integration from XCode and the terminal)
- You must have a Windows Azure subscription to complete this lab.
- You must have completed Module 04 and linked your Azure subscription with your O365 tenant.
- You must have Cocoapods dependencies manager already installed on the Mac. (cocoapods.org)

##Exercises

The hands-on lab includes the following exercises:

- [Add O365 iOS lists sdk library to the project](#exercise1)
- [Create a Client class for all operations](#exercise2)
- [Connect actions in the view to ProjectClient class](#exercise3)

<a name="exercise1"></a>
##Exercise 1: Add O365 iOS lists sdk library to a project
In this exercise you will use an existing application with the AzureAD authentication included, to add the O365 lists sdk library in the project
and create a client class with empty methods in it to handle the requests to the Sharepoint tenant.

###Task 1 - Open the Project
01. Clone this git repository in your machine

02. Open a Terminal and navigate to the root folder of the project. Execute the following:

    ```
    pod install
    ```

03. Open the **.xcworkspace** file in the O365-lists-app

04. Find and Open the **Auth.plist**

05. Fill the AzureAD account settings
    
    ![](img/fig.01.png)

06. Build and Run the project in an iOS Simulator to check the views

    ```
    Application:
    You will se a login page with buttons to access the application and to clear credentials.
    Once authenticated, a Project list will appear with one fake entry. Also there is an add 
    Project screen (tapping the plus sign), and a Project Details screen (selecting a row in 
    the table) with References that contains a Title, Comments and a Url that can be opened
    in Safari app. Finally we can access to the screens to manage the References.

    Environment:
    To manage Projects and its References, we have two lists called "Research Projects" and 
    "Research References" in a Office365 Sharepoint tenant.
    Also we have permissions to add, edit and delete items from a list.
    ```

    ![](img/fig.08.png)


<a name="exercise2"></a>
##Exercise 2: Create a Client class for all operations
In this exercise you will create a client class for all the operations related to Projects and References. This class will connect to the **office365-lists-sdk**
and do some parsing and JSON handling

###Task 1 - Create a client class to connect to the o365-lists-sdk

01. On the XCode files explorer, under the group **ResearchProjectTrackerApp** you will se a **client** empty folder. Also under **ResearchProjectTrackerExtension/Supporting Files**
you have another **client** folder.

    ![](img/fig.09.png)

02. On the first one, make a right click in the client folder and select **New File**. You will see the **New File wizard**. Click on the **iOS** section, select **Cocoa Touch Class** and click **Next**.

    ![](img/fig.10.png)

03. In this section, configure the new class giving it a name (**ProjectClient**), and make it a subclass of **NSObject**. Make sure that the language dropdown is set with **Objective-C** because our o365-lists library is written in that programming language. Finally click on **Next**.

    ![](img/fig.11.png)    

04. Now we are going to select where the new class sources files (.h and .m) will be stored. In this case we can click on **Create** directly. This will create a **.h** and **.m** files for our new class.

    ![](img/fig.12.png)

05. Do the same for the other **client** folder under the **ResearchProjectTrackerExtension** in order to create the **ProjectClientEx** class, but in the last step of the wizard, change the target, to add visibility to this scope.

    ![](img/fig.13.png)

06. Now you will have a file structure like this:

    ![](img/fig.14.png)

08. Build the project and check everything is ok.



###Task 2 - Add ProjectClient methods

01. Open the **ProjectClient.h** class and then add the following between **@interface** and **@end**

    ```
    - (NSURLSessionDataTask *)addProject:(NSString *)listName token:(NSString *)token callback:(void (^)(NSError *error))callback;
- (NSURLSessionDataTask *)updateProject:(NSDictionary *)project token:(NSString *)token callback:(void (^)(BOOL, NSError *))callback;
- (NSURLSessionDataTask *)updateReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(BOOL, NSError *))callback;
- (NSURLSessionDataTask *)addReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(NSError *))callback;
- (NSURLSessionDataTask *)getReferencesByProjectId:(NSString *)projectId token:(NSString *)token callback:(void (^)(NSMutableArray *listItems, NSError *error))callback;
- (NSURLSessionDataTask *)deleteListItem:(NSString *)name itemId:(NSString *)itemId token:(NSString *)token callback:(void (^)(BOOL result, NSError *error))callback;
- (NSURLSessionDataTask *)getProjectsWithToken:(NSString *)token andCallback:(void (^)(NSMutableArray *listItems, NSError *))callback;
    ```

    Each method is responsible of retrieve data from the O365 tenant and parse it, or managing add, edit, delete actions.

02. Add the body of each method in the **ProjectClient.m** file.

    Add Project
    ```
    const NSString *apiUrl = @"/_api/lists";

- (NSURLSessionDataTask *)addProject:(NSString *)projectName token:(NSString *)token callback:(void (^)(NSError *))callback
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* projectListName = @"Research%20Projects";
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", shpUrl , apiUrl, projectListName ];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Title': '%@'}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, projectName];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    [theRequest setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        callback(error);
    }];
    
    return task;
}
    ```

    Update Project
    ```
- (NSURLSessionDataTask *)updateProject:(NSDictionary *)project token:(NSString *)token callback:(void (^)(BOOL, NSError *))callback
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* projectListName = @"Research%20Projects";
    
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", shpUrl , apiUrl, projectListName, [project valueForKey:@"Id"]];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Title': '%@'}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [project valueForKey:@"Title"]];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    [theRequest setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        callback((!jsonResult && [myString isEqualToString:@""]), error);
    }];
    
    return task;
}

    ```

    Update Reference
    ```
- (NSURLSessionDataTask *)updateReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(BOOL, NSError *))callback
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* referenceListName = @"Research%20References";
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", shpUrl , apiUrl, referenceListName, [reference valueForKey:@"Id"]];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Comments': '%@', 'URL':{'Url':'%@', 'Description':'%@'}}";
    
    NSDictionary *dic =[reference valueForKey:@"URL"];
    NSString *refUrl = [dic valueForKey:@"Url"];
    NSString *refTitle = [dic valueForKey:@"Description"];
    
    NSString *formatedJson = [NSString stringWithFormat:json, [reference valueForKey:@"Comments"], refUrl, refTitle];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    [theRequest setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        callback((!jsonResult && [myString isEqualToString:@""]), error);
    }];
    
    return task;
}
    ```

    Add Reference
    ```
- (NSURLSessionDataTask *)addReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(NSError *))callback
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* referenceListName = @"Research%20References";
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", shpUrl , apiUrl, referenceListName];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'URL': %@, 'Comments':'%@', 'Project':'%@'}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [reference valueForKey:@"URL"], [reference valueForKey:@"Comments"], [reference valueForKey:@"Project"]];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    [theRequest setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        callback(error);
    }];
    
    return task;
}
    ```

    Get References by Project
    ```
- (NSURLSessionDataTask *)getReferencesByProjectId:(NSString *)projectId token:(NSString *)token callback:(void (^)(NSMutableArray *listItems, NSError *error))callback{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* referenceListName = @"Research%20References";
    NSString_Extended *queryString = [NSString stringWithFormat:@"Project eq '%@'", projectId];
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items?$filter=%@", shpUrl , apiUrl, referenceListName, [queryString urlencode]];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"GET"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        callback([self parseDataArray:data] ,error);
    }];
    
    return task;
}
    ```

    Delete an Item
    ```
- (NSURLSessionDataTask *)deleteListItem:(NSString *)name itemId:(NSString *)itemId token:(NSString *)token callback:(void (^)(BOOL result, NSError *error))callback{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", shpUrl , apiUrl, name, itemId];
   
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"DELETE"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        
        BOOL result = FALSE;
        
        if(error == nil && [data length] == 0 ){
            result = TRUE;
        }
        
        callback(result, error);
    }];
    
    return task;
}

    ```

    Get Projects (with Editor info)
    ```
- (NSURLSessionDataTask *)getProjectsWithToken:(NSString *)token andCallback:(void (^)(NSMutableArray *listItems, NSError *))callback{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* projectListName = @"Research%20Projects";
    NSString_Extended* filter = @"ID,Title,Modified,Editor/Title";
    NSString *aditionalParams = [NSString stringWithFormat:@"?$select=%@&$expand=Editor", [filter urlencode]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items%@", shpUrl , apiUrl, projectListName, aditionalParams];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"GET"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        callback([self parseDataArray:data] ,error);
    }];
    
    return task;
}
    ```

03. Add the **JSON** handling methods:

    Parsing Results
    ```
    - (NSMutableArray *)parseDataArray:(NSData *)data{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error ;
    
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:[self sanitizeJson:data]
                                                               options: NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSArray *jsonArray = [[jsonResult valueForKey : @"d"] valueForKey : @"results"];
    
    if(jsonArray != nil){
        for (NSDictionary *value in jsonArray) {
            [array addObject: value];
        }
    }else{
        NSDictionary *jsonItem =[jsonResult valueForKey : @"d"];
        
        if(jsonItem != nil){
            [array addObject:jsonItem];
        }
    }
    
    return array;
}
    ```

    Sanitizing JSON
    ```
 - (NSData*) sanitizeJson : (NSData*) data{
    NSString * dataString = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString* replacedDataString = [dataString stringByReplacingOccurrencesOfString:@"E+308" withString:@"E+127"];
    
    NSData* bytes = [replacedDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    return bytes;
}
    ```



04. Add the following import sentence:

    ```
    #import "NSString_Extended.h"
    ```

05. Build the project and check everything is ok.

06. In **ProjectClientEx.h** header file, add the following declaration between **@interface** and **@end**

    ```
    - (NSURLSessionDataTask *)addReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(NSError *))callback;
- (NSURLSessionDataTask *)getProjectsWithToken:(NSString *)token andCallback:(void (^)(NSMutableArray *listItems, NSError *))callback;
    ```

07. Now on **ProjectClientEx.m** add the method body:

    ```
const NSString *apiUrl = @"/_api/lists";

- (NSURLSessionDataTask *)addReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(NSError *))callback
{
    NSBundle *extensionBundle = [NSBundle bundleWithIdentifier:@"com.intergen.ResearchProjectTrackerApp.ResearchProjectTrackerEx"];
    NSString* plistPath = [extensionBundle pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* referenceListName = @"Research%20References";
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", shpUrl , apiUrl, referenceListName];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'URL': %@, 'Comments':'%@', 'Project':'%@'}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [reference valueForKey:@"URL"], [reference valueForKey:@"Comments"], [reference valueForKey:@"Project"]];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    [theRequest setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        callback(error);
    }];
    
    return task;
}

- (NSURLSessionDataTask *)getProjectsWithToken:(NSString *)token andCallback:(void (^)(NSMutableArray *listItems, NSError *))callback{
    NSBundle *extensionBundle = [NSBundle bundleWithIdentifier:@"com.intergen.ResearchProjectTrackerApp.ResearchProjectTrackerEx"];
    NSString* plistPath = [extensionBundle pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* projectListName = @"Research%20Projects";
    NSString_Extended* filter = @"ID,Title,Modified,Editor/Title";
    NSString *aditionalParams = [NSString stringWithFormat:@"?$select=%@&$expand=Editor", [filter urlencode]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items%@", shpUrl , apiUrl, projectListName, aditionalParams];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"GET"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json; odata=verbose" forHTTPHeaderField:@"accept"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        callback([self parseDataArray:data] ,error);
    }];
    
    return task;
}
    ```

08. Add the **JSON** handling methods:

    Parsing Results
    ```
    - (NSMutableArray *)parseDataArray:(NSData *)data{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error ;
    
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:[self sanitizeJson:data]
                                                               options: NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSArray *jsonArray = [[jsonResult valueForKey : @"d"] valueForKey : @"results"];
    
    if(jsonArray != nil){
        for (NSDictionary *value in jsonArray) {
            [array addObject: value];
        }
    }else{
        NSDictionary *jsonItem =[jsonResult valueForKey : @"d"];
        
        if(jsonItem != nil){
            [array addObject:jsonItem];
        }
    }
    
    return array;
}
    ```

    Sanitizing JSON
    ```
 - (NSData*) sanitizeJson : (NSData*) data{
    NSString * dataString = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString* replacedDataString = [dataString stringByReplacingOccurrencesOfString:@"E+308" withString:@"E+127"];
    
    NSData* bytes = [replacedDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    return bytes;
}
    ```

09. Add the following import sentences on **ProjectClientEx.m**

    ```
#import "office365-base-sdk/NSString+NSStringExtensions.h"
    ```

10. Build and Run the application and check everything is ok.

<a name="exercise3"></a>
##Exercise 3: Connect actions in the view to ProjectClient class
In this exercise you will navigate in every controller class of the project, in order to connect each action (from buttons, lists and events) with one ProjectClient operation.

```
The Application has every event wired up with their respective controller classes. 
We need to connect this event methods to our ProjectClient/ProjectClientEx class 
in order to have access to the o365-lists-sdk.
```

###Task1 - Wiring up ProjectTableView

01. Take a look to the **ProjectTableViewController.m** class implementation. More specifically, the **loadData** method.

    ![](img/fig.16.png)

    ```
    This empty method shows how we use the spinner and then call the data function, 
    delegating in this method the data gathering and spinner stop.

    All the calls to the O365 client begins creating a NSURLSessionTask that will
    be executed asynchronously and then call to a callback block that will change the view
    and to show the data or an error message, also in an async way, putting all the changes
    in the Execution Main Queue, using:
    ```

    ```
    dispatch_async(dispatch_get_main_queue(), ^{
        //changes to the view
    }
    ```

02. Add the **loadData** method body:

    ```
    -(void)loadData{
    //Create and add a spinner
    double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
    double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClient* client = [[ProjectClient alloc] init];
    
    NSURLSessionTask* listProjectsTask = [client getProjectsWithToken:self.token andCallback:^(NSMutableArray *listItems, NSError *error) {
        if(!error){
            self.projectsList = listItems;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [spinner stopAnimating];
            });
        }
    }];
    [listProjectsTask resume];
}
    ```


03. Now fill the table with the projects information

    ```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"ProjectListCell";
    ProjectTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    NSDictionary *item = [self.projectsList objectAtIndex:indexPath.row];
    cell.ProjectName.text = [item valueForKey:@"Title"];
    
    NSDictionary *editorInfo =[item valueForKey:@"Editor"];
    NSString *editDate = [item valueForKey:@"Modified"];
    cell.lastModifier.text =[NSString stringWithFormat:@"Last modified by %@ on %@", [editorInfo valueForKey:@"Title"],[editDate substringToIndex:10]];
    
    return cell;
}
    ```

04. Get projects count
    
    ```
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectsList count];
}
    ```

05. Row selection
    
    ```
    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentEntity= [self.projectsList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"detail" sender:self];
}
    ```

06. Set the selectedProject when navigate forward

    ```
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"newProject"]){
        CreateViewController *controller = (CreateViewController *)segue.destinationViewController;
        controller.token = self.token;
    }else{
        ProjectDetailsViewController *controller = (ProjectDetailsViewController *)segue.destinationViewController;
        //controller.project = currentEntity;
        controller.token = self.token;
    }
    
}
    ```

07. Add the instance variable for the selected project:

    ```
    NSDictionary* currentEntity;
    ```

08. Add the import sentence for the ProjectClient class

    ```
    #import "ProjectClient.h"
    ```

09. Build and Run the app, and check everything is ok. You will see the project lists in the main screen

    ![](img/fig.17.png)

###Task2 - Wiring up CreateProjectView

01. Open **CreateViewController.m** and add the body to the **createProject** method

    ```
-(void)createProject{
    if(![self.FileNameTxt.text isEqualToString:@""]){
        double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
        double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        [spinner startAnimating];
        
        ProjectClient* client = [[ProjectClient alloc] init];
        
        NSURLSessionTask* task = [client addProject:self.FileNameTxt.text token:self.token callback:^(NSError *error) {
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                NSString *errorMessage = [@"Add Project failed. Reason: " stringByAppendingString: error.description];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
                [alert show];
            }
        }];
        [task resume];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Complete all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}

    ```

02. Add the import sentence to the **ProjectClient** class

    ```
    #import "ProjectClient.h"
    ```

03. Build and Run the app, and check everything is ok. Now you can create a new project with the plus button in the left corner of the main screen

    ![](img/fig.18.png)


###Task3 - Wiring up ProjectDetailsView

01. Open **ProjectDetailsViewController.h** and add the following variables

    ```
    @property NSDictionary* project;
    @property NSDictionary* selectedReference;
    ```

02. Set the value when the user selects a project in the list. On **ProjectTableViewController.m**

    Uncomment this line in the **prepareForSegue:sender:** method
    ```
    //controller.project = currentEntity;
    ```

03. Back to the **ProjectDetailsViewController.m** Set the fields and screen title text on the **viewDidLoad** method

    ```
-(void)viewDidLoad{
    self.projectName.text = [self.project valueForKey:@"Title"];
    self.navigationItem.title = [self.project valueForKey:@"Title"];
    self.navigationItem.rightBarButtonItem.title = @"Done";
    self.selectedReference = false;
    self.projectNameField.hidden = true;
}
    ```

04. Load the references

    Load data method
    ```
-(void)loadData{
    double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
    double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClient* client = [[ProjectClient alloc] init];
    
    [self getReferences:spinner];    
}

-(void)getReferences:(UIActivityIndicatorView *) spinner{
    ProjectClient* client = [[ProjectClient alloc] init];
    
    NSURLSessionTask* listReferencesTask = [client getReferencesByProjectId:[self.project valueForKey:@"Id"] token:self.token callback:^(NSMutableArray *listItems, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.references = [listItems copy];
                [self.refencesTable reloadData];
                [spinner stopAnimating];
            });
        
        }];

    [listReferencesTask resume];
}
    ```


05. Fill the table cells

    ```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"referencesListCell";
    ReferencesTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    NSDictionary *item = [self.references objectAtIndex:indexPath.row];
    NSDictionary *dic =[item valueForKey:@"URL"];
    cell.titleField.text = [dic valueForKey:@"Description"];
    cell.urlField.text = [dic valueForKey:@"Url"];
    
    return cell;
}
    ```

06. Get the references count
    
    ```
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.references count];
}
    ```

07. Row selection

    ```
    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedReference= [self.references objectAtIndex:indexPath.row];    
    [self performSegueWithIdentifier:@"referenceDetail" sender:self];
}
    ```

08. Forward navigation

    ```
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"createReference"]){
        CreateReferenceViewController *controller = (CreateReferenceViewController *)segue.destinationViewController;
        controller.project = self.project;
        controller.token = self.token;
    }else if([segue.identifier isEqualToString:@"referenceDetail"]){
        ReferenceDetailsViewController *controller = (ReferenceDetailsViewController *)segue.destinationViewController;
        controller.selectedReference = self.selectedReference;
        controller.token = self.token;
    }else if([segue.identifier isEqualToString:@"editProject"]){
        EditProjectViewController *controller = (EditProjectViewController *)segue.destinationViewController;
        controller.project = self.project;
        controller.token = self.token;
    }
    self.selectedReference = false;
}
    ```

    ```
    - (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return ([identifier isEqualToString:@"referenceDetail"] && self.selectedReference) || [identifier isEqualToString:@"createReference"] || [identifier isEqualToString:@"editProject"];
}
    ```

09. Add the import sentence to the **ProjectClient** class

    ```
    #import "ProjectClient.h"
    ```

10. Build and Run the app, and check everything is ok. Now you can see the references from a project

    ![](img/fig.19.png)

###Task4 - Wiring up EditProjectView

01. Adding a variable for the selected project 

    First, add a variable **project** in the **EditProjectViewController.h**
    ```
    @property NSDictionary* project;
    ```

02. On the **ProjectDetailsViewController.m**, uncomment this line in the **prepareForSegue:sender:** method

    ```
    //controller.project = self.project;
    ```

03. Back to **EditProjectViewController.m**. Add the body for **updateProject**

    ```
-(void)updateProject{
    if(![self.ProjectNameTxt.text isEqualToString:@""]){
        double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
        double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        [spinner startAnimating];
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[@"Title",self.ProjectNameTxt.text, [self.project valueForKey:@"Id"]] forKeys:@[@"_metadata",@"Title",@"Id"]];
        
        ProjectClient* client = [[ProjectClient alloc]init];
        
        NSURLSessionTask* task = [client updateProject:dic token:self.token callback:^(BOOL result, NSError *error) {
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    ProjectTableViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                    [self.navigationController popToViewController:View animated:YES];
                });
            }else{
                NSString *errorMessage = [@"Update Project failed. Reason: " stringByAppendingString: error.description];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
                [alert show];
            }
        }];
        [task resume];
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Complete all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}
    ```

04. Do the same for **deleteProject**

    ```
-(void)deleteProject{
    double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
    double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClient* client = [[ProjectClient alloc] init];

    NSURLSessionTask* task = [client deleteListItem:@"Research%20Projects" itemId:[self.project valueForKey:@"Id"] token:self.token callback:^(BOOL result, NSError *error) {
        if(error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                
                ProjectTableViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                [self.navigationController popToViewController:View animated:YES];
            });
        }else{
            NSString *errorMessage = [@"Delete Project failed. Reason: " stringByAppendingString: error.description];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
            [alert show];
        }
    }];
    
    [task resume];
}
    ```

05. Set the **viewDidLoad** initialization

    ```
-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.ProjectNameTxt.text = [self.project valueForKey:@"Title"];
    self.navigationController.title = @"Edit Project";
}
    ```

06. Add the import sentence to the **ProjectClient** class

    ```
    #import "ProjectClient.h"
    ```

07. Build and Run the app, and check everything is ok. Now you can edit a project

    ![](img/fig.20.png)


###Task5 - Wiring up CreateReferenceView

01. On the **CreateReferenceViewController.m** add the body for the **createReference** method

    ```
-(void)createReference{
    if((![self.referenceUrlTxt.text isEqualToString:@""]) && (![self.referenceDescription.text isEqualToString:@""]) && (![self.referenceTitle.text isEqualToString:@""])){
        double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
        double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        [spinner startAnimating];
        
        ProjectClient* client = [[ProjectClient alloc] init];
        
        NSString* obj = [NSString stringWithFormat:@"{'Url':'%@', 'Description':'%@'}", self.referenceUrlTxt.text, self.referenceTitle.text];
        NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[obj, self.referenceDescription.text, [NSString stringWithFormat:@"%@", [self.project valueForKey:@"Id"]]] forKeys:@[@"URL", @"Comments", @"Project"]];
        
        NSURLSessionTask* task = [client addReference:dic token:self.token callback:^(NSError *error) {
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    NSString *errorMessage = (error) ? [@"Add Reference failed. Reason: " stringByAppendingString: error.description] : @"Invalid Url";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                });
            }
        }];
        [task resume];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Complete all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}
    ```

    And add the import sentence
    ```
    #import "ProjectClient.h"
    ```

02. On **ProjectDetailsViewController.m** uncomment this line in the method **prepareForSegue:sender:**

    ```
    //controller.project = self.project;
    ```

03. Back in **CreateReferenceViewController.h**, add the variable

    ```
    @property NSDictionary* project;
    ```

04. Build and Run the app, and check everything is ok. Now you can add a reference to a project

    ![](img/fig.21.png)

###Task6 - Wiring up ReferenceDetailsView

01. On **ReferenceDetailsViewController.m** add the initialization method

    ```
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = nil;
    
    NSDictionary *dic =[self.selectedReference valueForKey:@"URL"];
    
    if(![[self.selectedReference valueForKey:@"Comments"] isEqual:[NSNull null]]){
        self.descriptionLbl.text = [self.selectedReference valueForKey:@"Comments"];
    }else{
        self.descriptionLbl.text = @"";
    }
    self.descriptionLbl.numberOfLines = 0;
    [self.descriptionLbl sizeToFit];
    self.urlTableCell.scrollEnabled = NO;
    self.navigationItem.title = [dic valueForKey:@"Description"];
}
    ```

02. Add the table actions

    ```
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = @"referenceDetailsTableCell";
    ReferenceDetailTableCellTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    NSDictionary *dic =[self.selectedReference valueForKey:@"URL"];
    
    cell.urlContentLBL.text = [dic valueForKey:@"Url"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic =[self.selectedReference valueForKey:@"URL"];
    NSURL *url = [NSURL URLWithString:[dic valueForKey:@"Url"]];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}
    ```

03. Forward navigation

    ```
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editReference"]){
        EditReferenceViewController *controller = (EditReferenceViewController *)segue.destinationViewController;
        controller.token = self.token;
        //controller.selectedReference = self.selectedReference;
    }
}
    ```

04. On **ReferenceDetailsViewController.h**, add the variable:

    ```
    @property NSDictionary* selectedReference;
    ```

05. On the **ProjectDetailsViewController.m** uncomment this line on the method **prepareForSegue:sender:**

    ```
    //controller.selectedReference = self.selectedReference;
    ```

06. Build and Run the app, and check everything is ok. Now you can see the Reference details.

    ![](img/fig.22.png)


###Task7 - Wiring up EditReferenceView

01. On **ReferenceDetailsViewController.m** uncomment this line on the method **prepareForSegue:sender**

    ```
    controller.selectedReference = self.selectedReference;
    ```

02. On **EditReferenceViewController.h** add a variable:

    ```
    @property NSDictionary* selectedReference;
    ```

03. On the **EditReferenceViewController.m**, change the **viewDidLoad** method

    ```
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.title = @"Edit Reference";
    
    self.navigationController.view.backgroundColor = nil;
    
    NSDictionary *dic =[self.selectedReference valueForKey:@"URL"];
    
    self.referenceUrlTxt.text = [dic valueForKey:@"Url"];
    
    if(![[self.selectedReference valueForKey:@"Comments"] isEqual:[NSNull null]]){
        self.referenceDescription.text = [self.selectedReference valueForKey:@"Comments"];
    }else{
        self.referenceDescription.text = @"";
    }

    self.referenceTitle.text = [dic valueForKey:@"Description"];
}
    ```

04. Change the **updateReference** method

    ```
-(void)updateReference{
    if((![self.referenceUrlTxt.text isEqualToString:@""]) && (![self.referenceDescription.text isEqualToString:@""]) && (![self.referenceTitle.text isEqualToString:@""])){
        double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
        double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        [spinner startAnimating];
        
        
        NSDictionary* urlDic = [NSDictionary dictionaryWithObjects:@[self.referenceUrlTxt.text, self.referenceTitle.text] forKeys:@[@"Url",@"Description"]];
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[urlDic, self.referenceDescription.text, [self.selectedReference valueForKey:@"Project"], [self.selectedReference valueForKey:@"Id"]] forKeys:@[@"URL",@"Comments",@"Project",@"Id"]];
        

        ProjectClient* client = [[ProjectClient alloc] init];
        
        NSURLSessionTask* task = [client updateReference:dic token:self.token callback:^(BOOL result, NSError *error) {
            if(error == nil && result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    ProjectDetailsViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                    [self.navigationController popToViewController:View animated:YES];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    NSString *errorMessage = (error) ? [@"Update Reference failed. Reason: " stringByAppendingString: error.description] : @"Invalid Url";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                });
            }
        }];
        [task resume];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Complete all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}
    ```

05. Change the **deleteReference**

    ```
-(void)deleteReference{
    double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
    double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClient* client = [[ProjectClient alloc] init];
    
    NSURLSessionTask* task = [client deleteListItem:@"Research%20References" itemId:[self.selectedReference valueForKey:@"Id"] token:self.token callback:^(BOOL result, NSError *error) {
        if(error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                ProjectDetailsViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                [self.navigationController popToViewController:View animated:YES];
            });
        }else{
            NSString *errorMessage = [@"Delete Reference failed. Reason: " stringByAppendingString: error.description];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
            [alert show];
        }
    }];
    
    [task resume];
}
    ```

06. Add the import sentence to the **ProjectClient** class

    ```
    #import "ProjectClient.h"
    ```

07. Build and Run the app, and check everything is ok. Now you can edit and delete a reference.

    ![](img/fig.23.png)


###Task8 - Wiring up Add Reference Safari Extension

```    
The app provides a Safari action extension, that allows the user to share a url and add it to
a project using a simple screen, without entering the main app.
```

01. Add the **loadData** method body on **ActionViewController.m**

    ```
-(void)loadData{
    //Create and add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClientEx *client = [[ProjectClientEx alloc] init];
    
    NSURLSessionTask* task = [client getProjectsWithToken:token andCallback:^(NSMutableArray *list, NSError *error) {
        
        if(!error){
            self.projectsList = list;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.projectTable reloadData];
                [spinner stopAnimating];
            });
        }
        
    }];
    [task resume];
}
    ```

    Add the import sentence
    ```
    #import "ProjectClientEx.h"
    ```

    And an instance variable between **@implementation** and **@end**
    ```
    NSDictionary* currentEntity 
    ```    

02. Finally add the table actions and events, including the selection and the references sharing

    ```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"ProjectListCell";
    ProjectTableExtensionViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    NSDictionary *item = [self.projectsList objectAtIndex:indexPath.row];
    cell.ProjectName.text = [item valueForKey:@"Title"];
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectsList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    
    [spinner startAnimating];
    
    currentEntity= [self.projectsList objectAtIndex:indexPath.row];
    
    NSString* obj = [NSString stringWithFormat:@"{'Url':'%@', 'Description':'%@'}", self.urlTxt.text, @""];
    NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[obj, @"", [NSString stringWithFormat:@"%@", [currentEntity valueForKey:@"Id"]]] forKeys:@[@"URL", @"Comments", @"Project"]];
    
    __weak ActionViewController *sself = self;
    ProjectClientEx *client = [[ProjectClientEx alloc ] init];
    
    NSURLSessionTask* task =[client addReference:dic token:token callback:^(NSError *error) {
        if(error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                sself.projectTable.hidden = true;
                sself.selectProjectLbl.hidden = true;
                sself.successMsg.hidden = false;
                sself.successMsg.text = [NSString stringWithFormat:@"Reference added successfully to the %@ Project.", [currentEntity valueForKey:@"Title"]];
                [spinner stopAnimating];
            });
        }
    }];
    
    [task resume];
}
    ```

05. To Run the app, you should select the correct target. To do so, follow the steps:

    On the **Run/Debug panel control**, you will see the target selected
    ![](img/fig.26.png)

    Click on the target name and select the **Extension Target** and an iOS simulator
    ![](img/fig.27.png)

    Now you can Build and Run the application, but first we have to select what native application
    will open in order to access the extension. In this case, we select **Safari**                                    
    ![](img/fig.28.png)


06. Build and Run the application, check everything is ok. Now you can share a reference url from safari and attach it to a Project with our application.

    Custom Action Extension                                                                                       
    ![](img/fig.24.png)

    Simple view to add a Reference to a Project                                                                  
    ![](img/fig.25.png)

##Summary

By completing this hands-on lab you have learnt:

01. The way to connect an iOS application with an Office365 tenant.

02. How to retrieve information from Sharepoint lists.

03. How to handle the responses in JSON format. And communicate with the infrastructure.

