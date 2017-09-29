//
//  ASImageLoader.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 15.09.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASImageLoader.h"
#import <AnobiKit/AKConfig.h>

#define ASImageLoaderDefaults_requestTimeout 30
#define ASImageLoaderDefaults_cacheMemoryCapacity 4 * 0x100000
#define ASImageLoaderDefaults_cacheDiskCapacity 64 * 0x100000

#pragma mark - UIView
#pragma mark -

@interface UIView (ASImageLoader)
- (id)cellAtIndexPath:(NSIndexPath *)ip;
- (void)reloadCellAtIndexPath:(NSIndexPath *)ip;
@end

#pragma mark - UITableView
#pragma mark -

@implementation UITableView (ASImageLoader)
- (id)cellAtIndexPath:(NSIndexPath *)ip {
    return [self cellForRowAtIndexPath:ip];
}
- (void)reloadCellAtIndexPath:(NSIndexPath *)ip {
    [self reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end

#pragma mark - UICollectionView
#pragma mark -

@implementation UICollectionView (ASImageLoader)
- (id)cellAtIndexPath:(NSIndexPath *)ip {
    return [self cellForItemAtIndexPath:ip];
}
- (void)reloadCellAtIndexPath:(NSIndexPath *)ip {
    [self reloadItemsAtIndexPaths:@[ip]];
}
@end

#pragma mark - ASImageLoader
#pragma mark -

@implementation ASImageLoader

static UIImage *placeholder;
static NSMutableSet *failedURLs;
static NSCache *cache;

static NSUInteger cacheMemoryCapacity;
static NSUInteger cacheDiskCapacity;
static NSTimeInterval requestTimeout;

+ (void)initialize {
    [super initialize];
    @try {
        NSDictionary *config = [AKConfig<NSDictionary *> configWithName:self.class.description];
        if (config) {
            requestTimeout = ((NSNumber *)config[@"requestTimeout"]).doubleValue ?: ASImageLoaderDefaults_requestTimeout;
            cacheMemoryCapacity = ((NSNumber *)config[@"cacheMemoryCapacity"]).unsignedIntegerValue;
            if (cacheMemoryCapacity <= 0) cacheMemoryCapacity = ASImageLoaderDefaults_cacheMemoryCapacity;
            cacheDiskCapacity = ((NSNumber *)config[@"cacheDiskCapacity"]).unsignedIntegerValue;
            if (cacheDiskCapacity <= 0) cacheDiskCapacity = ASImageLoaderDefaults_cacheDiskCapacity;
        }
    } @catch (NSException *exception) {
        NSLog(@"[ERROR] Exception: %@", exception);
    }
}

+ (void)configureWithRequestTimeout:(NSTimeInterval)t cacheMemoryCapacity:(NSUInteger)cacheMemoryCap cacheDiskCapacity:(NSUInteger)cacheDiskCap  {

}


+ (UIImage *)imageFetch:(void (^)(UIImage *image, NSError *error))fetch withURL:(NSURL *)URL {
    if (!URL || [failedURLs containsObject:URL]) {
        return placeholder;
    }
    
    UIImage *cachedImage = [cache objectForKey:URL];
    if (cachedImage) {
        return cachedImage;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:requestTimeout];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (cachedResponse) {
        NSData *data = cachedResponse.data;
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [cache setObject:image forKey:URL];
                return image;
            }
        }
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"[ERROR] %@", error);
            if (error.code == NSURLErrorUnsupportedURL) {
                [failedURLs addObject:URL];
            }
        }
        if (fetch) {
            UIImage *image = placeholder;
            if (data) {
                image = [UIImage imageWithData:data];
                [cache setObject:image forKey:URL];
            }
            fetch(image, error);
        }
    }] resume];
    
    return nil;
}


+ (void)imageFetchWithURL:(NSURL *)URL
                  forCell:(id<ASImagePresenter>)cell
                   inView:(__weak UIView *)view
              atIndexPath:(NSIndexPath *)indexPath {
    UIImage *cachedImage = [self imageFetch:^(UIImage *image, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (view) {
                id ipcell = [view cellAtIndexPath:indexPath];
                if (ipcell) {
                    if ([ipcell conformsToProtocol:@protocol(ASImagePresenter)]) {
                        id<ASImagePresenter> imagePresenter = ipcell;
                        [imagePresenter setImage:image];
                        if (imagePresenter.activityIndicator) {
                            [imagePresenter.activityIndicator stopAnimating];
                        }
                    }
                } else {
                    [view reloadCellAtIndexPath:indexPath];
                }
            }
        });
    } withURL:URL];
    if (cachedImage) {
        [cell.activityIndicator stopAnimating];        
    } else {
        [cell.activityIndicator startAnimating];
    }
    [cell setImage:cachedImage];
}

@end
