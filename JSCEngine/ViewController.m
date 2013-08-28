//
//  ViewController.m
//  JSCEngine
//
//  Created by Tang Tianyong on 8/28/13.
//  Copyright (c) 2013 tang3w. All rights reserved.
//

#import "ViewController.h"
#import "JSCEngine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    JSCEngine *engine = [[JSCEngine alloc] init];
    
    
    
    JSGlobalContextRef context = JSGlobalContextCreate(NULL);
    
    
    JSStringRef jsString = JSStringCreateWithUTF8CString("hello, world");
    JSValueRef value = JSValueMakeString(context, jsString);
    
    JSStringRef jsString1 = JSValueToStringCopy(context, value, NULL);
    
    NSString *nsString = CFBridgingRelease(JSStringCopyCFString(kCFAllocatorDefault, jsString1));
    
    NSLog(@"%@", nsString);
    
    
    
    
//    [engine eval:@"(/dasdad/.test('asd'))" error:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
