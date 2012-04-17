//
//  THDispatchQueue.m
//  ApplicationStatus
//
//  Created by Hao Tan on 12-4-11.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import "THDispatchQueue.h"
#import "THWebDefine.h"

@implementation THDispatchQueue

- (id)initWithConcurrentCount:(int)count
{
    self = [super init];
    if (self)
    {
        if (count < 1) count = kTHDispatchQueueDefaultConcurrentCount;
        semaphore = dispatch_semaphore_create(count);
        queue = dispatch_queue_create(NULL, NULL);
    }
    return self;
}

- (id)init
{
    return [self initWithConcurrentCount:kTHDispatchQueueDefaultConcurrentCount];
}

- (void)dealloc
{
    dispatch_release(semaphore);
    dispatch_release(queue);
}

- (void)addOperation:(THQueueOperationBlock)block
{
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block();
            dispatch_semaphore_signal(semaphore);
        });
    });
}

@end
