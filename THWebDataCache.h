//
//  THWebDataCache.h
//  THWebServiceTest
//
//  Created by Hao Tan on 12-4-12.
//  Copyright (c) 2012年 http://www.tanhao.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THWebDataCache : NSObject
{
    NSString *cacheDirectory;
}

- (id)initWithSubDirectory:(NSString *)subDirectory;
- (BOOL)storeData:(NSData *)aData forKey:(NSString *)key;
- (NSData *)dataFromKey:(NSString *)key;
- (BOOL)removeDataForKey:(NSString *)key;

@end
