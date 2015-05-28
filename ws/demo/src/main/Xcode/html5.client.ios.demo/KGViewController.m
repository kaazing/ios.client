/**
 ** This is free and unencumbered software released into the public domain.
 **
 ** Anyone is free to copy, modify, publish, use, compile, sell, or
 ** distribute this software, either in source code form or as a compiled
 ** binary, for any purpose, commercial or non-commercial, and by any
 ** means.
 **
 ** In jurisdictions that recognize copyright laws, the author or authors
 ** of this software dedicate any and all copyright interest in the
 ** software to the public domain. We make this dedication for the benefit
 ** of the public at large and to the detriment of our heirs and
 ** successors. We intend this dedication to be an overt act of
 ** relinquishment in perpetuity of all present and future rights to this
 ** software under copyright law.
 **
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 ** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 ** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 ** IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 ** OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ** ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 ** OTHER DEALINGS IN THE SOFTWARE.
 **
 ** For more information, please refer to <http://unlicense.org/>
 */

#import "KGViewController.h"
#import <KGWebSocket/WebSocket.h>

//LoginHandler API:
@interface KGDemoLoginHandler : KGLoginHandler
@end

@implementation KGDemoLoginHandler {
    NSString             *_username;
    NSString             *_password;
    NSInteger            _buttonIndex;
    UIAlertView          *_alertView;
    dispatch_semaphore_t _loginSemaphore;
}

-(void)dealloc {
    _username = nil;
    _password = nil;
}

- (id)init {
    self = [super init];
    return self;
}


-(NSURLCredential*) credentials {
    _buttonIndex = -1;
    _loginSemaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popupLogin];
    });
    
    // dispatch_semaphore_wait call will decrement the resource count.
    // Since the resulting value is less than zero, this call waits in
    // for a signal to occur before returning.
    // dispatch_semaphore_signal is called when OK or Cancel button
    // is clicked
    dispatch_semaphore_wait(_loginSemaphore, DISPATCH_TIME_FOREVER);
    
    // Release the reference of semaphore to free up the memory
    _loginSemaphore = nil;

    // Clicked the Submit button
    if (_buttonIndex != 0)
    {
        return [[NSURLCredential alloc] initWithUser:_username password:_password persistence:NSURLCredentialPersistenceNone];
    } else {
        return nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _username = [_alertView textFieldAtIndex:0].text;
    _password = [_alertView textFieldAtIndex:1].text;
    _buttonIndex = buttonIndex;
    dispatch_semaphore_signal(_loginSemaphore);
}

- (void) popupLogin {
    _buttonIndex = -1;
    
    _alertView = [[UIAlertView alloc] initWithTitle:@"Please Login:" message:nil
                                           delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"OK", nil];
    
    _alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    // Show alert on screen
    [_alertView show];
}
@end



@interface KGViewController ()

@end


@implementation KGViewController {
    
    KGWebSocket           *_websocket;
    KGWebSocketFactory    *_factory;
    BOOL                  _reconnect;
    
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
    KGTracerDebug = YES;
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
    NSString *url = uriTextField.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createAndEstablishWebSocketConnection:url];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.messageTextField || theTextField == self.uriTextField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)sendMessage:(id)sender {
    @try {
        id dataToSend;
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

- (IBAction)closeButton:(id)sender {
    [self log:@"CLOSE"];
    @try {
        [_websocket close];
    }
    @catch (NSException *exception) {
        [self log:[exception reason]];
    }
}

- (IBAction)clearLog:(id)sender {
    [textView setText:@""];
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
            NSString *url = uriTextField.text;
            
            //connection was open when application enter background, reconnect!
            [self createAndEstablishWebSocketConnection:url];
            
        }
    }
}

#pragma mark<Private Methods>

- (KGChallengeHandler *) createBasicChallengeHandler {
    KGLoginHandler* loginHandler = [[KGDemoLoginHandler alloc] init];
    KGBasicChallengeHandler* challengeHandler = [KGBasicChallengeHandler create];
    [challengeHandler setLoginHandler:loginHandler];
    return challengeHandler;
}

- (void) createAndEstablishWebSocketConnection:(NSString *)location {
    @try {
        [self log:@"CONNECTING"];
        
        // Create KGWebSocketFactory
        _factory = [KGWebSocketFactory createWebSocketFactory];

        KGChallengeHandler *challengeHandler = [self createBasicChallengeHandler];
        
        // Setting the challenge handler will implicitly enable the revalidate extension
        [_factory setDefaultChallengeHandler:challengeHandler];
        
        // Create KGWebSocket from the KGWebSocketFactory
        NSURL   *url = [NSURL URLWithString:location];
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

- (void) log:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = msg;
        NSString *log = [textView text];
        
        if ((log != nil) && ([log length] > 0)) {
            text = [NSString stringWithFormat:@"%@\n%@", [textView text], msg];
        }
        
        // remove old text if text field is too large
        if ([[textView text] length] > 5000) {
            text = [text substringFromIndex:3000];
        }
        
        [textView setText:text];
        [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
    });
}

- (void) updateUIcomponents:(BOOL)isConnected {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.uriTextField.enabled = !isConnected;
        self.uriTextField.backgroundColor = isConnected?[UIColor lightGrayColor]:[UIColor whiteColor];
        self.messageTextField.enabled = isConnected;
        self.messageTextField.backgroundColor = isConnected? [UIColor whiteColor]:[UIColor lightGrayColor];
        self.sendButton.enabled = isConnected;
        self.connectButton.enabled = !isConnected;
        self.closeButton.enabled = isConnected;
    });
}


@end

