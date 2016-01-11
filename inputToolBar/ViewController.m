//
//  ViewController.m
//  inputToolBar
//
//  Created by simple on 16/1/11.
//  Copyright © 2016年 levy.com. All rights reserved.
//

#import "ViewController.h"

#define KFacialSizeWidth    20

#define KFacialSizeHeight   20

#define KCharacterWidth     8


#define VIEW_LINE_HEIGHT    24

#define VIEW_LEFT           16

#define VIEW_RIGHT          16

#define VIEW_TOP            8


#define VIEW_WIDTH_MAX      166

@interface ViewController ()<UITextViewDelegate>
{
    
    BOOL isFirstShowKeyboard;
    
    BOOL isButtonClicked;
    
    BOOL isKeyboardShowing;
    
    BOOL isSystemBoardShow;
    
    
    CGFloat keyboardHeight;
    
    
    UIView *toolBar;
    
    UITextView *textView;
    
    UIButton *sendButton;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self subViews];
    
    [textView.layer setCornerRadius:6];
    [textView.layer setMasksToBounds:YES];
    
    isFirstShowKeyboard = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

-(void)subViews{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = width*1.0/500;
    
    toolBar = [UIView new];
    [toolBar setBackgroundColor:[UIColor colorWithRed:0.9412 green:0.9412 blue:0.9412 alpha:1.0]];
    [toolBar setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 68*scale, width, 68*scale)];
    [self.view addSubview:toolBar];
    
    textView = [UITextView new];
    textView.delegate = self;
    [textView.layer setCornerRadius:6];
    [textView.layer setBorderColor:[UIColor blackColor].CGColor];
    [textView.layer setBorderWidth:1];
    [textView.layer setMasksToBounds:YES];
    [textView setFrame:CGRectMake(15*scale, 13*scale, 370*scale, 45*scale)];
    [toolBar addSubview:textView];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setBackgroundColor:[UIColor whiteColor]];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton.layer setCornerRadius:6];
    [sendButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [sendButton.layer setBorderWidth:1];
    [sendButton.layer setMasksToBounds:YES];
    [sendButton setFrame:CGRectMake(395*scale, 13*scale, 96*scale, 45*scale)];
    [toolBar addSubview:sendButton];
    
}

-(void)sendClick:(UIButton *)btn{
    
    textView.text = nil;
    [self textViewDidChange:textView];
    
    [textView resignFirstResponder];
    
    isFirstShowKeyboard = YES;
    
    isButtonClicked = NO;
    
    textView.inputView = nil;
}

/** ################################ UIKeyboardNotification ################################ **/

- (void)keyboardWillShow:(NSNotification *)notification {
    
    dispatch_after(0.0, dispatch_get_main_queue(), ^{
        
        isKeyboardShowing = YES;
        
        NSDictionary *userInfo = [notification userInfo];
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        CGRect keyboardRect = [aValue CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
        
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        UIViewAnimationCurve animationCurve;
        [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [UIView setAnimationCurve:animationCurve];
                             CGRect  frame = toolBar.frame;
                             frame.origin.y += keyboardHeight;
                             frame.origin.y -= keyboardRect.size.height;
                             toolBar.frame = frame;
                             
                             keyboardHeight = keyboardRect.size.height;
                         }];
        
        if ( isFirstShowKeyboard ) {
            
            isFirstShowKeyboard = NO;
            
            isSystemBoardShow = !isButtonClicked;
        }
        
        
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    dispatch_after(0.0, dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = [notification userInfo];
        
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        UIViewAnimationCurve animationCurve;
        [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [UIView setAnimationCurve:animationCurve];
                             CGRect   frame = toolBar.frame;
                             frame.origin.y += keyboardHeight;
                             toolBar.frame = frame;
                             
                             keyboardHeight = 0;
                         }];
    });
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    isKeyboardShowing = NO;
    
    if ( isButtonClicked ) {
        
        isButtonClicked = NO;
        isSystemBoardShow = YES;
        textView.inputView = nil;
        [textView becomeFirstResponder];
    }
}

/** ################################ UITextViewDelegate ################################ **/

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //点击了非删除键
    if( [text length] == 0 ) {
        
        if ( range.length > 1 ) {
            
            return YES;
        }
        else {
            
            return YES;
        }
    }
    else {
        
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)_textView {
    
    CGSize size = textView.contentSize;
    size.height -= 2;
    if ( size.height >= 68 ) {
        
        size.height = 68;
    }
    else if ( size.height <= 32 ) {
        
        size.height = 32;
    }
    
    if ( size.height != textView.frame.size.height ) {
        
        CGFloat span = size.height - textView.frame.size.height;
        
        CGRect frame = toolBar.frame;
        frame.origin.y -= span;
        frame.size.height += span;
        toolBar.frame = frame;
        
        CGFloat centerY = frame.size.height / 2;
        
        frame = textView.frame;
        frame.size = size;
        textView.frame = frame;
        
        CGPoint center = textView.center;
        center.y = centerY;
        textView.center = center;
        
        center = sendButton.center;
        center.y = centerY;
        sendButton.center = center;
    }
}

@end
