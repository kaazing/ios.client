-   [Home](../../index.md)
-   [Documentation](../index.md)
-   Secure Your Objective-C Client

Secure Your Objective-C Client
==============================

**Note:** To use the Gateway, a KAAZING client library, or a KAAZING demo, fork the repository from [kaazing.org](http://kaazing.org).

In this procedure, you will learn how to program your Objective-C client built using the KAAZING Gateway Objective-C libraries to authenticate with the KAAZING Gateway. Authenticating your client involves implementing a challenge handler to respond to authentication challenges from the Gateway. If your challenge handler is responsible for obtaining user credentials, then you will also need to implement a login handler.

For information about the KAAZING Gateway Objective-C Client API, see [Objective-C Client API](../apidoc/client/ios/gateway/index.md).

**Notes:**
 
-   Before you add security to your clients, follow the steps in [Configure Authentication and Authorization](../security/o_aaa_config_authentication.md) to set up security on KAAZING Gateway for your client. The authentication and authorization methods configured on the Gateway influence your client security implementation. The examples is this topic provide the most common client implementations.
-   For information on secure network connections between clients and the Gateway, see [Secure Network Traffic with the Gateway](../security/o_tls.md).

Creating a Basic Challenge Handler
----------------------------------

A challenge handler is a constructor used in a client to respond to authentication challenges from the Gateway when the client attempts to access a protected resource. Each of the resources protected by the Gateway can be configured with a different authentication scheme (for example, Basic, Application Basic, Negotiate, Application Negotiate, or Application Token), and your client requires a challenge handler for each of the schemes that it will encounter or a single challenge handler that will respond to all challenges.

For information about each authentication scheme type, see [Configure the HTTP Challenge Scheme](../security/p_aaa_config_authscheme.md).

Clients with a single challenge handling strategy for all 401 challenges can simply set a specific challenge handler as the default using `KGBasicChallengeHandler`. The following is an example of how to implement a single challenge handler for all challenges:

`KGBasicChallengeHandler* challengeHandler = [KGBasicChallengeHandler create];`

The preceding example uses static credentials, but you will want to create a login handler to obtain individual user credentials. Here is an example using a login popup that responds when users click a **Connect** button, obtains user credentials, and then responds to the challenge from the Gateway:

``` m
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

``` m
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

Next Step
---------

[Display Logs for the Objective-C Client](p_dev_objc_log.md)


