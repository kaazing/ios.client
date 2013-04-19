//
//  KGViewController.m
//  html5.client.ios.demo
//
//  Created by Matthias Wessendorf on 20.06.12.
//  Copyright (c) 2012 Kaazing. All rights reserved.
//

#import "KGViewController.h"
#import "Core.h"

//LoginHandler API:
@interface KGDemoLoginHandler : KGLoginHandler
@end

@implementation KGDemoLoginHandler {
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    int _buttonIndex;
}

-(void)dealloc {
    
}

- (id)init {
    NSLog(@"[KGDemoLoginHandler init]");
    self = [super init];
    return self;
}


-(NSURLCredential*) credentials {
    
    _buttonIndex = -1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popupLogin];
    });
    
    //wate user clock a button
    while (_buttonIndex < 0) {
        [NSThread sleepForTimeInterval:1];
        //_buttonIndex = 0;
    }
    // Clicked the Submit button
    if (_buttonIndex != 0)
    {
        NSString* username = usernameTextField.text;
        NSString* password = passwordTextField.text;
        return [[NSURLCredential alloc] initWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
    } else {
        return nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    _buttonIndex = buttonIndex;
}

- (void) popupLogin {
    _buttonIndex = -1;
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Please Login:" message:@"\n \n \n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    // Adds a username Field
    usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; usernameTextField.placeholder = @"Username";
    [usernameTextField setBackgroundColor:[UIColor whiteColor]];
    [usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [alertview addSubview:usernameTextField];
    // Adds a password Field
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0, 260.0, 25.0)]; passwordTextField.placeholder = @"Password";
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [passwordTextField setBackgroundColor:[UIColor whiteColor]]; 
    [alertview addSubview:passwordTextField];
    
    // Show alert on screen. 
    
    [alertview show];
}
@end



@interface KGViewController ()

@end


@implementation KGViewController {
    
    KGWebSocket* _websocket;
    BOOL _reconnect;
    
}

@synthesize uriTextField;
@synthesize messageTextField;
@synthesize connectButton;
@synthesize closeButton;
@synthesize sendButton;
@synthesize textView;
@synthesize binarySwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)connectButton:(id)sender {
    NSString *location = self.uriTextField.text;
    
    [self log:[@"CONNECT: " stringByAppendingString:location]];
    
    // set up Login Handler:
    KGLoginHandler* loginHandler = [[KGDemoLoginHandler alloc] init];
    
    KGBasicChallengeHandler* challengeHandler = [KGChallengeHandlers load:@"KGBasicChallengeHandler"];
    [challengeHandler setLoginHandler:loginHandler];
    [KGChallengeHandlers setDefault:challengeHandler];
    
    
    
    
    _websocket = [KGWebSocket connectionWithURLString:location];
    [self setupWebSocketListeners];
        
    [_websocket connect];

    self.uriTextField.enabled = NO;
    self.uriTextField.backgroundColor = [UIColor lightGrayColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.messageTextField || theTextField == self.uriTextField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)sendMessage:(id)sender {
    if ([binarySwitch isOn]) {
        NSData *data = [self.messageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
        [self log:[NSString stringWithFormat:@"SEND: %@", data]];
        
        [_websocket send:data];
    }
    else {
        NSString *msg = self.messageTextField.text;
        [self log:[@"SEND: " stringByAppendingString:msg]];

        [_websocket send:msg];
    }
}

- (IBAction)closeButton:(id)sender {
    [self log:@"CLOSE"];
    
    [_websocket close];
}

- (IBAction)clearLog:(id)sender {
    [textView setText:@""];
}


-(void) setupWebSocketListeners {
    
    KGViewController* ref = self;
    
    _websocket.didOpen = ^(KGWebSocket* webSocket) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ref log:@"CONNECTED"];
            [ref updateUIcomponents:YES];
        });
    };
    
    _websocket.didReceiveMessage = ^(KGWebSocket* webSocket, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
                [ref log:[NSString stringWithFormat:@"MESSAGE: %@", data]];
        });
    };
    
    _websocket.didCloseWithCode = ^(KGWebSocket* websocket, NSInteger code, NSString* reason, BOOL wasClean) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ref log:[@"CLOSED" stringByAppendingFormat:@"(%i)", code]];
            [ref updateUIcomponents:NO];
        });
    };
}

- (void) log:(NSString *)msg {
    NSString *oldText = [textView text];
    NSString *msgWithNewline = [msg stringByAppendingString:@"\n"];
    NSString *newText = [oldText stringByAppendingString:msgWithNewline];
    [textView setText:newText];
    [textView flashScrollIndicators];
}

- (void) updateUIcomponents:(BOOL)isConnected {
    self.uriTextField.enabled = !isConnected;
    self.uriTextField.backgroundColor = isConnected?[UIColor lightGrayColor]:[UIColor whiteColor];
    self.messageTextField.enabled = isConnected;
    self.messageTextField.backgroundColor = isConnected? [UIColor whiteColor]:[UIColor lightGrayColor];
    self.sendButton.enabled = isConnected;
    self.connectButton.enabled = !isConnected;
    self.closeButton.enabled = isConnected;
}

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
            //connection was open when application enter background, reconnect!
            NSString *location = self.uriTextField.text;
            _websocket = [KGWebSocket connectionWithURLString:location];
            [self setupWebSocketListeners];
            
            [_websocket connect];
        }
    }
}
@end

