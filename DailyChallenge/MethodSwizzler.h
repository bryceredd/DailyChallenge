//
//  MethodSwizzler.h
//  RFLibrary
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodSwizzler : NSObject
+ (void) swizzleClass:(Class)klass selector:(SEL)selectorA withSelector:(SEL)selectorB;
@end
