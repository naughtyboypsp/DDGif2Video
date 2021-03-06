//
//  DDGifImage.m
//  Demo
//
//  Created by hzduanjiashun on 2017/11/17.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "DDGifImage.h"

@interface DDGifImage () {
    @public
    CGImageSourceRef _imageSource;
}

@end

@interface DDGifImageEnumerator: NSEnumerator

@property (nonatomic, strong, readonly) DDGifImage *gif;
@property (nonatomic, assign) NSInteger currentIndex;

- (instancetype)initWithGifImage:(DDGifImage *)gif;

@end

@implementation DDGifImageEnumerator

- (instancetype)initWithGifImage:(DDGifImage *)gif
{
    self = [super init];
    if (self) {
        _gif = gif;
    }
    return self;
}

- (CIImage *)nextObject {
    if (self.currentIndex >= _gif.imageCount) {
        return nil;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(_gif->_imageSource, self.currentIndex, NULL);
    CIImage *ret = [CIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    self.currentIndex ++;
    return ret;
}

@end

@implementation DDGifImage

- (void)dealloc
{
    if (_imageSource) {
        CFRelease(_imageSource);
    }
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
        _name = path.lastPathComponent.stringByDeletingPathExtension;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSURL *url = [NSURL fileURLWithPath:path];
            _imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
            if (_imageSource) {
                _imageCount = CGImageSourceGetCount(_imageSource);
                
                NSDictionary *properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(_imageSource, NULL);
                NSDictionary *gifProperties = properties[(id)kCGImagePropertyGIFDictionary];
                if (gifProperties) {
                    _isGif = YES;
                    _loopCount = [gifProperties[(id)kCGImagePropertyGIFLoopCount] integerValue];
                    NSNumber *delayTime = gifProperties[(id)kCGImagePropertyGIFUnclampedDelayTime];
                    if (delayTime == nil) {
                        delayTime = gifProperties[(id)kCGImagePropertyGIFDelayTime];
                    }
                    _delayTime = [delayTime doubleValue];
                    
                    CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSource, 0, nil);
                    _width = CGImageGetWidth(image);
                    _height = CGImageGetHeight(image);
                    CGImageRelease(image);
                }
            }
        }
    }
    return self;
}

- (NSEnumerator<CIImage *> *)CIImageEnumerator {
    return [[DDGifImageEnumerator alloc] initWithGifImage:self];
}

@end
