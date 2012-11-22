//
//  THWebDefine.h
//  UserSystem
//
//  Created by Hao Tan on 12-3-21.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import "THWebUtility.h"
#import "THWebService.h"
#import "THPostWebService.h"
#import "THDownloadWebService.h"
#import "THDispatchQueue.h"

#ifndef UserSystem_THWebDefine_h
#define UserSystem_THWebDefine_h

//Error
#define THErrorURLFail      [NSError errorWithDomain:@"URL Can not be nil!" code:100 userInfo:nil]
#define THErrorRequestFail  [NSError errorWithDomain:@"URL Request Create Error!" code:101 userInfo:nil]
#define THErrorFileExist    [NSError errorWithDomain:@"File Exist!" code:102 userInfo:nil]
#define THErrorCreateFail   [NSError errorWithDomain:@"Create File Fail!" code:103 userInfo:nil]

//下载的临时文件的后缀 
#define kTHDownLoadTask_TempSuffix  @".TempDownload"
//计算下载速度的取样时间
#define kTHDownLoadTimerInterval    2.0
//THDispatchQueue默认的并发数
#define kTHDispatchQueueDefaultConcurrentCount 10
//缓存的文件夹
#define kTHWebDataCacheDirectory    @"com.magican.datacache"

#endif
