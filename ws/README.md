# ios.client/ws

[![Build Status][build-status-image]][build-status]

[build-status-image]: https://travis-ci.org/kaazing/ios.client.svg?branch=develop
[build-status]: https://travis-ci.org/kaazing/ios.client

# About This Project

The ws project implements the [WebSocket standard](https://tools.ietf.org/html/rfc6455) in iOS. It provides a WebSocket client API that enables developers to build iOS applications that communicate over WebSocket with an RFC-6455 endpoint, such as KAAZING Gateway.

# Building Projects

## Minimum Requirements for Building the Projects in This Repo

* Java SE Development Kit (JDK) 7 or higher
* Maven 3.0.5 or higher
* Xcode 5 or higher
* Xcode's Command Line Tools.  From Xcode, install via _Xcode &rarr; Preferences &rarr; Downloads_.
* xctool: ```brew install -v --HEAD xctool```
* [appledoc](https://github.com/tomaz/appledoc): 

```
git clone https://github.com/tomaz/appledoc.git
cd appledoc
sudo sh install-appledoc.sh
```

## Steps for Building this Project

0. Clone the repo: ```git clone https://github.com/kaazing/ios.client.git```
0. Go to the cloned directory: ```cd ios.client```
0. Build the project: ```mvn clean install```

# Using KAAZING Gateway or any RFC-6455 Endpoint

You can use an RFC-6455 endpoint, such as KAAZING Gateway, to connect to a back-end service. To learn how to administer the Gateway, its configuration files, and security, see the documentation on [developer.kaazing.com](http://developer.kaazing.com/documentation/5.0/index.html).

# Learning How to Develop Client Applications

To learn how to develop client applications with these projects, see the documentation on [developer.kaazing.com](http://developer.kaazing.com/documentation/5.0/index.html).

# View a Running Demo

To view demos of clients built with these projects, see [kaazing.org](http://kaazing.org/)
