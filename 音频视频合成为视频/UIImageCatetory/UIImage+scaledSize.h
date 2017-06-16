//
//  UIImage+scaledSize.h
//  音频视频合成为视频
//
//  Created by Mac on 2017/6/16.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (scaledSize)


/**
 图片根据尺寸缩放

 @param targetSize 尺寸
 @return 新的图片
 */
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;



@end
