Module XX: *Manage Lists in a O365 tenant with iOS*
==========================

##Overview

The lab lets students use an AzureAD account to manage lists in a O365 Sharepoint tenant with an iOS app.

##Objectives

- Learn how to create a client for O365 to manage lists and listsItems
- Learn how to add features to create, edit and delete lists and items within an iOS app.

##Prerequisites

- Apple Macintosh environment
- XCode 6 (from the AppStore - compatible with iOS8 sdk)
- XCode developer tools (it will install git integration from XCode and the terminal)
- You must have a Windows Azure subscription to complete this lab.
- You must have completed Module 04 and linked your Azure subscription with your O365 tenant.

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
01. Download the starting point App:

    ```
    git clone 
    ```

02. Open the **.xcodeproj** file in the O365-lists-app

03. Find and Open the **ViewController.m** class under **O365-lists-app/controllers/login/**

04. Fill the AzureAD account settings in the **viewDidLoad** method
    
    ![](img/fig.01.png)

03. Build and Run the project in an iOS Simulator to check the views

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
    We will use a files-sdk in order to access the environment using two classes called 
    "ListEntity" and "ListItem" that have all necesary data to manage the content.

    --We continue with the O365-lists-sdk library import to the project--
    ```

    ![](img/fig.08.png)

###Task 2 - Import the library
01. Download a copy of the library using the terminal:

    ```
    git clone 
    ```

02. Open the downloaded folder and copy **office365-lists-sdk** folder under **Sdk-ObjectiveC**. Paste it in a lib folder inside our project path.

    ![](img/fig.02.png)

03. Drag the **office365-lists-sdk.xcodeproj** file into XCode under our application project.
    
    ![](img/fig.03.png)

05. Go to project settings selecting the first file from the files explorer. Then click on **Build Phases** and add an entry in the **Target Dependencies** section.

    ![](img/fig.04.png)

06. Select the **office365-lists-sdk** library dependency.

    ![](img/fig.05.png)

07. Under **Link Binary with Libraries** add an entry pointing to **office365-lists-sdk.a** file

    ![](img/fig.06.png) 

08. Follow 05-07 steps again, this time for the **Extension target**.

    ![](img/fig.15.png)

08. Build and Run the application to check is everithing is ok.

    ![](img/fig.07.png)

<a name="exercise2"></a>
##Exercise 2: Create a Client class for all operations
In this exercise you will create a client class for all the operations related to Projects and References. This class will connect to the **office365-lists-sdk**
and do some parsing and JSON handling

###Task 1 - Create a client class to connect to the o365-lists-sdk

01. On the XCode files explorer, under the group **ResearchProjectTrackerApp** you will se a **client** empty folder. Also under **ResearchProjectTrackerExtension/Supporting Files**
you have another **client** folder.

    ![](img/fig.09.png)

02. On the firt one, make a right click in the client folder and select **New File**. You will see the **New File wizard**. Click on the **iOS** section, select **Cocoa Touch Class** and click **Next**.

    ![](img/fig.10.png)

03. In this section, configure the new class giving it a name (**ProjectClient**), and make it a subclass of **ListClient**. Make sure that the language dropdown is set with **Objective-C** because our o365-lists library is written in this programming language. Finally click **Next**, this will create a **.h** and **.m** files for our new class.

    ![](img/fig.11.png)    

04. Now we are going to select where the new class sources files (.h and .m) will be stored. In this case we can click on **Create** directly.

    ![](img/fig.12.png)

05. Do the same for the other **client** folder under the **ResearchProjectTrackerExtension** in order to create the **ProjectClientEx** class, but in the last step of the wizard, change the target, to add visibility to this scope.

    ![](img/fig.13.png)

06. Now you will have a file structure like this:

    [](img/fig.14.png)

07. Build the Project and you will see 2 errors. To fix them change the import sentences On **ProjectClient.h** and **ProjectClientEx.m**.

    From :
    ```
    #import "ListClient.h"
    ```

    To:
    ```
    #import <office365-lists-sdk/ListClient.h>
    ```

08. Re-build the project and check everything is ok.



###Task 2 - Add the ProjectClient methods

01. Under **client** group, you will see the **ProjectClient.h** class. Open it and check the empty methods:

    ```
    - (NSURLSessionDataTask *)getReferencesByProjectId:(NSString *)projectId callback:(void (^)(NSMutableArray *listItems, NSError *error))callback;
    - (NSURLSessionDataTask *)addProject:(ListItem *)listItem callback: (void (^)(BOOL success, NSError *error))callback;
    - (NSURLSessionDataTask *)addReference:(ListItem *)reference callback: (void (^)(BOOL success, NSError *error))callback;
    - (NSURLSessionDataTask *)updateProject:(ListItem *)project callback:(void (^)(BOOL, NSError *))callback;
    - (NSURLSessionDataTask *)updateReference:(ListItem *)reference callback:(void (^)(BOOL, NSError *))callback;
    - (NSURLSessionDataTask *)deleteListItem:(NSString *)name itemId:(NSString *)itemId callback:(void (^)(BOOL result, NSError *error))callback;
    ```

02. Each method is responsible of retrieve data from the O365 tenant and parse it, or manage add, edit, delete actions.

    ```
    - (NSURLSessionDataTask *)getReferencesByProjectId:(NSString *)projectId callback:(void (^)(NSMutableArray *listItems, NSError *error))callback;
    - (NSURLSessionDataTask *)addProject:(ListItem *)listItem callback: (void (^)(BOOL success, NSError *error))callback;
    - (NSURLSessionDataTask *)addReference:(ListItem *)reference callback: (void (^)(BOOL success, NSError *error))callback;
    - (NSURLSessionDataTask *)updateProject:(ListItem *)project callback:(void (^)(BOOL, NSError *))callback;
    - (NSURLSessionDataTask *)updateReference:(ListItem *)reference callback:(void (^)(BOOL, NSError *))callback;
    - (NSURLSessionDataTask *)deleteListItem:(NSString *)name itemId:(NSString *)itemId callback:(void (^)(BOOL result, NSError *error))callback;
    ```

03. Build the project and check everything is ok.



<a name="exercise3"></a>
##Exercise 3: Connect actions in the view to ProjectClient class
In this exercise you will navigate in every controller class of the project, in order to connect each action (from buttons, lists and events) with one ProjectClient operation.

###Task1 - Wiring up ProjectTableView

01.

###Task2 - Wiring up CreateProjectView

01.

###Task3 - Wiring up ProjectDetailsView

01.

###Task4 - Wiring up EditProjectView

01.

###Task5 - Wiring up ReferencesTableView

01.

###Task6 - Wiring up CreateReferenceView

01.

###Task7 - Wiring up ReferenceDetailsView

01.

###Task8 - Wiring up EditReferenceView

01.







##Summary

By completing this hands-on lab you have learnt:

01. Some of the basics of iOS development.

02. How to add the ADALiOS library and bundles to the application 

03. How to call login and clear operations to handle the token from an AzureAD account for further requests

