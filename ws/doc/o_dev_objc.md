Build Objective-C (iOS) WebSocket Clients
=========================================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

This checklist provides the steps necessary to create an Objective-C client using the KAAZING Gateway [Objective-C Client API](http://developer.kaazing.com/documentation/5.0/apidoc/client/ios/gateway/index.html):

| \#  | Step                                                                                                                                         | Topic or Reference                                                 |
|-----|----------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| 1   | Learn how to use the Objective-C Client API.                                                                                                 | [Use the Objective-C WebSocket Client API](p_dev_objc_client.md) |
| 2   | Learn how to authenticate your client by implementing a challenge handler to respond to authentication challenges from KAAZING Gateway. | [Secure Your Objective-C Client](p_dev_objc_secure.md)           |
| 3   | Learn how to gather data on KAAZING Gateway Objective-C client                                                                               | [Display Logs for the Objective-C Client](p_dev_objc_log.md)     |
| 4   | Troubleshoot the most common issues that occur when using Objective-C clients.                                                               | [Troubleshoot Your Objective-C Client](p_dev_objc_tshoot.md)     |


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



