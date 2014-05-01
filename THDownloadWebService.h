//
//  THDownloadWebService.h
//  UserSystem
//
//  Created by Hao Tan on 12-3-21.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THWebService.h"

typedef void(^THDownloadWebServiceBlock)(NSURLResponse *response, NSError *error, double progress, BOOL finished);

@protocol THDownloadWebServiceDelegate;
@interface THDownloadWebService : THWebService
{     
    BOOL       overwrite;
	NSString   *_fileName;
    NSString   *_filePath;
    NSDate     *_startDate;
    unsigned long long fileSize;
    double peakSpeed;
    double averageSpeed;
    
@private
    NSTimer    *_timer;
    NSString   *_destinationPath;
    NSString   *_temporaryPath;
    NSFileHandle        *_fileHandle;
    unsigned long long  offset;
    unsigned long long  totalDownSize;
    unsigned long long  onceDownSize;
}

- (void)setDelegate:(id<THDownloadWebServiceDelegate>)anObject;
- (id<THDownloadWebServiceDelegate>)delegate;

/*
 当文件名相同时是否覆盖,overwriter为NO的时候，当文件已经存在，则下载结束,否则覆盖
 默认为NO
 */
@property (nonatomic, assign) BOOL overwrite;
/*
 下载文件的名字名，默认为下载原文件名
 */
@property (nonatomic, strong) NSString *fileName;
/*
 文件保存的path(不包括文件名),默认路径为DocumentDirectory
 */
@property (nonatomic, strong) NSString *filePath;
/*
 下载的大小,只有当下载任务成功启动之后才能获取
 */
@property (nonatomic, readonly) unsigned long long fileSize;
/*
 下载的峰值速度
 */
@property (nonatomic, readonly) double peakSpeed;
/*
 下载的平均速度
 */
@property (nonatomic, readonly) double averageSpeed;
/*
 Block
 */
@property (nonatomic, copy) THDownloadWebServiceBlock downloadBlock;

- (void)startWithHandler:(THDownloadWebServiceBlock)block;

+ (void)serviceWithUrl:(NSURL *)url handler:(THDownloadWebServiceBlock)block;

@end


@protocol THDownloadWebServiceDelegate <THWebServiceDelegate>

- (void)downloadProgressChange:(THDownloadWebService *)aDownload progress:(double)newProgress;

@end