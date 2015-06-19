# ios.client

[![Build Status][build-status-image]][build-status]

[build-status-image]: https://travis-ci.org/kaazing/ios.client.svg?branch=develop
[build-status]: https://travis-ci.org/kaazing/ios.client

# About This Project

The ios.client project implements the WebSocket standard in Objective-C (iOS). It provides a client API that enables developers to build iOS applications that communicate with an RFC-6455 endpoint over WebSocket.

# Building This Project

## Minimum Requirements for Building the Project

* Java SE Development Kit (JDK) 7 or higher
* Maven 3.0.5 or higher
* Xcode 5 or higher
* Xcode's Command Line Tools.  From Xcode, install via _Xcode &rarr; Preferences &rarr; Downloads_.
* xctool: ```brew install -v --HEAD xctool```
* [appledoc](https://github.com/tomaz/appledoc)

```
git clone https://github.com/tomaz/appledoc.git
cd appledoc
sudo sh install-appledoc.sh
```

## Steps for Building This Project

0. Clone the repo: ```git clone https://github.com/kaazing/ios.client.git```
0. Go to the cloned directory: ```cd ios.client```
0. Build the project: ```mvn clean install```

# Learning How to Use the Gateway

To learn how to administer the Gateway, its configuration files, and security, see the documentation on [developer.kaazing.com](http://developer.kaazing.com/documentation/5.0/index.html).

# Learning How to Develop Client Applications

To learn how to develop client applications using the Gateway, see the documentation on [developer.kaazing.com](http://developer.kaazing.com/documentation/5.0/index.html).

# View a Running Demo

To view a demo of this client, see [kaazing.org](http://kaazing.org/)
