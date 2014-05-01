//
//  THWebService.h
//  UserSystem
//
//  Created by Hao Tan on 12-3-20.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^THWebServiceBlock) (NSURLResponse *response, NSError *error, NSData *data);

@protocol THWebServiceDelegate;
@interface THWebService : NSObject
{
	id<THWebServiceDelegate>   __unsafe_unretained _delegate;
	NSURL                      *_url;
	
@protected
	NSURLConnection            *_con;
	NSMutableData              *_data;
}
@property (nonatomic, unsafe_unretained) id<THWebServiceDelegate> delegate;
@property (nonatomic, strong) NSURL  *url;
@property (nonatomic, copy) THWebServiceBlock webServiceBlock;

- (void)stop;
- (BOOL)startAsynchronous;
- (NSData *)startSynchronous;
- (void)startWithHandler:(THWebServiceBlock)block;

+ (NSData *)dataWithUrl:(NSURL *)url;
+ (void)serviceWithUrl:(NSURL *)url handler:(THWebServiceBlock)block;

@end

@interface THWebService()
- (void)didReceiveResponse:(NSURLResponse *)response;
- (void)didReceiveData:(NSData *)aData;
- (void)didFailWithError:(NSError *)error;
- (void)didFinishLoading;
@end

@protocol THWebServiceDelegate<NSObject>

- (void)webServiceBegin:(THWebService *)webService;
- (void)webServiceFinish:(THWebService *)webService didReceiveData:(NSData *)data;
- (void)webServiceFail:(THWebService *)webService didFailWithError:(NSError *)error;

@end
