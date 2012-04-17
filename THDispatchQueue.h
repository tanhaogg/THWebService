//
//  THDispatchQueue.h
//  ApplicationStatus
//
//  Created by Hao Tan on 12-4-11.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^THQueueOperationBlock)(void);

@interface THDispatchQueue : NSObject
{
    dispatch_semaphore_t semaphore;
    dispatch_queue_t queue;
}

- (id)initWithConcurrentCount:(int)count;
- (void)addOperation:(THQueueOperationBlock)block;

@end
