Display Logs for the Objective-C Client
=======================================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

In this procedure, you will learn how to gather data on your KAAZING Gateway Objective-C client.

Before You Begin
----------------

This procedure is part of [Build Objective-C (iOS) WebSocket Clients](o_dev_objc.md):

1.  [Use the Objective-C WebSocket Client API](p_dev_objc_client.md)
2.  [Secure Your Objective-C Client](p_dev_objc_secure.md)
3.  **Display Logs for the Objective-C Client**
4.  [Troubleshoot Your Objective-C Client](p_dev_objc_tshoot.md)

<span id="logging"></span></a>To Display Logs for the Objective-C Client
------------------------------------------------------------------------

1.  Build your Objective-C client, as described in [Build Objective-C (iOS) WebSocket Clients](o_dev_objc.md).
2.  Add the following line into one of the existing functions, such as `viewDidLoad()`:

    `KGTracerDebug = YES;`

    For example:

    ``` m
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
-   See [KGTracer](../apidoc/client/ios/gateway/Classes/KGTracer.md) for more information.

Next Step
---------

[Troubleshoot Your Objective-C Client](p_dev_objc_tshoot.md)


