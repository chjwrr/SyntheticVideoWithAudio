//
//  HJMergeVideoWithMusic.h
//  音频视频合成为视频
//
//  Created by Mac on 2017/6/16.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^mergeVideoSuccessBlock)(void);

@interface HJMergeVideoWithMusic : NSObject


/**
 没有背景音乐的视频添加背景音乐

 @param musicPath 背景音乐地址
 @param videoPath 视频地址
 @param savePath 保存视频地址
 @param successBlock 合成成功
 */
+ (void)mergeVideoWithMusic:(NSString *)musicPath noBgMusicVideo:(NSString *)videoPath saveVideoPath:(NSString *)savePath success:(mergeVideoSuccessBlock)successBlock;

//抽取原视频的音频与需要的音乐混合
/**
 音频视频合成
 
 @param musicPath 音频
 @param videoPath 视频
 @param savePath 保存地址
 @param successBlock 合成成功
 */
+ (void)mergeVideoWithMusic:(NSString *)musicPath video:(NSString *)videoPath saveVideoPath:(NSString *)savePath success:(mergeVideoSuccessBlock)successBlock;

    
@end
