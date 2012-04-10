//
//  THPostWebService.h
//  UserSystem
//
//  Created by Hao Tan on 12-3-20.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THWebService.h"

@interface THPostWebService : THWebService
{
    NSDictionary *_postDic;
}
@property (nonatomic, strong) NSDictionary *postDic;

@end
