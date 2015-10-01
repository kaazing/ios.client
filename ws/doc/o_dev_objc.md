Build Objective-C (iOS) WebSocket Clients
=========================================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

This checklist provides the steps necessary to create an Objective-C client using the KAAZING Gateway [Objective-C Client API](http://developer.kaazing.com/documentation/5.0/apidoc/client/ios/gateway/index.html):

| \# | Step                                                                                                                                    | Topic or Reference                                                                    |
|:---|:----------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------|
| 1  | Learn how to use the Objective-C Client API.                                                                                            | [Use the Objective-C WebSocket Client API](#use-the-objective-c-websocket-client-api) |
| 2  | Learn how to authenticate your client by implementing a challenge handler to respond to authentication challenges from KAAZING Gateway. | [Secure Your Objective-C Client](#secure-your-objective-c-client)                     |
| 3  | Learn how to gather data on KAAZING Gateway Objective-C client                                                                          | [Display Logs for the Objective-C Client](#display-logs-for-the-objective-c-client)   |
| 4  | Troubleshoot the most common issues that occur when using Objective-C clients.                                                          | [Troubleshoot Your Objective-C Client](#troubleshoot-your-objective-c-client)         |


Introduction
------------

In this how-to, you will learn how to use the KAAZING Gateway Objective-C client library to enable your iOS client to communicate with any back-end service over WebSocket via the KAAZING Gateway or any RFC-6455 WebSocket endpoint.

This document contains information for an Objective-C developer who wants to add Objective-C to an iOS client to enable communication with a back-end server through KAAZING Gateway or any RFC-6455 WebSocket endpoint.

For more information on the Objective-C API, see [Objective-C Client API](http://developer.kaazing.com/documentation/5.0/apidoc/client/ios/gateway/index.html).

WebSocket and Objective-C
-------------------------

KAAZING Gateway provides support for the HTML5 Communication protocol libraries in Objective-C. Using the Objective-C Client API, you can enable the HTML5 WebSocket protocols in new or existing Objective-C applications. For example, you can create an Objective-C client to get streaming financial or news data from a back-end server using WebSocket. The following figure shows a high-level overview of the architecture:

![](images/f-html5-objc-client-web.png)

**Figure: Enable Communication Between Your iOS Client and a Back-end Server over WebSocket**


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

Components and Tools
---------------------------------------------------------------

Before you get started, review the components and tools used to build the WebSocket Objective-C (iOS) client in this procedure.

| Component or Tool                                          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Location                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|:-----------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| KAAZING Gateway or any RFC-6455 WebSocket endpoint.        | You can use the KAAZING Gateway or any RFC-6455 WebSocket endpoint that hosts an Echo service, such as [www.websocket.org](http://www.websocket.org).                                                                                                                                                                                                                                                                                                                                                                                                               | The KAAZING Gateway is available at [kaazing.org](http://kaazing.org).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| KAAZING Gateway WebSocket Objective-C (iOS) Client library | The Objective-C (iOS) file KGWebSocket.dmg.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | The library is available at [kaazing.org](http://kaazing.org).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| KAAZING Gateway WebSocket Objective-C (iOS) Demo           | A WebSocket Objective-C (iOS) demo that connects to the Gateway or an RFC-6455 WebSocket endpoint, sends an Echo request, and receives and displays an Echo response.                                                                                                                                                                                                                                                                                                                                                                                               | The demo is available at [kaazing.org](http://kaazing.org).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| KGWebSocket.framework                                      | KAAZING Gateway Objective-C framework                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Contained in KGWebSocket.dmg.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| CFNetwork.framework                                        | Core Foundation framework that provides a library of abstractions for network protocols.                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | For more information on CFNetwork, see [Introduction to CFNetwork Programming Guide](https://developer.apple.com/library/mac/#documentation/Networking/Conceptual/CFNetwork/Introduction/Introduction.html).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| MainStoryboard.storyboard                                  | The storyboard for the user interface look and feel and the interactive controls.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `gateway.client.ios.demo/src/main/Xcode/html5.client.ios.demo/en.lproj/MainStoryboard.storyboard`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| KGViewController.h                                         | The header file that contains the target-action mechanism: how the user interface elements send an action message to an object that knows how to perform the corresponding action method (defined in KGViewController.m). In this file, user interface objects and outlet connections (connections between user interface objects and custom controller objects) are defined for the user interface controls. For more information, see [Outlets](http://developer.apple.com/library/mac/#documentation/General/Conceptual/CocoaEncyclopedia/Outlets/Outlets.html). | `gateway.client.ios.demo/src/main/Xcode/html5.client.ios.demo/KGViewController.h`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| KGViewController.m                                         | The implementation file (sometimes called a source file) where the architecture of the client is defined, including how the client responds to different events.                                                                                                                                                                                                                                                                                                                                                                                                    | `gateway.client.ios.demo/src/main/Xcode/html5.client.ios.demo/KGViewController.m`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Development Tool                                           | Xcode 4.4 or later from Apple. The examples in this topic use Xcode 4 and iOS 5.1 SDK.                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | https://developer.apple.com/xcode/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Secure Networking of TLS/SSL                               | Objective-C (iOS) is run on an iOS device that manages TLS/SSL connections, requesting TLS/SSL certificates from the Gateway or RFC-6455 WebSocket endpoint.                                                                                                                                                                                                                                                                                                                                                                                                        | For more information on securing network connections between the Gateway and an0 Objective-C (iOS) client, see [Secure Network Traffic with the Gateway](../security/o_tls.md "Kaazing Developer Network"). For information on API interfaces needed to configure TLS/SSL trust programmatically for testing, see [Certificate, Key, and Trust Services Reference](https://developer.apple.com/library/ios/documentation/Security/Reference/certifkeytrustservices/index.html#//apple_ref/doc/uid/TP30000157) and [Certificate, Key, and Trust Services Programming Guide](https://developer.apple.com/library/ios/documentation/Security/Conceptual/CertKeyTrustProgGuide/01introduction/introduction.html#//apple_ref/doc/uid/TP40001358). |
| Authentication with Challenge Handlers                     | Authenticating your Objective-C (iOS) client involves implementing a challenge handler to respond to authentication challenges from the Gateway. If your challenge handler is responsible for obtaining user credentials, then you will also need to implement a login handler.                                                                                                                                                                                                                                                                                     | For examples, see the `KGDemoLoginHandler` interface and implementation in KGViewController.m.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

Taking a Look at the Objective-C Client Demo
-----------------------------------------------------------------------

Before you start, take a look at a demo built using the Objective-C Client API:

1.  Fork or download the KAAZING Gateway Objective-C Client Demo from [kaazing.org](http://kaazing.org).
2.  You can build and run the demo by building the demo project using Xcode. Open the project file **html5.client.ios.demo.xcodeproj** in Xcode, and then run the application in the iPhone simulator. The demo application shows how use the Objective-C API to communicate with the Echo service running on [www.websocket.org](http://www.websocket.org).

Primary WebSocket Objective-C API Features
------------------------------------------

The examples in this section will demonstrate how to open and close a WebSocket connect, send and receive message, and error handling.

### Connecting and Closing Connections

The following example demonstrates how to open and close a connection. A best practice when connecting is to use a `try...catch` block. Note that the WebSocket connection is also closed when the app enters the background and is set to reconnect when the app enters the foreground.

```
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

```
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

```
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

For information about the KAAZING Gateway Objective-C Client API, see [Objective-C Client API](http://developer.kaazing.com/documentation/5.0/apidoc/client/ios/gateway/index.html).

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

        ```
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

    ```
    #import "KGViewController.h"
    #import <KGWebSocket/WebSocket.h>
    ```

    The remaining code for this client is contained withIn the implementation for the `KGViewController` class:

    ```
    @implementation KGViewController {
    ...
    @end
    ```

11. Declare variables for the WebSocket and WebSocket Factory objects:

    ```
    @implementation KGViewController {
        KGWebSocket           *_websocket; // WebSocket class
        KGWebSocketFactory    *_factory;   // WebSocketFactory class
        BOOL                  _reconnect;  // Boolean variable for reconnecting
    }
    ```

12. Generate the methods for the interface properties you defined in **KGViewController.h**:

    ```
    @synthesize uriTextField;
    @synthesize messageTextField;
    @synthesize connectButton;
    @synthesize closeButton;
    @synthesize sendButton;
    @synthesize textView;
    @synthesize binarySwitch;
    ```

13. Add the `createAndEstablishWebSocketConnection` method to create the WebSocket factory and WebSocket:

    ```
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

    ```
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

    ```
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

    ```
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

    ```
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

    ```
    - (void) log:(NSString *)msg {
        NSString *oldText = [textView text];
        NSString *msgWithNewline = [msg stringByAppendingString:@"\n"];
        NSString *newText = [oldText stringByAppendingString:msgWithNewline];
        [textView setText:newText];
        [textView flashScrollIndicators];
    }
    ```

20. Modify the `clearLog:` method to clear the text area:

    ```
    - (IBAction)clearLog:(id)sender {
        [textView setText:@""];
    }
    ```

21. Add the `updateUIcomponents:` method to update the UI in response to the connection event:

    ```
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

    ```
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

        ```
        - (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
            if (theTextField == self.messageTextField || theTextField == self.uriTextField) {
                [theTextField resignFirstResponder];
            }
            return YES;
        }
        ```

    2.  Modify the `viewDidLoad` method to set up the view:

        ```
        - (void)viewDidLoad {
            [super viewDidLoad];
            // Do any additional setup after loading the view, typically from a nib.
        }
        ```

        **Note:** `viewDidload` is deprecated in iOS 6.0, as are some of the other methods in this demo. The demo is intended to work on iOS 5.1+ and iOS 6.0+, so these deprecated methods are used. If you are developing for iOS 6.0+ only, review Deprecated UIViewController Methods from Apple.

    3.  Add a viewDidUnload method for when the client unloads after the viewDidLoad method that is automatically added by Xcode.

        ```
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

        ```
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


Secure Your Objective-C Client
==============================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

In this procedure, you will learn how to program your Objective-C client built using the KAAZING Gateway Objective-C libraries to authenticate with the KAAZING Gateway. Authenticating your client involves implementing a challenge handler to respond to authentication challenges from the Gateway. If your challenge handler is responsible for obtaining user credentials, then you will also need to implement a login handler.

For information about the KAAZING Gateway Objective-C Client API, see [Objective-C Client API](http://developer.kaazing.com/documentation/5.0/apidoc/client/ios/gateway/index.html).

**Notes:**

-   Before you add security to your clients, follow the steps in [Configure Authentication and Authorization](../security/o_auth_configure.md) to set up security on KAAZING Gateway for your client. The authentication and authorization methods configured on the Gateway influence your client security implementation. The examples is this topic provide the most common client implementations.
-   For information on secure network connections between clients and the Gateway, see [Secure Network Traffic with the Gateway](../security/o_tls.md).

Creating a Basic Challenge Handler
----------------------------------

A challenge handler is a constructor used in a client to respond to authentication challenges from the Gateway when the client attempts to access a protected resource. Each of the resources protected by the Gateway can be configured with a different authentication scheme (for example, Basic, Application Basic, Negotiate, or Application Token), and your client requires a challenge handler for each of the schemes that it will encounter or a single challenge handler that will respond to all challenges.

For information about each authentication scheme type, see [Configure the HTTP Challenge Scheme](https://github.com/kaazing/gateway/blob/develop/doc/security/p_authentication_config_http_challenge_scheme.md).

Clients with a single challenge handling strategy for all 401 challenges can simply set a specific challenge handler as the default using `KGBasicChallengeHandler`. The following is an example of how to implement a single challenge handler for all challenges:

`KGBasicChallengeHandler* challengeHandler = [KGBasicChallengeHandler create];`

The preceding example uses static credentials, but you will want to create a login handler to obtain individual user credentials. Here is an example using a login popup that responds when users click a **Connect** button, obtains user credentials, and then responds to the challenge from the Gateway:

```
#import "KGViewController.h"
#import <KGWebSocket/WebSocket.h>

//LoginHandler API
@interface KGDemoLoginHandler : KGLoginHandler
@end

@implementation KGDemoLoginHandler {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    NSString    *username;
    NSString    *password;
    int         _buttonIndex;
    dispatch_semaphore_t loginSemaphore;
}

-(void)dealloc {
    usernameTextField = nil;
    passwordTextField = nil;
    username = nil;
    password = nil;
}

- (id)init {
    self = [super init];
    return self;
}


-(NSURLCredential*) credentials {
    _buttonIndex = -1;
    loginSemaphore = dispatch_semaphore_create(0);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self popupLogin];
    });

    /*
    dispatch_semaphore_wait call will decrement the resource count.
    Since the resulting value is less than zero, this call waits in
    for a signal to occur before returning.
    dispatch_semaphore_signal is called when OK or Cancel button
    is clicked
    */
    dispatch_semaphore_wait(loginSemaphore, DISPATCH_TIME_FOREVER);

    // Release the reference of semaphore to free up the memory
    dispatch_release(loginSemaphore);
    // Clicked the Submit button
    if (_buttonIndex != 0)
    {
        return [[NSURLCredential alloc] initWithUser:username password:password
                persistence:NSURLCredentialPersistenceNone];
    } else {
        return nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    username = usernameTextField.text;
    password = passwordTextField.text;
    _buttonIndex = buttonIndex;
    dispatch_semaphore_signal(loginSemaphore);
}

- (void) popupLogin {
    _buttonIndex = -1;
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Please Login:"
        message:@"\n \n \n" delegate:self cancelButtonTitle:@"Cancel"
        otherButtonTitles:@"OK", nil];

    // Adds a username Field
    usernameTextField = [[UITextField alloc]
        initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        usernameTextField.placeholder = @"Username";
    [usernameTextField becomeFirstResponder];
    [usernameTextField setBackgroundColor:[UIColor whiteColor]];
    [usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [usernameTextField setText:@"joe"];
    [alertview addSubview:usernameTextField];

    // Adds a password Field
    passwordTextField = [[UITextField alloc]
        initWithFrame:CGRectMake(12.0, 80.0, 260.0, 25.0)];
        passwordTextField.placeholder = @"Password";
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [passwordTextField setBackgroundColor:[UIColor whiteColor]];
    [passwordTextField setText:@"welcome"];
    [alertview addSubview:passwordTextField];

    // Show alert on screen.
    [alertview show];
}
@end

@implementation KGViewController {

    KGWebSocket           *_websocket;
    KGWebSocketFactory    *_factory;
    BOOL                  _reconnect;

}
.
.
.
#pragma mark<Private Methods>

- (KGChallengeHandler *) createBasicChallengeHandler {
    KGLoginHandler* loginHandler = [[KGDemoLoginHandler alloc] init];
    KGBasicChallengeHandler* challengeHandler = [KGBasicChallengeHandler create];
    [challengeHandler setLoginHandler:loginHandler];
    return challengeHandler;
}
```

### Managing Log In Attempts

When it is not possible for the KAAZING Gateway client to create a challenge response, the client must return `nil` to the Gateway to stop the Gateway from continuing to issue authentication challenges.

The following example demonstrates how to stop the Gateway from issuing further challenges (look for instances of `retry` and `nil`).

```
//LoginHandler API:
@interface KGDemoLoginHandler : KGLoginHandler
- (int)retry;    // wrong username/password counter
- (void)setRetry:(int)newValue;

@end

@implementation KGDemoLoginHandler {
  UITextField *usernameTextField;
  UITextField *passwordTextField;
  NSString    *username;
  NSString    *password;
  int         _buttonIndex;
  dispatch_semaphore_t loginSemaphore;
  int        _retry;
}

-(void)dealloc {
  usernameTextField = nil;
  passwordTextField = nil;
  username = nil;
  password = nil;
}

- (id)init {
  self = [super init];
  [self setRetry: 0];
  return self;
}

-(NSURLCredential*) credentials {
  if (_retry++ >= 2) {
    return nil;      // abort authentication process if reaches max retries (set to 2 in this sample)
  }
  _buttonIndex = -1;
  loginSemaphore = dispatch_semaphore_create(0);

  dispatch_async(dispatch_get_main_queue(), ^{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
      [self popupLogin_70]; // new UIAlertView code in iOS7
    } else {
      [self popupLogin];
    }
  });

  // dispatch_semaphore_wait call will decrement the resource count.
  // Since the resulting value is less than zero, this call waits in
  // for a signal to occur before returning.
  // dispatch_semaphore_signal is called when OK or Cancel button
  // is clicked
  dispatch_semaphore_wait(loginSemaphore, DISPATCH_TIME_FOREVER);

  // Release the reference of semaphore to free up the memory
  dispatch_release(loginSemaphore);
  // Clicked the Submit button
  if (_buttonIndex != 0)
  {
    return [[NSURLCredential alloc]
      initWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
  } else {
    return nil;    // user click cancel button to abort authentication process
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  username = usernameTextField.text;
  password = passwordTextField.text;
  _buttonIndex = buttonIndex;
  dispatch_semaphore_signal(loginSemaphore);
}

- (void) popupLogin {
  _buttonIndex = -1;
  UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Please Login:" message:@"\n \n \n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
  // Adds a username Field
  usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; usernameTextField.placeholder = @"Username";
  [usernameTextField becomeFirstResponder];
  [usernameTextField setBackgroundColor:[UIColor whiteColor]];
  [usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [usernameTextField setText:@"joe"];
  [alertview addSubview:usernameTextField];
  // Adds a password Field
  passwordTextField = [[UITextField alloc]
    initWithFrame:CGRectMake(12.0, 80.0, 260.0, 25.0)]; passwordTextField.placeholder = @"Password";
  [passwordTextField setSecureTextEntry:YES];
  [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [passwordTextField setBackgroundColor:[UIColor whiteColor]];
  [passwordTextField setText:@"welcome"];
  [alertview addSubview:passwordTextField];

  // Show alert on screen.

  [alertview show];
}

- (void) popupLogin_70 {
  _buttonIndex = -1;
  UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Please Login:" message:@"\n \n \n"
    delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
  alertview.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
  usernameTextField = [alertview textFieldAtIndex:0];
  passwordTextField = [alertview textFieldAtIndex:1];
  [alertview show];
}
- (int)retry {
  return _retry;
}

- (void)setRetry:(int)newValue {
  _retry = newValue;
}

@end

@interface KGViewController ()

@end

@implementation KGViewController {

  KGWebSocket           *_websocket;
  KGWebSocketFactory    *_factory;
  BOOL                  _reconnect;
  KGDemoLoginHandler    *_loginHandler;
}
...
#pragma mark<Private Methods>
- (KGChallengeHandler *) createBasicChallengeHandler {
  _loginHandler = [[KGDemoLoginHandler alloc] init];
  KGBasicChallengeHandler* challengeHandler = [KGBasicChallengeHandler create];
  [challengeHandler setLoginHandler:_loginHandler];
  return challengeHandler;
}
...
// Attach a block to execute when WebSocket connection is established.
// This indicates that the connection is ready to send and receive data.
id loginHandler = _loginHandler;    // use a local variable to avoid strong reference
_websocket.didOpen = ^(KGWebSocket* webSocket) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [ref log:@"CONNECTED"];
    [loginHandler setRetry:0];  // reset retry counter
    [ref updateUIcomponents:YES];
  });
};
...
// The block to execute when the connection is closed
_websocket.didClose = ^(KGWebSocket* websocket, NSInteger code, NSString* reason, BOOL wasClean) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [ref log:[@"CLOSED" stringByAppendingFormat:@"(%i): Reason: %@", code, reason]];
    [loginHandler setRetry:0];  // reset retry counter
    [ref updateUIcomponents:NO];
  });
};
...
@end
```

**Note:** This example is taken from the out of the box Objective-C demo that is included in the bundle with the Gateway. The demo is located in `GATEWAY_HOME/demo/ios`.


Display Logs for the Objective-C Client
=======================================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

In this procedure, you will learn how to gather data on your KAAZING Gateway Objective-C client.

To Display Logs for the Objective-C Client
------------------------------------------------------------------------

1.  Build your Objective-C client, as described in [Build Objective-C (iOS) WebSocket Clients](o_dev_objc.md).
2.  Add the following line into one of the existing functions, such as `viewDidLoad()`:

    `KGTracerDebug = YES;`

    For example:

    ```
    - (void)viewDidLoad {
      [super viewDidLoad];
      KGTracerDebug = YES;
    }
    ```

3.  Build your Xcode project, run the Objective-C client in the Xcode Simulator, and perform some actions for the Objective-C client to log.

    The output is displayed in the Xcode Target Output area.

Notes
-----

-   If you run the Objective-C client on an iOS device, the logging output is also displayed in **Console** for the device in Xcode Organizer. In Xcode, click **Window**, click **Organizer**, locate the iOS device in **DEVICES**, and click **Console**.
-   See [KGTracer](http://developer.kaazing.com/documentation/5.0/apidoc/client/ios/gateway/index.html) for more information.


Troubleshoot Your Objective-C Client
====================================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

This topic contains descriptions of common errors that might occur when using the Objective-C Client API and provides steps on how to prevent these errors.

What Problem Are You Having?
----------------------------

-   [Lexical or Preprocessor Issue: KGWebSocket not found](#lexical-or-preprocessor-issue-kgwebsocket-not-found)
-   [Apple Mach-O Linker (Id) Error](#apple-mach-o-linker-id-error)
-   [Error: Selector Not Recognized or NSInvalidArgumentException](#error-selector-not-recognized-or-nsinvalidargumentexception)

Lexical or Preprocessor Issue: KGWebSocket not found
----------------------------------------------------

**Cause:** This error occurs because Xcode cannot locate the KGWebSocket.framework file that references a header file.

**Solution:** To resolve this error, correct the **Framework Search Paths** setting by performing the following steps:

1.  Navigate to the location of the KAAZING Gateway Objective-C framework:

    The Objective-C framework is available on [kaazing.org](http://kaazing.org).</span>

2.  Drag the **KGWebSocket.framework** file from the mounted volume into the **Frameworks** folder in the Xcode project navigator.
3.  In the **Choose options for adding these files** dialog that appears, enable the **Copy items into destination group’s folder** checkbox, select your project in **Add to targets**, and click **Finish**.

    Xcode adds the framework to the project navigator, updates the **Framework Search Paths** setting in **Build Settings** with the path to the framework, and updates the **Link Binary With Libraries** settings in **Build Phases** automatically.

Apple Mach-O Linker (Id) Error
------------------------------

**Cause:** This error will refer to "undefined symbols" beginning with `_CFHTTP`, for example `_CFHTTPMessageAddAuthentication`. The error occurs because the Xcode project is missing the CFNetwork.framework file. Clients built using the KAAZING Gateway Objective-C library also require the CFNetwork.framework.

**Solution:** To resolve this error, add CFNetwork.framework by performing the following steps:

1.  Click **Build Phases** at the top of the project editor.
2.  Open the **Link Binary With Libraries** section.
3.  Click the **Add (+)** button to add a library or framework.
4.  Enter `CFNetwork.framework` in the search field. **CFNetwork.framework** is displayed automatically.

    If you do not see **CFNetwork.framework**, then you might not have iOS SDK 5.1 or later installed. You can install the SDK as part of the Xcode bundle.

5.  Select **CFNetwork.framework** and click **Add**. CFNetwork.framework is added to the Xcode project and appears in the Xcode project navigator. You can drag CFNetwork.framework into the **Frameworks** folder.

Error: Selector Not Recognized or NSInvalidArgumentException
------------------------------------------------------------

**Cause:** These errors occur because the Xcode project is linking against an Objective-C static library that contains categories and the `-ObjC` value for the **Other Linker Flags** build setting is not configured. Basically, the error occurs when a library extends one of the built-in classes using a category. An example of the Selector Not Recognized error:

`[\_\_NSCFConstantString indexOf:]: unrecognized selector sent to instance 0x...`

Objective-C does not define linker symbols for each function (or method, in Objective-C). Linker symbols are only generated for each class. If you extend a pre-existing class with categories, the linker does not know to associate the object code of the core class implementation and the category implementation. This prevents objects created in the resulting application from responding to a selector that is defined in the category. The `-ObjC` flag causes the linker to load every object file in the library that defines an Objective-C class or category.

For more information, see [Building Objective-C static libraries with categories](http://developer.apple.com/library/mac/#qa/qa1490/_index.html).

**Solution:** To resolve this error, add the `-ObjC` value for the **Other Linker Flags** build setting by performing the following steps:

1.  In the project navigator, select the target to which you want to add a library or framework.
2.  Click the **Build Settings** tab and scroll down to the **Linking** section.
3.  In **Other Linker Flags**, add the value `-ObjC`.

**Note:** NSInvalidArgumentException is a constant in the Foundation framework (defined by NSException) and is thrown whenever you pass an invalid argument to a method. Consequently, it might be thrown for reasons other than the missing `-ObjC` flag.

See Also
--------

-   [Mac Developer Library Technical Q&As](http://developer.apple.com/library/mac/navigation/#section=Resource%20Types&topic=Technical%20Q%26amp%3BAs)
-   [Instruments User Guide](http://developer.apple.com/library/ios/#documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Introduction/Introduction.html)
-   [How to inspect iOS's HTTP traffic without spending a dime](http://www.tuaw.com/2011/02/21/how-to-inspect-ioss-http-traffic-without-spending-a-dime/)
