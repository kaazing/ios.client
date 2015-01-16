Objective-C WebSocket Client Demo
=================================
[![Build Status][build-status-image]][build-status]

[build-status-image]: https://travis-ci.org/kaazing/gateway.client.ios.demo-1.svg?branch=develop
[build-status]: https://travis-ci.org/kaazing/gateway.client.ios.demo-1


About this project
------------------
This is a simple Xcode project that shows how to use the [Kaazing WebSocket Objective-C Client library](https://github.com/kaazing/gateway.client.ios)!
Requirements
------------

* Java SE Development Kit (JDK) 7 or higher
* Maven 3.0.5 or higher
* Xcode 5 or higher
* You'll need Xcode's Command Line Tools installed.  From Xcode, install via _Xcode &rarr; Preferences &rarr; Downloads_.


Steps for building this project
--------------------------------
0. Clone the repo: ```git clone https://github.com/kaazing/gateway.client.ios.demo.git```
0. Go to the cloned directory: ```cd gateway.client.ios.demo```
0. Build the project: ```mvn clean package```

This downloads the required iOS library (including its headers) and puts them into the _right_ directory.


Running the demo from within Xcode
------------------------------------
Once the above steps have been done, start Xcode and open the project, by going the following folder with the Xcode wizard:

    src/main/Xcode

This _should_ get the project included into your Xcode IDE and you should be able to run the project in the simulator.

Have fun!
