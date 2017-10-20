//
//  ViewController.m
//  OperationTest
//
//  Created by 韩志峰 on 2017/9/12.
//  Copyright © 2017年 韩志峰. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Person+Height.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableString  *mutableName;
@property (nonatomic, copy) NSString *nString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self conCurrentQueue];
//    [self serialQueue];
//    [self globalQueue];
    [self groupQueue];
//    [self barrier_dis];
    /*
    //[mutabble copy]深复制 [inmutabble copy] 浅复制
    Person *per = [[Person alloc] init];
    NSMutableString *testString = [[NSMutableString alloc] initWithString:@"jiaoshi"];
    per.name = testString;
    per.job = testString;
    [testString appendString:@"xiaozhang"];
     */
//    [self signalTest];
    
}
- (void)serialQueue{
    dispatch_queue_t queue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"ontTask%@",[NSThread currentThread]);
        sleep(1);
    });
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"twoTask%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"threeTask%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"fourTask%@",[NSThread currentThread]);
    });
}
- (void)conCurrentQueue{
    dispatch_queue_t queue = dispatch_queue_create("com.conCurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"ontTask%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"twoTask%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"threeTask%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"fourTask%@",[NSThread currentThread]);
    });
    
}
- (void)globalQueue{//全局并发队列是个单利
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue02 = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue03 = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue04 = dispatch_get_global_queue(0, 0);
    NSLog(@"%p\n%p\n%p\n%p",queue,queue02,queue03,queue04);
    
}
- (void)groupQueue{
    //当指定的task完成之后程序才能向下进行
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"oneTask");
        sleep(3);
        NSLog(@"oneTaskOver");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"twoTask");
        NSLog(@"twoTaskOver");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"fourTask");
        NSLog(@"fourTaskOver");
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"notify ---no task");//notify 里面的最后一步调用
        
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"threeTask");
        NSLog(@"threeTaskOver");
    });
    dispatch_group_enter(group);
    dispatch_group_leave(group);
    
}
- (void)barrier_dis{
    dispatch_queue_t queue = dispatch_queue_create("con", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"oneTask");
        sleep(3);
        NSLog(@"oneTaskOver");
    });
    dispatch_async(queue, ^{
        NSLog(@"twoTask");
        sleep(1);
        NSLog(@"twoTaskOver");
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"barrier");
    });
    dispatch_async(queue, ^{
        NSLog(@"three");
        NSLog(@"three over");
    });
    dispatch_async(queue, ^{
        NSLog(@"four");
        NSLog(@"four over");
    });

}
/*
 dispatch_semaphore_t sema = dispatch_semaphore_create(0);
 [网络请求:{
 成功：dispatch_semaphore_signal(sema);
 失败：dispatch_semaphore_signal(sema);
 }];
 dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
 */
//信号量来控制线程的顺序
- (void)signalTest{
    NSBlockOperation *operationOne = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        NSLog(@"oneTask%@",[NSThread currentThread]);
        dispatch_queue_t queue = dispatch_queue_create("con", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            NSLog(@"fenfa%@",[NSThread currentThread]);
            sleep(2);
            NSLog(@"finish");
            NSLog(@"oneTaskOver");
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
     }];
    NSBlockOperation *twoOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"twoTask%@",[NSThread currentThread]);
        sleep(1);
        NSLog(@"twoTaskOver");
    }];
    NSBlockOperation *threeOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"threeTask%@",[NSThread currentThread]);
        //        sleep(1);
        NSLog(@"threeTaskOver");
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [threeOperation addDependency:twoOperation];
    [twoOperation addDependency:operationOne];
    [queue addOperations:@[operationOne,twoOperation,threeOperation] waitUntilFinished:NO];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
