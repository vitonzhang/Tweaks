//
//  _FBTweakEditViewController.m
//  Pods
//
//  Created by zhangchong on 15-4-14.
//
//

#import "_FBTweakEditViewController.h"
#import "FBTweak.h"
#import <objc/objc.h>

@interface _FBTweakEditViewController () <UITextViewDelegate>
{
    FBTweak *_tweak;
    
    UIScrollView *_containerView;
    UITextView *_originalValueTextView;
    UITextView *_newValueTextView;
}
@end

@implementation _FBTweakEditViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
    self = [super init];
    if (self) {
        _tweak = tweak;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardFrameChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    CGSize viewSize = self.view.bounds.size;
    CGRect containerViewRc = CGRectZero;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    if ([self isiOS7OrHigher]
        && (!self.navigationController || !self.tabBarController))
    {
        containerViewRc.origin.y = 2.0f;
        containerViewRc.size.height = viewSize.height - 64.f;
        containerViewRc.size.width = viewSize.width;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    else
    {
        containerViewRc.size = viewSize;
    }
    
    _containerView = [[UIScrollView alloc] initWithFrame:containerViewRc];
    [_containerView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:_containerView];
    
    // "Old Value" Label.
    CGRect lableRc = CGRectMake(0, 0, viewSize.width, 40.0f);
    UILabel *oldValueLable = [[UILabel alloc] initWithFrame:lableRc];
    [oldValueLable setText:@"Old Value"];
    [oldValueLable setBackgroundColor:[UIColor colorWithRed:0xff/255.0f
                                                      green:0x2d/255.0f
                                                       blue:0x4b/255.0f
                                                      alpha:1.0f]];
    [oldValueLable setTextColor:[UIColor whiteColor]];
    [oldValueLable setTextAlignment:NSTextAlignmentCenter];
    [_containerView addSubview:oldValueLable];
    
    // "Old Value" Text.
    CGFloat textViewHeight = containerViewRc.size.height * 0.45 - 40.0f;
    CGRect origianlViewRc = CGRectMake(0, 40.0f, containerViewRc.size.width, textViewHeight);
    _originalValueTextView = [[UITextView alloc] initWithFrame:origianlViewRc];
    [_originalValueTextView setBackgroundColor:[UIColor whiteColor]];
    [_originalValueTextView setEditable:NO];
    [_originalValueTextView setFont:[UIFont systemFontOfSize:18.f]];
    [_originalValueTextView setText:_tweak.currentValue ? _tweak.currentValue : _tweak.defaultValue];
    [_containerView addSubview:_originalValueTextView];
    
    // "New Value" Label.
    lableRc.origin.y = containerViewRc.size.height * 0.5;
    UILabel *newValueLable = [[UILabel alloc] initWithFrame:lableRc];
    [newValueLable setText:@"New Value"];
    [newValueLable setBackgroundColor:[UIColor colorWithRed:0xff/255.0f
                                                      green:0x2d/255.0f
                                                       blue:0x4b/255.0f
                                                      alpha:1.0f]];
    [newValueLable setTextColor:[UIColor whiteColor]];
    [newValueLable setTextAlignment:NSTextAlignmentCenter];
    [_containerView addSubview:newValueLable];
    
    // "New Value" Text.
    CGRect newViewRc = CGRectMake(0, containerViewRc.size.height * 0.5 + 40,
                                  containerViewRc.size.width, textViewHeight);
    _newValueTextView = [[UITextView alloc] initWithFrame:newViewRc];
    [_newValueTextView setBackgroundColor:[UIColor whiteColor]];
    [_newValueTextView setFont:[UIFont systemFontOfSize:18.f]];
    [_newValueTextView setDelegate:self];
    [_containerView addSubview:_newValueTextView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(_save)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
     
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_save {

    NSString *text = _newValueTextView.text;
    _tweak.currentValue = text;
    [_newValueTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    NSString * text = [textView text];
    
    if (text && [text length] > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // [textView resignFirstResponder];
}

#pragma mark - Keyboard
- (void)_keyboardFrameChanged:(NSNotification *)notification
{
    
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    endFrame = [self.view.window convertRect:endFrame fromWindow:nil];
    endFrame = [self.view convertRect:endFrame fromView:self.view.window];
    
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void (^animations)() = ^{
        /*
        UIEdgeInsets contentInset = _containerView.contentInset;
        contentInset.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
        _containerView.contentInset = contentInset;
        
        UIEdgeInsets scrollIndicatorInsets = _containerView.scrollIndicatorInsets;
        scrollIndicatorInsets.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
        _containerView.scrollIndicatorInsets = scrollIndicatorInsets;
        */
        
        CGPoint contentOffset= _containerView.contentOffset;
        contentOffset.y = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
        _containerView.contentOffset = contentOffset;
    };
    
    UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
}

#pragma mark - Utils

// Move into Utils files.
- (BOOL)isiOS7OrHigher
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end




