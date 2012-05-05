//
//  MethodSwizzler.m
//  RFLibrary
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "MethodSwizzler.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation MethodSwizzler

+ (void) swizzleClass:(Class)klass selector:(SEL)original withSelector:(SEL)alternate {
    
    Method orig_method = class_getInstanceMethod(klass, original);
    Method alt_method = class_getInstanceMethod(klass, alternate);
    
    // if both methods are found, swizzle them
    if(class_addMethod(klass, original, method_getImplementation(alt_method), method_getTypeEncoding(alt_method))) {
        class_replaceMethod(klass, alternate, method_getImplementation(orig_method), method_getTypeEncoding(orig_method));
    } else {
        method_exchangeImplementations(orig_method, alt_method);
    }
}

@end
