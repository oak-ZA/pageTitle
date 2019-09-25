//
//  Tools.m
//  PageController
//
//  Created by 张奥 on 2019/9/25.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "Tools.h"

@implementation Tools

-(NSString *)resetLaunchImage{
    CGSize viewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    NSString*viewOrientation =@"Portrait";//横屏请设置成 @"Landscape"
    NSString*launchImage =nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for(NSDictionary* dict in imagesDict){
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImage = dict[@"UILaunchImageName"];
            return launchImage;
        }
    }
    return nil;
}

//加载本地图片
-(UIImage *)loadLocalImage:(NSString *)imageUrl{
    //保证更换只更换图片,不更换地址
//    NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"launchImageUrl"];
//    NSString *path = imageUrl;
//    if (![imagePath isEqualToString:imageUrl]) {
//        //说明不是一样的地址
//        path = imagePath;
//    }
//    if ([imagePath isEqualToString:@""] && [imagePath isKindOfClass:[NSNull class]]&& imagePath == nil) {
//        path = imageUrl;
//    }
    // 获取图像路径
    NSString *filePath = [self imageFilePath:imageUrl];
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    [self loadWriteImage:imageUrl];
    if (image != nil) {
        return image;
    }
    

    return nil;
    
}

//下载存储图片
-(void)loadWriteImage:(NSString *)imageUrl{
    //下载图片
    // 沙盒中没有，下载
    // 异步下载,分配在程序进程缺省产生的并发队列
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 多线程中下载图像--->方便简洁写法
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        // 缓存图片
        BOOL isSucess =  [imageData writeToFile:[self imageFilePath:imageUrl] atomically:YES];
        if (isSucess) {
//            //图片名字存入到本地
//            [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:@"launchImageUrl"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

#pragma mark - 获取图像路径
- (NSString *)imageFilePath:(NSString *)imageUrl
{
    // 获取caches文件夹路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSLog(@"caches = %@",cachesPath);
    
    // 创建DownloadImages文件夹
    NSString *downloadImagesPath = [cachesPath stringByAppendingPathComponent:@"DownloadImages"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:downloadImagesPath]) {
        
        [fileManager createDirectoryAtPath:downloadImagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
#pragma mark 拼接图像文件在沙盒中的路径,因为图像URL有"/",要在存入前替换掉,随意用"_"代替
    NSString *imageName = [imageUrl stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *imageFilePath = [downloadImagesPath stringByAppendingPathComponent:imageName];
    
    return imageFilePath;
}

@end
