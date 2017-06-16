//
//  UIImage+scaledSize.m
//  音频视频合成为视频
//
//  Created by Mac on 2017/6/16.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "UIImage+scaledSize.h"

@implementation UIImage (scaledSize)



- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        
        /*
         CGFloat widthFactor = targetWidth / width;
         CGFloat heightFactor = targetHeight / height;
         
         if (widthFactor > heightFactor)
         scaleFactor = widthFactor; // scale to fit height
         else
         scaleFactor = heightFactor; // scale to fit width
         
         
         scaledWidth= width * scaleFactor;
         scaledHeight = height * scaleFactor;
         
         // center the image
         if (widthFactor > heightFactor)
         {
         thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
         }
         else if (widthFactor < heightFactor)
         {
         thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
         }
         */
        
        if (width > height) {
            //横向长图
            
            scaledHeight = targetWidth * height / width;
            scaledWidth = targetWidth;
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            thumbnailPoint.x = 0;
            
        }else if (height > width){
            //竖向长图
            
            scaledWidth = width * targetHeight / height;
            scaledHeight = targetHeight;
            
            thumbnailPoint.y = 0;
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            
        }else{
            //正方形图
            
            scaledWidth = targetWidth;
            scaledHeight = targetWidth;
            
            thumbnailPoint.x = 0;
            thumbnailPoint.y = (targetHeight - targetWidth) * 0.5;
            
        }
        
        
        
        
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
