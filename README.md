# gateway.client.ios

# About this Project

gateway.client.ios is an implementation of WebSocket specification [RFC-6455] (https://tools.ietf.org/html/rfc6455) in Objective-C.

# Building this Project

## Minimum requirements for building the project

* Java SE Development Kit (JDK) 7 or higher
* Maven 3.0.5 or higher
* Xcode 5 or higher
* Xcode's Command Line Tools.  From Xcode, install via _Xcode &rarr; Preferences &rarr; Downloads_.
* xctool: ```brew install -v --HEAD xctool```

## Steps for building this project

0. Clone the repo: ```git clone https://github.com/kaazing/gateway.client.java.git```
0. Go to the cloned directory: ```cd gateway.client.ios```
0. Build the project: ```mvn clean install```

# Running this Project

0. Integrate this component in gateway.distribution by updating the version in gateway.distribution's pom
0. Build the corresponding gateway.distribution and use it for application development

# Running a Prebuilt Project

You can also obtain the WebSocket iOS Client library by downloading the full Kaazing WebSocket Gateway from kaazing.org. The iOS WebSocket Client library - KGWebSocket.dmg - will be found under GATEWAY_HOME/lib/client/ios folder.

# Learning How to Develop Client Applications

Learn to develop RFC-6455 based [iOS client applications](http://kazing.org/documentaton/5.0/dev-ios/o_dev_ios.html).

# View a Running Demo

View a demo (see kaazing.org)

