//
//  Person+Height.m
//  OperationTest
//
//  Created by 韩志峰 on 2017/9/12.
//  Copyright © 2017年 韩志峰. All rights reserved.
//

#import "Person+Height.h"
#import <objc/runtime.h>
@implementation Person (Height)
- (NSString *)src{
    NSString *src = objc_getAssociatedObject(self, @"src");
    return src;
}
- (void)setSrc:(NSString *)src{
    objc_setAssociatedObject(self, @"src", src, OBJC_ASSOCIATION_RETAIN);
}
@end
