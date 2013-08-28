// JSCEngine.m
//
// Copyright (c) 2013 Tang Tianyong
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
// KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
// AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#import "JSCEngine.h"
#import <JavaScriptCore/JavaScriptCore.h>

id NSObjectWithJSValue(JSContextRef context, JSValueRef value);

// √
NSString * NSStringWithJSString(JSStringRef string) {
    return CFBridgingRelease(JSStringCopyCFString(kCFAllocatorDefault, string));
}

// √
NSString * NSStringWithJSValue(JSContextRef context, JSValueRef value) {
    return NSStringWithJSString(JSValueToStringCopy(context, value, NULL));
}

NSDictionary * NSDictionaryWithJSObject(JSContextRef context, JSObjectRef object) {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    JSPropertyNameArrayRef propertyNames = JSObjectCopyPropertyNames(context, object);
    size_t propertyCount = JSPropertyNameArrayGetCount(propertyNames);
    
    for (size_t i = 0; i < propertyCount; ++i) {
        JSStringRef propertyName = JSPropertyNameArrayGetNameAtIndex(propertyNames, i);
        
        JSValueRef valueRef = JSObjectGetProperty(context, object, propertyName, NULL);
        id value = NSObjectWithJSValue(context, valueRef);
        
        if (value) {
            NSString *key = NSStringWithJSString(propertyName);
            dictionary[key] = value;
        }
    }
    
    JSPropertyNameArrayRelease(propertyNames);
    
    return dictionary;
}

id NSObjectWithJSValue(JSContextRef context, JSValueRef value) {
    id result = nil;
    
    switch (JSValueGetType(context, value)) {
        case kJSTypeBoolean:
            result = @(JSValueToBoolean(context, value));
            break;
        case kJSTypeString:
            result = NSStringWithJSValue(context, value);
            break;
        case kJSTypeNumber:
            result = @(JSValueToNumber(context, value, NULL));
            break;
        case kJSTypeNull:
            result = [NSNull null];
            break;
        case kJSTypeObject:
            if (JSObjectIsFunction(context, (JSObjectRef)value)) {
                result = ^ id (id param1, ...) {
                    NSMutableArray *params = [[NSMutableArray alloc] init];
                    
                    if (param1) {
                        [params addObject:param1];
                        
                        va_list args;
                        va_start(args, param1);
                        
                        id param;
                        
                        while ((param = va_arg(args, id)) != nil) {
                            
                        }
                        
                        va_end(args);
                    }
                    
                };
            } else {
                result = NSDictionaryWithJSObject(context, (JSObjectRef)value);
            }
            break;
        case kJSTypeUndefined:
            break;
        default:
            break;
    }
    
    return result;
}

@implementation JSCEngine {
    JSGlobalContextRef _globalContext;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _globalContext = JSGlobalContextCreate(NULL);
    }
    
    return self;
}

- (id)eval:(NSString *)code error:(NSError *__autoreleasing *)error {
    JSStringRef script = JSStringCreateWithCFString((__bridge CFStringRef)(code));

    JSValueRef exception = NULL;
    JSValueRef result = JSEvaluateScript(_globalContext, script, NULL, NULL, 0, &exception);
    
    JSStringRelease(script);
    
    if (exception != NULL) {
        JSType type = JSValueGetType(_globalContext, exception);
        
        switch (type) {
            case kJSTypeUndefined:
                NSLog(@"Undefined");
                break;
            case kJSTypeNull:
                NSLog(@"Null");
                break;
            case kJSTypeBoolean:
                NSLog(@"Boolean");
                break;
            case kJSTypeNumber:
                NSLog(@"Number");
                break;
            case kJSTypeString:
                NSLog(@"String");
                break;
            case kJSTypeObject:
                NSLog(@"Object");
                break;
            default:
                break;
        }
        
        
        JSStringRef exceptionArg = JSValueToStringCopy(_globalContext, exception, NULL);
        NSString* exceptionRes = (__bridge NSString*)JSStringCopyCFString(kCFAllocatorDefault, exceptionArg);
        
        NSLog(@"reason: %@", exceptionRes);
    }
    
    
    
    if (exception != NULL) {
        if (error != NULL) {
            
        }
        
        return nil;
    }
    
    return nil;
}

@end
