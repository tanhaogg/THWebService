//
//  THWebUtility.m
//  UserSystem
//
//  Created by Hao Tan on 12-3-20.
//  Copyright (c) 2012年 http://www.tanhao.me All rights reserved.
//

#import "THWebUtility.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation THWebUtility

#pragma mark -
#pragma mark Hash

#define THHashSizeForRead (4*1024)

+ (NSString *)hashFile:(NSString *)filePath with:(THHashKind)hashKind
{
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    if (!inputStream)
    {
        return nil;
    }
    
    void *CTXPoint = NULL;
    switch (hashKind)
    {
        case THHashKindMd5:
        {
            CTXPoint = (CC_MD5_CTX *)calloc(1, (sizeof(CC_SHA1_CTX)));
            CC_MD5_Init(CTXPoint);
            break;
        }
        case THHashKindSha1:
        {
            CTXPoint = (CC_SHA1_CTX *)calloc(1, (sizeof(CC_SHA1_CTX)));
            CC_SHA1_Init(CTXPoint);
            break;
        }
        case THHashKindSha256:
        {
            CTXPoint = (CC_SHA256_CTX *)calloc(1, (sizeof(CC_SHA256_CTX)));
            CC_SHA256_Init(CTXPoint);
            break;
        }
        case THHashKindSha512:
        {            
            CTXPoint = (CC_SHA512_CTX *)calloc(1, (sizeof(CC_SHA512_CTX)));
            CC_SHA512_Init(CTXPoint);
            break;
        }
        default:
        {
            return nil;
            break;
        }
    }
    
    [inputStream open];
    while (YES)
    {
        uint8_t buffer[THHashSizeForRead];
        NSInteger readBytesCount = [inputStream read:buffer maxLength:sizeof(buffer)];
        if (readBytesCount < 0)
        {
            [inputStream close];
            free(CTXPoint);
            return nil;
        }
        else if (readBytesCount == 0)
        {
            break;
        }
        
        switch (hashKind)
        {
            case THHashKindMd5:
            {
                CC_MD5_Update(CTXPoint,(const void *)buffer,(CC_LONG)readBytesCount);
                break;
            }
            case THHashKindSha1:
            {
                CC_SHA1_Update(CTXPoint,(const void *)buffer,(CC_LONG)readBytesCount);
                break;
            }
            case THHashKindSha256:
            {
                CC_SHA256_Update(CTXPoint,(const void *)buffer,(CC_LONG)readBytesCount);
                break;
            }
            case THHashKindSha512:
            {            
                CC_SHA512_Update(CTXPoint,(const void *)buffer,(CC_LONG)readBytesCount);
                break;
            }
        }
    }
    
    unsigned char *digest = NULL;
    NSUInteger digestLength = 0;
    switch (hashKind)
    {
        case THHashKindMd5:
        {
            digestLength = CC_MD5_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_MD5_Final(digest, CTXPoint);
            break;
        }
        case THHashKindSha1:
        {
            digestLength = CC_SHA1_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_SHA1_Final(digest, CTXPoint);
            break;
        }
        case THHashKindSha256:
        {
            digestLength = CC_SHA256_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_SHA256_Final(digest, CTXPoint);
            break;
        }
        case THHashKindSha512:
        {            
            digestLength = CC_SHA512_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_SHA512_Final(digest, CTXPoint);
            break;
        }
    }
    // Compute the string result
    NSMutableString *hashString = [NSMutableString string];    
    for (size_t i = 0; i < digestLength; ++i) 
    {
        [hashString appendFormat:@"%02x",digest[i]];
    }
    
    [inputStream close];
    free(digest);
    free(CTXPoint);
    return hashString;
}

+ (NSString *)hashData:(NSData *)data with:(THHashKind)hashKind
{
    if (!data)
    {
        return nil;
    }
    
    const char *cStr = [data bytes];
	
    unsigned char *digest = NULL;
    NSUInteger digestLength = 0;
    switch (hashKind)
    {
        case THHashKindMd5:
        {
            digestLength = CC_MD5_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_MD5(cStr, (uint32_t)data.length, digest);
            break;
        }
        case THHashKindSha1:
        {
            digestLength = CC_SHA1_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_SHA1(cStr, (uint32_t)data.length, digest);
            break;
        }
        case THHashKindSha256:
        {
            digestLength = CC_SHA256_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_SHA256(cStr, (uint32_t)data.length, digest);
            break;
        }
        case THHashKindSha512:
        {            
            digestLength = CC_SHA512_DIGEST_LENGTH;
            digest = (u_char *)calloc(1, digestLength);
            CC_SHA512(cStr, (uint32_t)data.length, digest);
            break;
        }
        default:
        {
            return nil;
            break;
        }
    }
    
    NSMutableString *hashString = [NSMutableString string];    
    for (size_t i = 0; i < digestLength; ++i) 
    {
        [hashString appendFormat:@"%02x",digest[i]];
    }
    free(digest);
    return hashString; 
}

+ (NSString *)hashString:(NSString *)string with:(THHashKind)hashKind
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data)
    {
        return nil;
    }
    return [self hashData:data with:hashKind];
}

#pragma mark -
#pragma mark HMAC

+ (NSString *)hMacData:(NSData *)data withSecretKey:(NSString *)secretKey withHashKind:(THHashKind)hashKind
{
    if (!data || !secretKey)
    {
        return nil;
    }
    
    CCHmacAlgorithm algorithm;
    NSUInteger digestLength;
    switch (hashKind)
    {
        case THHashKindMd5:
        {
            digestLength = CC_MD5_DIGEST_LENGTH;
            algorithm = kCCHmacAlgMD5;
            break;
        }
        case THHashKindSha1:
        {
            digestLength = CC_SHA1_DIGEST_LENGTH;
            algorithm = kCCHmacAlgSHA1;
            break;
        }
        case THHashKindSha256:
        {
            digestLength = CC_SHA256_DIGEST_LENGTH;
            algorithm = kCCHmacAlgSHA256;
            break;
        }
        case THHashKindSha512:
        {            
            digestLength = CC_SHA512_DIGEST_LENGTH;
            algorithm = kCCHmacAlgSHA512;
            break;
        }
        default:
        {
            return nil;
            break;
        }
    }
    
    const char *cKey =  [secretKey cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[digestLength];
    CCHmac(algorithm, cKey, strlen(cKey), data.bytes, data.length, cHMAC);
    
    NSMutableString* hash = [NSMutableString  string];
    for(int i = 0; i < sizeof(cHMAC); i++)
    {
        [hash appendFormat:@"%02x", cHMAC[i]];
    }    
    return hash;
}

+ (NSString *)hMacString:(NSString *)string withSecretKey:(NSString *)secretKey withHashKind:(THHashKind)hashKind
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data || !secretKey)
    {
        return nil;
    }
    return [self hMacData:data withSecretKey:secretKey withHashKind:hashKind];
}

@end
