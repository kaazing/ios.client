-   [Home](../../index.md)
-   [Documentation](../index.md)
-   Troubleshoot Your Objective-C Client

Troubleshoot Your Objective-C Client
====================================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

This topic contains descriptions of common errors that might occur when using the Objective-C Client API and provides steps on how to prevent these errors.

Before You Begin
----------------

This procedure is part of [Build Objective-C (iOS) WebSocket Clients](o_dev_objc.md):

1.  [Use the Objective-C WebSocket Client API](p_dev_objc_client.md)
2.  [Secure Your Objective-C Client](p_dev_objc_secure.md)
3.  [Display Logs for the Objective-C Client](p_dev_objc_log.md)
4.  **Troubleshoot Your Objective-C Client**

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


