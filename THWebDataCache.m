//
//  THWebDataCache.m
//  THWebServiceTest
//
//  Created by Hao Tan on 12-4-12.
//  Copyright (c) 2012年 http://www.tanhao.me. All rights reserved.
//

#import "THWebDataCache.h"
#import "THWebDefine.h"

@implementation THWebDataCache

- (id)initWithSubDirectory:(NSString *)subDirectory
{
    self = [super init];
    if (self)
    {
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([cachePaths count] == 0)
        {
            return nil;
        }
        
        NSString *rootCachePath = [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:kTHWebDataCacheDirectory];
        cacheDirectory = [rootCachePath stringByAppendingPathComponent:subDirectory];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory])
        {
            BOOL sucess = [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
            if (!sucess)
            {
                return nil;
            }
        }
    }
    return self;
}

- (id)init
{
    return [self initWithSubDirectory:@""];
}

- (NSString *)cachePathForKey:(NSString *)key
{
    return [THWebUtility hashString:key with:THHashKindMd5];
}

- (BOOL)storeData:(NSData *)aData forKey:(NSString *)key
{
    if (!aData || [key length] ==0)
    {
        return NO;
    }
    NSString *fileName = [self cachePathForKey:key];
    if ([fileName length] == 0)
    {
        return NO;
    }
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    return [aData writeToFile:filePath atomically:YES];
}

- (NSData *)dataFromKey:(NSString *)key
{
    if ([key length] ==0)
    {
        return nil;
    }
    NSString *fileName = [self cachePathForKey:key];
    if ([fileName length] == 0)
    {
        return nil;
    }
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:filePath];
}

- (BOOL)removeDataForKey:(NSString *)key
{
    if ([key length] ==0)
    {
        return NO;
    }
    NSString *fileName = [self cachePathForKey:key];
    if ([fileName length] == 0)
    {
        return NO;
    }
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return YES;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
}

@end
