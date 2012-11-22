//
//  THWebService.m
//  UserSystem
//
//  Created by Hao Tan on 12-3-20.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import "THWebService.h"
#import "THWebDefine.h"

@implementation THWebService
@synthesize delegate=_delegate;
@synthesize url=_url;
@synthesize webServiceBlock;

- (void)dealloc
{
	[self stop];
}

- (void)stop
{
    [_con cancel];
    _con = nil;
}

- (NSURLRequest *)setUpRequest:(NSError **)error
{
    if (!_url)
    {
        if (error) *error = THErrorURLFail;
        return nil;
    }
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:_url
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:15.0];
    if (!request)
    {
        if (error) *error = THErrorRequestFail;
        return nil;
    }
    
	[request setHTTPMethod:@"GET"];    
    if (error) *error = NULL;
    return request;
}

- (BOOL)startAsynchronous
{
    [self stop];
    NSError *error = nil;
    NSURLRequest *request = [self setUpRequest:&error];
    if (!request)
    {
        [self didFailWithError:error];
        return NO;
    }
    _data = [[NSMutableData alloc] init];
    _con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [_con scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_con start];
    return YES;
}

- (NSData *)startSynchronous
{
    [self stop];
    NSURLRequest *request = [self setUpRequest:NULL];
    if (!request) return nil;
    NSURLResponse  *response;
    NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    return receiveData;
}

- (void)startWithHandler:(THWebServiceBlock)block
{
    [self stop];
    self.webServiceBlock = block;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSURLResponse  *response = nil;
        __block NSError *error = nil;
        __block NSData *receiveData = nil;
        NSURLRequest *request = [self setUpRequest:&error];
        if (request)
        {
            receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        }
        if (self.webServiceBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.webServiceBlock(response,error,receiveData);
            });
        }
    });
}

- (void)didReceiveResponse:(NSURLResponse *)response
{
    if (self.webServiceBlock)
    {            
        self.webServiceBlock(response,NULL,NULL);
    }
    if ([_delegate respondsToSelector:@selector(webServiceBegin:)]) 
    {
		[_delegate webServiceBegin:self];
	}
}

- (void)didReceiveData:(NSData *)aData
{
    if(_con!=nil)
    {
	    [_data appendData:aData];
	}
}

- (void)didFailWithError:(NSError *)error
{
    [self stop];
    if (self.webServiceBlock)
    {            
        self.webServiceBlock(NULL,error,NULL);
    }
    if ([_delegate respondsToSelector:@selector(webServiceFail:didFailWithError:)]) 
    {
		[_delegate webServiceFail:self didFailWithError:error];
	}
}

- (void)didFinishLoading
{
    [self stop];
    if (self.webServiceBlock)
    {            
        self.webServiceBlock(NULL,NULL,_data);
    }
    if ([_delegate respondsToSelector:@selector(webServiceFinish:didReceiveData:)]) 
    {        
		[_delegate webServiceFinish:self didReceiveData:_data];
	}
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self didReceiveResponse:response];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{
    [self didReceiveData:aData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self didFailWithError:error];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self didFinishLoading];
}

@end