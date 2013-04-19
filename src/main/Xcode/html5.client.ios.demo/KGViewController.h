//
//  KGViewController.h
//  html5.client.ios.demo
//
//  Created by Matthias Wessendorf on 20.06.12.
//  Copyright (c) 2012 Kaazing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGViewController : UIViewController<UITextFieldDelegate>

- (IBAction)connectButton:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)closeButton:(id)sender;
- (IBAction)clearLog:(id)sender;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;

@property (weak, nonatomic) IBOutlet UITextField *uriTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISwitch *binarySwitch;

@end
