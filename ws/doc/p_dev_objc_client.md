Use the Objective-C WebSocket Client API
========================================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

In this procedure, you will learn how to create an iOS client using the KAAZING Gateway Objective-C Client API. You will learn how to create an Xcode project and add the necessary frameworks in order to use the Objective-C Client API, and implement the Objective-C Client API methods to enable your client to send and receive Echo messages with the Echo service running on [http://www.websocket.org/](http://www.websocket.org/).

For information about deploying your Objective-C (iOS) client on devices with the arm64 architecture, see [Convert Your Objective-C (iOS) Client to a 64-Bit Runtime Environment](#convert-your-objective-c-ios-client-to-a-64-bit-runtime-environment).

This topic covers the following information:

-   [Components and Tools](#components-and-tools)
-   [Taking a Look at the Objective-C Client Demo](#taking-a-look-at-the-objective-c-client-demo)
-   [Primary WebSocket Objective-C API Features](#primary-websocket-objective-c-api-features)
-   [Build the WebSocket Objective-C Demo](#build-the-websocket-objective-c-demo)
-   [Convert Your Objective-C (iOS) Client to a 64-Bit Runtime Environment](#convert-your-objective-c-ios-client-to-a-64-bit-runtime-environment)

Before You Begin
----------------

This procedure is part of [Build Objective-C (iOS) WebSocket Clients](o_dev_objc.md):

1.  **Use the Objective-C WebSocket Client API**
2.  [Secure Your Objective-C Client](p_dev_objc_secure.md)
3.  [Display Logs for the Objective-C Client](p_dev_objc_log.md)
4.  [Troubleshoot Your Objective-C Client](p_dev_objc_tshoot.md)

<span id="Components_and_Tools"></span></a>Components and Tools
---------------------------------------------------------------

Before you get started, review the components and tools used to build the WebSocket Objective-C (iOS) client in this procedure.

| Component or Tool                                               | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Location                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|-----------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| KAAZING Gateway or any RFC-6455 WebSocket endpoint.        | You can use the KAAZING Gateway or any RFC-6455 WebSocket endpoint that hosts an Echo service, such as [www.websocket.org](http://www.websocket.org).                                                                                                                                                                                                                                                                                                                                                                                                          | The KAAZING Gateway is available at [kaazing.org](http://kaazing.org).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| KAAZING Gateway WebSocket Objective-C (iOS) Client library | The Objective-C (iOS) file KGWebSocket.dmg.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | The library is available at [kaazing.org](http://kaazing.org).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| KAAZING Gateway WebSocket Objective-C (iOS) Demo           | A WebSocket Objective-C (iOS) demo that connects to the Gateway or an RFC-6455 WebSocket endpoint, sends an Echo request, and receives and displays an Echo response.                                                                                                                                                                                                                                                                                                                                                                                            | The demo is available at [kaazing.org](http://kaazing.org).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| KGWebSocket.framework                                           | KAAZING Gateway Objective-C framework                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Contained in KGWebSocket.dmg.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| CFNetwork.framework                                             | Core Foundation framework that provides a library of abstractions for network protocols.                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | For more information on CFNetwork, see [Introduction to CFNetwork Programming Guide](https://developer.apple.com/library/mac/#documentation/Networking/Conceptual/CFNetwork/Introduction/Introduction.html).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| MainStoryboard.storyboard                                       | The storyboard for the user interface look and feel and the interactive controls.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `gateway.client.ios.demo/src/main/Xcode/html5.client.ios.demo/en.lproj/MainStoryboard.storyboard`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| KGViewController.h                                              | The header file that contains the target-action mechanism: how the user interface elements send an action message to an object that knows how to perform the corresponding action method (defined in KGViewController.m). In this file, user interface objects and outlet connections (connections between user interface objects and custom controller objects) are defined for the user interface controls. For more information, see [Outlets](http://developer.apple.com/library/mac/#documentation/General/Conceptual/CocoaEncyclopedia/Outlets/Outlets.html). | `gateway.client.ios.demo/src/main/Xcode/html5.client.ios.demo/KGViewController.h`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| KGViewController.m                                              | The implementation file (sometimes called a source file) where the architecture of the client is defined, including how the client responds to different events.                                                                                                                                                                                                                                                                                                                                                                                                    | `gateway.client.ios.demo/src/main/Xcode/html5.client.ios.demo/KGViewController.m`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Development Tool                                                | Xcode 4.4 or later from Apple. The examples in this topic use Xcode 4 and iOS 5.1 SDK.                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | https://developer.apple.com/xcode/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Secure Networking of TLS/SSL                                    | Objective-C (iOS) is run on an iOS device that manages TLS/SSL connections, requesting TLS/SSL certificates from the Gateway or RFC-6455 WebSocket endpoint.                                                                                                                                                                                                                                                                                                                                                                                                     | For more information on securing network connections between the Gateway and an0 Objective-C (iOS) client, see [Secure Network Traffic with the Gateway](../security/o_tls.md "Kaazing Developer Network"). For information on API interfaces needed to configure TLS/SSL trust programmatically for testing, see [Certificate, Key, and Trust Services Reference](https://developer.apple.com/library/ios/documentation/Security/Reference/certifkeytrustservices/index.html#//apple_ref/doc/uid/TP30000157) and [Certificate, Key, and Trust Services Programming Guide](https://developer.apple.com/library/ios/documentation/Security/Conceptual/CertKeyTrustProgGuide/01introduction/introduction.html#//apple_ref/doc/uid/TP40001358). |
| Authentication with Challenge Handlers                          | Authenticating your Objective-C (iOS) client involves implementing a challenge handler to respond to authentication challenges from the Gateway. If your challenge handler is responsible for obtaining user credentials, then you will also need to implement a login handler.                                                                                                                                                                                                                                                                                  | For examples, see the `KGDemoLoginHandler` interface and implementation in KGViewController.m.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

<span id="Demo"></span></a>Taking a Look at the Objective-C Client Demo
-----------------------------------------------------------------------

Before you start, take a look at a demo built using the Objective-C Client API:

1.  Fork or download the KAAZING Gateway Objective-C Client Demo from [kaazing.org](http://kaazing.org).
2.  You can build and run the demo by building the demo project using Xcode. Open the project file **html5.client.ios.demo.xcodeproj** in Xcode, and then run the application in the iPhone simulator. The demo application shows how use the Objective-C API to communicate with the Echo service running on [www.websocket.org](http://www.websocket.org).

Primary WebSocket Objective-C API Features
------------------------------------------

The examples in this section will demonstrate how to open and close a WebSocket connect, send and receive message, and error handling.

### Connecting and Closing Connections

The following example demonstrates how to open and close a connection. A best practice when connecting is to use a `try...catch` block. Note that the WebSocket connection is also closed when the app enters the background and is set to reconnect when the app enters the foreground.

``` objective-c
- (void) createAndEstablishWebSocketConnection:(NSString *)location {
    @try {
        [self log:@&quot;CONNECTING&quot;];

        // Create KGWebSocketFactory
        _factory = [KGWebSocketFactory createWebSocketFactory];

        KGChallengeHandler *challengeHandler = [self createBasicChallengeHandler];

        // Setting the challenge handler will implicitly enable the revalidate extension
        [_factory setDefaultChallengeHandler:challengeHandler];

        // Create KGWebSocket from the KGWebSocketFactory
        NSURL *url = [NSURL URLWithString:location];
        _websocket = [_factory createWebSocket:url];

        // Setup WebSocket events callbacks
        // The application developer can use a delegate based approach as well.
        [self setupWebSocketListeners];
        [_websocket connect];
    }
    @catch (NSException *exception) {
        [self log:[exception reason]];
        [self updateUIcomponents:NO];
        _websocket = nil;
        _factory = nil;
    }
}
...
- (IBAction)closeButton:(id)sender {
    [self log:@"CLOSE"];
    @try {
        [_websocket close];
    }
    @catch (NSException *exception) {
        [self log:[exception reason]];
    }
}
...
- (void)applicationDidEnterBackground {
        // when application moves to background,
        // close the open websocket connection, set reconnect to true
    if (_websocket != nil && [_websocket readyState] == KGReadyState_OPEN) {
        [_websocket close];
        _reconnect = YES;
    }
    else {
        _reconnect = NO;
    }
}
- (void)applicationWillEnterForeground {
        //if reconnect equals to true, reconect the websocket
    if (_websocket != nil && [_websocket readyState] == KGReadyState_OPEN) {
        [self updateUIcomponents:YES];
    }
    else {
        [self updateUIcomponents:NO];
        if (_reconnect) {
            NSString *url = uriTextField.text;

                //connection was open when application enter background, reconnect!
            [self createAndEstablishWebSocketConnection:url];

        }
    }
}
...
// The block to execute when the connection is closed
    _websocket.didClose = ^(KGWebSocket* websocket, NSInteger code, NSString* reason, BOOL wasClean) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ref log:[@"CLOSED" stringByAppendingFormat:@"(%i): Reason: %@", code, reason]];
            [ref updateUIcomponents:NO];
        });
```

### Sending and Receiving Messages

The following code demonstrates sending messages using all of the supported data types.

``` m
- (IBAction)sendMessage:(id)sender {
    @try {
        id dataToSend;
        // If the Binary switch is ON
        if ([binarySwitch isOn]) {
            NSData *data = [self.messageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
            [self log:[NSString stringWithFormat:@"SEND MESSAGE: %@", data]];
            dataToSend = data;
        }
        else {
            NSString *msg = self.messageTextField.text;
            [self log:[@"SEND MESSAGE: " stringByAppendingString:msg]];
            dataToSend = msg;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_websocket send:dataToSend];
        });
    }
    @catch (NSException *exception) {
        [self log:[exception reason]];
    }
}
...
-(void) setupWebSocketListeners {

    KGViewController* ref = self;

        // Attach a block to execute when WebSocket connection is established.
        // This indicates that the connection is ready to send and receive data.
    _websocket.didOpen = ^(KGWebSocket* webSocket) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ref log:@"CONNECTED"];
            [ref updateUIcomponents:YES];
        });
    };

        // The block to execute when a message is received from the server.
        // The data 'is' either UTF8-String (type: NSString) or binary (type: NSData)
    _websocket.didReceiveMessage = ^(KGWebSocket* webSocket, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ref log:[NSString stringWithFormat:@"RECEIVED MESSAGE: %@", data]];
        });
    };

        // The block to execute when an error occurs.
    _websocket.didReceiveError = ^(KGWebSocket* webSocket, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ref log:[NSString stringWithFormat:@"ERROR: %@", [error localizedFailureReason]]];
        });
    };

        // The block to execute when the connection is closed
    _websocket.didClose = ^(KGWebSocket* websocket, NSInteger code, NSString* reason, BOOL wasClean) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ref log:[@"CLOSED" stringByAppendingFormat:@"(%i): Reason: %@", code, reason]];
            [ref updateUIcomponents:NO];
        });
    };
}
```

### Error Handling

Error handling is performed using a `try...catch` block and the `e` exception identifier, local to the catch clause.

``` m
...
    }
    @catch (NSException *exception) {
        [self log:[exception reason]];
    }
...
```

Build the WebSocket Objective-C Demo
------------------------------------

The following steps show you have to build the WebSocket Objective-C Demo available at [kaazing.org](http://kaazing.org).

### Overview

In this procedure you will do the following:

1.  Set up your development environment using the Gateway and Xcode 4.4 or later.

2.  Review the components that will be used to create the Objective-C client.
3.  Create a new Xcode project.
4.  Add the **KAAZING Gateway Objective-C framework**.
5.  Add **CFNetwork.framework** to the project.
6.  Add the `-ObjC` value to the **Other Linker Flags** build setting.
7.  Build the interface for the client using **MainStoryboard.storyboard**.
8.  Add the actions for the buttons to the view controller header file **KGViewController.h**.
9.  Import the WebSocket header into the **KGViewController.m** implementation file.
10. Create the WebSocket factory and WebSocket.
11. Add event listeners to manage WebSocket connection events, incoming WebSocket messages, and any errors returned, and write event status to the log.
12. Modify the Send Message method for both text and binary messages.
13. Modify the Connect and Close methods for connecting and closing WebSocket connections.
14. Add a method to update the UI in response to the connection events.
15. Add methods for managing the WebSocket connection when the application is sent to the background or returns to the foreground.
16. Add the remaining methods to control the interface of the client, such as when the client loads and unloads on the device.
17. Build and run the client in the iPhone Simulator.

For information about the KAAZING Gateway Objective-C Client API, see [Objective-C Client API](../apidoc/client/ios/gateway/index.md).

**Notes:**
-   The code used in this procedure is taken from the Objective-C (iOS) demo located at [kaazing.org](http://kaazing.org).
-   This procedure assumes that you are familiar with Objective-C programming and are an advanced user of the [Xcode](https://developer.apple.com/xcode/) IDE for creating native iOS clients. If you are new to Objective-C and Xcode, see [Write Objective-C Code](http://developer.apple.com/library/ios/#referencelibrary/GettingStarted/RoadMapiOS/chapters/WriteObjective-CCode/WriteObjective-CCode/WriteObjective-CCode.html) and the tutorial [Your First iOS App](https://developer.apple.com/library/ios/#referencelibrary/GettingStarted/RoadMapiOS/chapters/RM_YourFirstApp_iOS/Articles/00_Introduction.html). An excellent video tutorial is Objective-C by [thenewboston.org](http://thenewboston.org/list.php?cat=33). A very brief overview of Objective-C is [Learn Objective-C](http://cocoadevcentral.com/d/learn_objectivec/) from Learn Cocoa.
-   This procedure assumes that you have the required iOS Developer Program credentials.
-   The Xcode project created in this procedure uses features available in Xcode 4.1 or later and iOS SDK 5.0 and later.

### Building the WebSocket Objective-C Demo

1.  Set up your development environment using the following:
    1.  Download and install [Apple Xcode 4.4](https://developer.apple.com/xcode/) or later (requires Mac OS X 10.7.4 or later). The Xcode bundle includes the iOS SDK.

        **Note:** Xcode 6 introduced major changes to Xcode and some of the following steps might not work as described in Xcode 6. Consult the Xcode 6 documentation for assistance with the steps.

2.  Review the components that will be used to create the Objective-C client. A quick review of these components will give you an overview of how the client is constructed.

    | Component                     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
    |-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
    | KGWebSocket.framework         | KAAZING Gateway Objective-C framework                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
    | CFNetwork.framework           | Core Foundation framework that provides a library of abstractions for network protocols. For more information on CFNetwork, see [Introduction to CFNetwork Programming Guide](https://developer.apple.com/library/mac/#documentation/Networking/Conceptual/CFNetwork/Introduction/Introduction.html).                                                                                                                                                                                                                                                               |
    | MainStoryboard.storyboard     | The storyboard for the user interface look and feel and the interactive controls.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
    | KGViewController.h            | The header file that contains the target-action mechanism: how the user interface elements send an action message to an object that knows how to perform the corresponding action method (defined in KGViewController.m). In this file, user interface objects and outlet connections (connections between user interface objects and custom controller objects) are defined for the user interface controls. For more information, see [Outlets](http://developer.apple.com/library/mac/#documentation/General/Conceptual/CocoaEncyclopedia/Outlets/Outlets.html). |
    | KGViewController.m            | The implementation file (sometimes called a source file) where the architecture of the client is defined, including how the client responds to different events.                                                                                                                                                                                                                                                                                                                                                                                                    |
    | KGWebSocket class             | Provides the API for creating and managing a WebSocket connection, as well as sending and receiving data on the connection.                                                                                                                                                                                                                                                                                                                                                                                                                                         |
    | KGWebSocketFactory class      | An instance of KGWebSocket is created using KGWebSocketFactory. This establishes a full-duplex connection to the target location.                                                                                                                                                                                                                                                                                                                                                                                                                                   |
    | WebSocket Listeners           | These are the methods used to handle WebSocket events such as: connection open, message received, error received, connection closed.                                                                                                                                                                                                                                                                                                                                                                                                                                |
    | WebSocket Send Message method | This method is used to send messages as text or binary.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |

3.  Launch Xcode.
4.  Create a new Xcode project.

    1.  Click **File**, then **New**, and then **Project**.
    2.  Under iOS, click **Application**, and click **Single View Application**. Click **Next**. The project options page appears.
    3.  Enter the name **WebSocketDemo** in **Product Name**, and the class prefix **KG** in **Class Prefix**. Xcode uses the product name you entered to name your project and the client, and the class prefix to name the classes and files it generates for you.
    4.  In **Company Identifier**, enter the name of your company.
    5.  In **Devices**, make sure that **iPhone** is selected.
    6.  Make sure that the **Use Storyboards** and **Use Automatic Reference Counting** options are selected and that the **Include Unit Tests** option is unselected.
    7.  Click **Next**.
    8.  Specify a location for your project (leave the **Source Control** option unselected) and then click **Create**. The new project is created along with the default files.

5.  Add the KAAZING Gateway Objective-C framework to the project.

    1.  Navigate to the location of the KAAZING Gateway Objective-C framework. The framework is located at [kaazing.org](http://kaazing.org).

    2.  Drag the **KGWebSocket.framework** file into the **Frameworks** folder in the Xcode project navigator.
    3.  In the **Choose options for adding these files** dialog that appears, enable the **Copy items into destination group’s folder** checkbox, select your project in **Add to targets**, and click **Finish**.

        Xcode adds the framework to the project navigator, updates the **Framework Search Paths** setting in **Build Settings** with the path to the framework, and updates the **Link Binary With Libraries** settings in **Build Phases** automatically.

    **Note:** You can also choose to add the **KGWebSocket.framework** file into your local `/Library/Frameworks/` folder or a network share before adding it to your project. This is a common practice for managing frameworks.

6.  Add CFNetwork.framework to the project. CFNetwork is a framework in the iOS Core Services framework that provides a library of abstractions for network protocols.

    1.  In the project navigator, select the target to which you want to add a library or framework. In this example, **WebSocketDemo**.
    2.  Click **Build Phases** at the top of the project editor.
    3.  Open the **Link Binary With Libraries** section.
    4.  Click the **Add (+)** button to add a library or framework.
    5.  Enter `CFNetwork.framework` in the search field, select **CFNetwork.framework** in the results, and click **Add**. The CFNetwork.framework is now listed in the Frameworks folder in the project navigator.

7.  Add the `-ObjC` value to the **Other Linker Flags** build setting because the KAAZING Gateway Objective-C API code you add links against an Objective-C static library that contains categories. You must add this value to prevent a runtime exception of **"selector not recognized"**. For more information, see [Building Objective-C static libraries with categories](http://developer.apple.com/library/mac/#qa/qa1490/_index.html).

    1.  In the project navigator, select the target to which you want to add a library or framework. In this example, **WebSocketDemo**.
    2.  Click the **Build Settings** tab and scroll down to the **Linking** section.
    3.  In **Other Linker Flags**, add the value `-ObjC`.

8.  Build the interface for the client using **MainStoryboard.storyboard** and the View Controller.

    1.  Click **MainStoryboard.storyboard** in the project navigator. A blank scene appears.
    2.  Expand **View Controller** in the editor area and click **View**.
    3.  Click the **Utility** view to display the [Utility area](http://developer.apple.com/library/ios/#recipes/xcode_help-general/AbouttheUtilityArea/AbouttheUtilityArea.html).
    4.  Show the Object Library, and choose **Controls** from the pop-up menu.
    5.  Drag the following controls into the scene, and give them the values listed in the following table. You might want to add a background color to the scene in order to display controls clearly.

        | Control    | Purpose                                                                                          | Value                              |
        |------------|--------------------------------------------------------------------------------------------------|------------------------------------|
        | Label      | URI text label                                                                                   | `URI:`                             |
        | Text Field | Field where users enter a WebSocket address                                                      | `ws://echo.websocket.org`          |
        | Button     | Connect button                                                                                   | `Connect`                          |
        | Text Field | Field where users enter a message                                                                | `Hello, WebSocket`                 |
        | Label      | Message text label                                                                               | `Message:`                         |
        | Button     | Send button                                                                                      | `Send`                             |
        | Button     | Close button                                                                                     | `Close`                            |
        | Text View  | Area where the connection state is displayed, and where sent and received messages are displayed | No value                           |
        | Button     | Clear button                                                                                     | `Clear`                            |
        | Switch     | Switch between text and binary messages                                                          | No value. Set **State** to **On**. |
        | Label      | Binary text label                                                                                | `Binary`                           |

    When you are finished, the scene should look like the following:

    ![](images/dev-ios-client-view.jpg)

    **Figure: Completed View Controller Scene**

9.  Add the actions for the buttons to the view controller header file. In our example, the file is named **KGViewController.h**.

    1.  Control-drag the UI controls into the `KGViewController` class in **KGViewController.h** to create actions and outlet connections (an outlet describes a connection between two objects). Configure the actions and outlet connections so that **KGViewController.h** appears as follows:

        ``` m
        #import <UIKit/UIKit.h>

        @interface KGViewController : UIViewController<UITextFieldDelegate>
        // Connection: Action
        // Type: id
        // Event: Touch Up Inside
        // Arguments: Sender
        - (IBAction)connectButton:(id)sender;
        - (IBAction)sendMessage:(id)sender;
        - (IBAction)closeButton:(id)sender;
        - (IBAction)clearLog:(id)sender;
        // These methods will be defined later
        - (void)applicationDidEnterBackground;
        - (void)applicationWillEnterForeground;

        // Connection: Outlet
        @property (weak, nonatomic) IBOutlet UITextField *uriTextField;
        @property (weak, nonatomic) IBOutlet UITextField *messageTextField;

        @property (weak, nonatomic) IBOutlet UIButton *closeButton;
        @property (weak, nonatomic) IBOutlet UIButton *connectButton;
        @property (weak, nonatomic) IBOutlet UIButton *sendButton;
        @property (weak, nonatomic) IBOutlet UITextView *textView;
        @property (weak, nonatomic) IBOutlet UISwitch *binarySwitch;

        @end
        ```

        When you Control-drag the UI controls in the `KGViewController`, the popover control appears:

        ![](images/dev-ios-popover-control.png)

        **Figure: The Xcode popover control**


        For action method declarations (`IBAction`), choose **Action** in the the **Connection** drop-down. For outlet connections (`IBOutlet`), choose **Outlet** in the **Connection** drop-down. This is a common Xcode procedure. If you are unfamiliar with this procedure, review the [Configuring the View](https://developer.apple.com/library/ios/#referencelibrary/GettingStarted/RoadMapiOS/chapters/RM_YourFirstApp_iOS/Articles/05_ConfiguringView.html) step in [Your First iOS App](https://developer.apple.com/library/ios/#referencelibrary/GettingStarted/RoadMapiOS/chapters/RM_YourFirstApp_iOS/Articles/00_Introduction.html).

        **Notes:**

        -   For all of the buttons, ensure that **Touch Up Inside** is selected in the **Sent Events** section of the **Connections Inspector**. Xcode will likely configure this automatically.
        -   While you can paste the above code into your header file, if you control-drag the UI elements into the code from the scene (press and hold the Control key while you drag the button to the implementation file in the assistant editor pane) and use the popover control to specify the outlet connections, you can ensure that you have all the settings correct.
        -   When you add the action methods, corresponding stub methods are added to the KGViewController.m implementation file automatically. You will update these methods in KGViewController.m with the KAAZING Gateway Objective-C API in later steps.
        -   Some iOS clients define the interface in the implementation file instead of the header file. The client in this procedure defines the interface in the header file and the implementation methods in the implementation file.

10. Import the WebSocket header into the **KGViewController.m** implementation file:

    ``` m
    #import "KGViewController.h"
    #import <KGWebSocket/WebSocket.h>
    ```

    The remaining code for this client is contained withIn the implementation for the `KGViewController` class:

    ``` m
    @implementation KGViewController {
    ...
    @end
    ```

11. Declare variables for the WebSocket and WebSocket Factory objects:

    ``` m
    @implementation KGViewController {
        KGWebSocket           *_websocket; // WebSocket class
        KGWebSocketFactory    *_factory;   // WebSocketFactory class
        BOOL                  _reconnect;  // Boolean variable for reconnecting
    }
    ```

12. Generate the methods for the interface properties you defined in **KGViewController.h**:

    ``` m
    @synthesize uriTextField;
    @synthesize messageTextField;
    @synthesize connectButton;
    @synthesize closeButton;
    @synthesize sendButton;
    @synthesize textView;
    @synthesize binarySwitch;
    ```

13. Add the `createAndEstablishWebSocketConnection` method to create the WebSocket factory and WebSocket:

    ``` m
    - (void) createAndEstablishWebSocketConnection {
        @try {
            NSString *location = self.uriTextField.text;
            [self log:[@"CONNECT: " stringByAppendingString:location]];

            // Create KGWebSocketFactory
            _factory = [KGWebSocketFactory createFactory];

            // Create KGWebSocket from the KGWebSocketFactory
            NSURL *url = [NSURL URLWithString:location];
            _websocket = [_factory createWebSocket:url];

            /*
            Add KGRevalidateExtension's name as an enabled extension to the
            KGWebSocket created earlier.
            The extension will be negotiated during handshake.
            */
            NSString *extensionName = [[KGRevalidateExtension revalidateExtension] name];
            [_websocket setEnabledExtensions:[NSArray arrayWithObjects:extensionName, nil]];

            /*
            Set up WebSocket listeners using block based approach
            The application developer can use a delegate based approach as well.
            */
            [self setupWebSocketListeners];
            // Connect to the Gateway over WebSocket
            [_websocket connect];
        }
        @catch (NSException *exception) {
            [self log:[exception reason]];
        }
    }
    ```

14. Add the `setupWebSocketListeners` method to manage WebSocket connection events, incoming WebSocket messages, and any errors returned, and write event status to the log:

    ``` m
    - (void) setupWebSocketListeners {

        KGViewController* ref = self;

        /*
        Attach a block to execute when WebSocket connection is established.
        This indicates that the connection is ready to send and receive data.
        */
        _websocket.didOpen = ^(KGWebSocket* webSocket) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ref log:@"CONNECTED"];
                [ref updateUIcomponents:YES];
            });
        };

        /*  
        The block to execute when a message is received from the Gateway.
        The data is either UTF8-String (type: NSString) or binary (type: NSData)
        */
        _websocket.didReceiveMessage = ^(KGWebSocket* webSocket, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ref log:[NSString stringWithFormat:@"MESSAGE: %@", data]];
            });
        };

        // The block to execute when an error occurs.
        _websocket.didReceiveError = ^(KGWebSocket* webSocket, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ref log:[NSString stringWithFormat:@"MESSAGE: %@",
                         [error localizedFailureReason]]];
            });
        };

        // The block to execute when the connection is closed
        _websocket.didClose = ^(KGWebSocket* websocket, NSInteger code, NSString* reason,
                                BOOL wasClean) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ref log:[@"CLOSED" stringByAppendingFormat:@"(%i)", code]];
                [ref updateUIcomponents:NO];
            });
        };
    }
    ```

15. Binary messages are received as [NSData](http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/Reference/Reference.html). For more information, see [Introduction to Binary Data Programming Guide for Cocoa](http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/BinaryData/BinaryData.html) from Apple. Text messages are received as [NSString](http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/Reference/NSString.html).
16. Modify the `sendMessage:` method for both text and binary messages. The `sendMessage` method was generated automatically when you added the action to the **Send** button, but the method needs to be modified to call the WebSocket object and use its send: method for transmitting data to the Gateway over the WebSocket connection:

    ``` m
    - (IBAction)sendMessage:(id)sender {
        @try {
            if ([binarySwitch isOn]) {                     // Send binary messages
                NSData *data = [self.messageTextField.text
                                dataUsingEncoding:NSUTF8StringEncoding];
                [self log:[NSString stringWithFormat:@"SEND: %@", data]];

                // Use the send: method from the KGWebSocket class
                [_websocket send:data];
            }
            else {
                NSString *msg = self.messageTextField.text;    // Send text messages
                [self log:[@"SEND: " stringByAppendingString:msg]];

                [_websocket send:msg];
            }
        }
        @catch (NSException *exception) {
            [self log:[exception reason]];
        }
    }
    ```

    Binary messages are sent using [NSData](http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/Reference/Reference.html).

17. Modify the `connectButton:` method. The `connectButton:` method was generated automatically when you added the action to the **Connect** button, but the method needs to be modified to call the method for creating the WebSocket connection and updating the UI:

    ``` m
    - (IBAction)connectButton:(id)sender {
        // Call the method for creating the WebSocket connect
        [self createAndEstablishWebSocketConnection];
        // Disable the URI field
        self.uriTextField.enabled = NO;
        // Change the URI field’s background color
        self.uriTextField.backgroundColor = [UIColor lightGrayColor];
    }
    ```

18. Modify the `closeButton:` method to close the WebSocket connection and catch any exceptions:

    ``` m
    - (IBAction)closeButton:(id)sender {
        [self log:@"CLOSE"];
        @try {
            [_websocket close];
        }
        @catch (NSException *exception) {
            [self log:[exception reason]];
        }
    }
    ```

19. Add the log `log:` that is used by the other event methods:

    ``` m
    - (void) log:(NSString *)msg {
        NSString *oldText = [textView text];
        NSString *msgWithNewline = [msg stringByAppendingString:@"\n"];
        NSString *newText = [oldText stringByAppendingString:msgWithNewline];
        [textView setText:newText];
        [textView flashScrollIndicators];
    }
    ```

20. Modify the `clearLog:` method to clear the text area:

    ``` m
    - (IBAction)clearLog:(id)sender {
        [textView setText:@""];
    }
    ```

21. Add the `updateUIcomponents:` method to update the UI in response to the connection event:

    ``` m
    - (void) updateUIcomponents:(BOOL)isConnected {
        self.uriTextField.enabled = !isConnected;
        self.uriTextField.backgroundColor = isConnected?[UIColor lightGrayColor]:
            [UIColor whiteColor];
        self.messageTextField.enabled = isConnected;
        self.messageTextField.backgroundColor = isConnected? [UIColor whiteColor]:
            [UIColor lightGrayColor];
        self.sendButton.enabled = isConnected;
        self.connectButton.enabled = !isConnected;
        self.closeButton.enabled = isConnected;
    }
    ```

22. Add the `applicationDidEnterBackground` and `applicationWillEnterForeground` methods for managing the WebSocket connection when the application is sent to the background or returns to the foreground:

    ``` m
    - (void)applicationDidEnterBackground {
        // when application moves to background,
        // close the open websocket connection, set reconnect to true
        if (_websocket != nil && [_websocket readyState] == KGReadyState_OPEN) {
            [_websocket close];
            _reconnect = YES;
        }
        else {
            _reconnect = NO;
        }
    }

    - (void)applicationWillEnterForeground {
        //if reconnect equals to true, reconnect the websocket
        if (_websocket != nil && [_websocket readyState] == KGReadyState_OPEN) {
            [self updateUIcomponents:YES];
        }
        else {
            [self updateUIcomponents:NO];
            if (_reconnect) {
                //connection was open when application enter background, reconnect
                [self createAndEstablishWebSocketConnection];

            }
        }
    }
    ```

    The methods use the `readyState` property to determine the current state of the connection. `readyState` can have the values `0` (CONNECTING), `1` (OPEN), `2` (CLOSING), `3` (CLOSED). These are the ready state codes defined in the [WebSocket API](http://dev.w3.org/html5/websockets/#dom-websocket-readystate).

    The remaining methods are used to control the interface of the client and are not WebSocket-related.

23. Add the remaining methods to control the interface of the client.
    1.  Add the `textFieldShouldReturn:` method to set the text field as first responder and keep this status to receive keyboard input:

        ``` m
        - (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
            if (theTextField == self.messageTextField || theTextField == self.uriTextField) {
                [theTextField resignFirstResponder];
            }
            return YES;
        }
        ```

    2.  Modify the `viewDidLoad` method to set up the view:

        ``` m
        - (void)viewDidLoad {
            [super viewDidLoad];
            // Do any additional setup after loading the view, typically from a nib.
        }
        ```

        **Note:** `viewDidload` is deprecated in iOS 6.0, as are some of the other methods in this demo. The demo is intended to work on iOS 5.1+ and iOS 6.0+, so these deprecated methods are used. If you are developing for iOS 6.0+ only, review Deprecated UIViewController Methods from Apple.

    3.  Add a viewDidUnload method for when the client unloads after the viewDidLoad method that is automatically added by Xcode.

        ``` m
        - (void)viewDidUnload
        {
            [self setUriTextField:nil];
            [self setMessageTextField:nil];
            [self setSendButton:nil];
            [self setConnectButton:nil];
            [self setCloseButton:nil];
            [self setTextView:nil];
            [self setBinarySwitch:nil];
            [super viewDidUnload];
            // Release any retained subviews of the main view.
        }
        ```

    4.  Add a method for managing the UI orientation:

        ``` m
        - (BOOL)shouldAutorotateToInterfaceOrientation:
                (UIInterfaceOrientation)interfaceOrientation
        {
            return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        }
        ```

24. Ensure that the `KGViewController` implementation class ends with its `@end` statement.
25. Start the Gateway as described in **How do I start and stop the Gateway?** in [Setting Up KAAZING Gateway](https://github.com/kaazing/gateway/blob/develop/doc/about/setup-guide.md).
26. Build and run the client in the iPhone Simulator.
    1.  In the **Scheme** menu, select **iPhone 5.1 Simulator** or **iPhone 6.1 Simulator**.
    2.  Click **Run**.

        The iPhone Simulator displays the client.

        ![](images/f-html5-objc-simulator.png)

        **Figure: Your WebSocket Demo client on the iPhone Simulator**


    3.  Click **Connect**. The client connects to the Echo service hosted by the Gateway over WebSocket. The log displays:

        ```
        CONNECT: ws://echo.websocket.org
        CONNECTED
        ```

    4.  Click **Send**. The text message is sent to the Gateway as binary. The log displays the sent binary message and the Echo service response from the Gateway: `SEND: <48656c6c 6f2c2057 6562536f 636b6574 21> MESSAGE: <48656c6c 6f2c2057 6562536f 636b6574 21>`
    5.  Switch the **Binary** switch to **OFF** and click **Send**. The log displays the sent text message and the Echo service response from the Gateway: `SEND: Hello, WebSocket! MESSAGE: Hello, WebSocket!`
    6.  Click **Close** to close the WebSocket connection and end the session.

Convert Your Objective-C (iOS) Client to a 64-Bit Runtime Environment
---------------------------------------------------------------------

iPhone 5s, iPad Air and iPad mini (2nd generation) both run on a completely new processor architecture: arm64. arm64 is the standard, 64-Bit architecture in Xcode 5.0.1. You can use Xcode 5.0.1 to update your Objective-C (iOS) client to support arm64. For more information, see [Converting Your App to a 64-Bit Binary](https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaTouch64BitGuide/ConvertingYourAppto64-Bit/ConvertingYourAppto64-Bit.html).

To update your Objective-C (iOS) client to support arm64:

1.  Install Xcode 5.0.1 or later from the [Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).
2.  Open your Objective-C (iOS) client project. Xcode prompts you to modernize your project. Modernizing the project adds new warnings and errors that are important when compiling your app for 64-bit.
3.  Update your project settings to support iOS 5.1.1 or later. You cannot build a 64-bit project if it targets an iOS version earlier than iOS 5.1. Change the **Architectures** build setting in your project to **Standard Architectures (including 64-bit)**. Set the **Deployment Target** to **7.1**. For more information, see [Converting Your App to a 64-Bit Binary](https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaTouch64BitGuide/ConvertingYourAppto64-Bit/ConvertingYourAppto64-Bit.html).

Next Step
---------

[Secure Your Objective-C Client](p_dev_objc_secure.md)
