//
//  THDownloadWebService.m
//  UserSystem
//
//  Created by Hao Tan on 12-3-21.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import "THDownloadWebService.h"
#import "THWebDefine.h"

@implementation THDownloadWebService
@synthesize overwrite;
@synthesize fileName=_fileName;
@synthesize filePath=_filePath;
@synthesize fileSize;
@synthesize peakSpeed;
@synthesize averageSpeed;
@synthesize downloadBlock;

- (void)setDelegate:(id)anObject
{
    _delegate = anObject;
}

- (id)delegate
{
    return _delegate;
}

- (void)stop
{
    [super stop];
    [_fileHandle closeFile];
    _fileHandle = nil;
    
    [_timer invalidate];
    _timer = nil;
    
    _startDate = nil;
    
    totalDownSize = 0;
    onceDownSize  = 0;
    peakSpeed =0;
    averageSpeed = 0;
    
    fileSize = 0;
}

- (NSURLRequest *)setUpRequest:(NSError **)error
{
    //当url为空的时间，返回失败
    if (!_url)
    {
        if (error) *error = THErrorURLFail;
        return nil;
    }
    
    //未指定文件名
    if (!_fileName)
    {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:_url MIMEType:NULL expectedContentLength:NULL textEncodingName:NULL];
        _fileName = [response suggestedFilename];
        /*
        NSString *urlStr = [_url absoluteString];
        _fileName = [urlStr lastPathComponent];
        if ([_fileName length] > 32) _fileName = [_fileName substringFromIndex:[_fileName length]-32];
         */
    }
    
    //未指定路径
    if (!_filePath) 
    {
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        _filePath = documentsDir;
    }
    
    //目标地址与缓存地址
    _destinationPath=[_filePath stringByAppendingPathComponent:_fileName];
	_temporaryPath=[_destinationPath stringByAppendingFormat:kTHDownLoadTask_TempSuffix];
    
    //处理如果文件已经存在的情况
    if ([[NSFileManager defaultManager] fileExistsAtPath:_destinationPath]) 
    {
        if (overwrite) 
        {
            [[NSFileManager defaultManager] removeItemAtPath:_destinationPath error:nil];
        }else
        {
            if (error) *error = THErrorFileExist;
            return nil;
        }
    }
    
    //缓存文件不存在，则创建缓存文件
    if (![[NSFileManager defaultManager] fileExistsAtPath:_temporaryPath]) 
    {
        BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:_temporaryPath contents:nil attributes:nil];
        if (!createSucces)
        {
            if (error) *error = THErrorCreateFail;
            return nil;
        }
    }
    
    //设置fileHandle
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_temporaryPath];
    offset = [_fileHandle seekToEndOfFile];
    NSString *range = [NSString stringWithFormat:@"bytes=%llu-",offset];
    
    //设置下载的一些属性
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
    [request addValue:range forHTTPHeaderField:@"Range"];
    if (error) *error = NULL;
    return request;
}

- (void)startWithHandler:(THDownloadWebServiceBlock)block;
{
    self.downloadBlock = block;
    [self startAsynchronous];
}

- (BOOL)startAsynchronous
{
    BOOL sucess = [super startAsynchronous];
    if (sucess)
    {
        _timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:kTHDownLoadTimerInterval target:self selector:@selector(lisenProgressAndSpeed) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        
        _startDate = [[NSDate alloc] init];
    }
    return sucess;
}

- (void)lisenProgressAndSpeed
{
    offset = [_fileHandle offsetInFile];
    
    double totalTimeGap = fabs([_startDate timeIntervalSinceNow]);
    double onceTimeGap = [_timer timeInterval];
    averageSpeed = totalDownSize/totalTimeGap;
    peakSpeed = onceDownSize/onceTimeGap;
    onceDownSize = 0;
    
    if (fileSize > 0)
    {
        double progress = offset*1.0/fileSize;
        if ([_delegate respondsToSelector:@selector(downloadProgressChange:progress:)])
        {
            [[self delegate] downloadProgressChange:self progress:progress];
        }
        if (self.downloadBlock)
        {
            self.downloadBlock(NULL,NULL,progress,NO);
        }
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)didReceiveResponse:(NSURLResponse *)response
{
    if ([response expectedContentLength] != NSURLResponseUnknownLength) 
    {
        fileSize = [response expectedContentLength] + offset;
    }
    if (self.downloadBlock)
    {
        self.downloadBlock(response,NULL,0,NO);
    }
    [super didReceiveResponse:response];
}

- (void)didReceiveData:(NSData *)aData
{
    totalDownSize += aData.length;
    onceDownSize  += aData.length;
    [_fileHandle writeData:aData];
}

- (void)didFailWithError:(NSError *)error
{
    if (self.downloadBlock)
    {
        self.downloadBlock(NULL,error,0,NO);
    }
}

- (void)didFinishLoading
{
    [[NSFileManager defaultManager] moveItemAtPath:_temporaryPath toPath:_destinationPath error:nil];
    if (self.downloadBlock)
    {
        self.downloadBlock(NULL,NULL,0,YES);
    }
    [super didFinishLoading];
}

@end
