//
//  HJMergeVideoWithMusic.m
//  音频视频合成为视频
//
//  Created by Mac on 2017/6/16.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "HJMergeVideoWithMusic.h"
#import <AVFoundation/AVFoundation.h>

@implementation HJMergeVideoWithMusic


/**
 没有背景音乐的视频添加背景音乐
 
 @param musicPath 背景音乐地址
 @param videoPath 视频地址
 @param savePath 保存视频地址
 @param successBlock 合成成功
 */

+ (void)mergeVideoWithMusic:(NSString *)musicPath noBgMusicVideo:(NSString *)videoPath saveVideoPath:(NSString *)savePath success:(mergeVideoSuccessBlock)successBlock{
    
    // 声音来源
    NSURL *audioInputUrl = [NSURL fileURLWithPath:musicPath];
    // 视频来源
    NSURL *videoInputUrl = [NSURL fileURLWithPath:videoPath];
    
    
    // 添加合成路径
    NSURL *outputFileUrl = [NSURL fileURLWithPath:savePath];
    // 时间起点
    CMTime nextClistartTime = kCMTimeZero;
    // 创建可变的音视频组合
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    
    // 视频采集
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:nil];
    // 视频时间范围
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    // 视频采集通道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //  把采集轨道数据加入到可变轨道之中
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    
    
    // 声音采集
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:nil];
    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
    CMTimeRange audioTimeRange = videoTimeRange;
    // 音频通道
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 音频采集通道
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    // 加入合成轨道之中
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
    
    // 创建一个输出
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPresetMediumQuality];
    // 输出类型
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    // 输出地址
    assetExport.outputURL = outputFileUrl;
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            successBlock();
            
        });
    }];
}




/**
 音频视频合成

 @param musicPath 音频
 @param videoPath 视频
 @param savePath 保存地址
 @param successBlock 合成成功
 */
+ (void)mergeVideoWithMusic:(NSString *)musicPath video:(NSString *)videoPath saveVideoPath:(NSString *)savePath success:(mergeVideoSuccessBlock)successBlock {
    
    //第一步：音频和视频中的音频混音，生成混音文件
    
    
    AVMutableComposition *composition =[AVMutableComposition composition];
    NSMutableArray *audioMixParams =[NSMutableArray array];
    
    //录制的视频
    NSURL *video_inputFileUrl =[NSURL fileURLWithPath:videoPath];
    AVURLAsset *songAsset =[AVURLAsset URLAssetWithURL:video_inputFileUrl options:nil];
    CMTime startTime =CMTimeMakeWithSeconds(0,songAsset.duration.timescale);
    CMTime trackDuration =songAsset.duration;
    
    //获取视频中的音频素材
    [self setUpAndAddAudioAtPath:video_inputFileUrl toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(14*44100,44100) addAudioParams:audioMixParams];
    
    
    //本地要插入的音乐
    NSURL *assetURL2 =[NSURL fileURLWithPath:musicPath];
    //获取设置完的本地音乐素材
    [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(0,44100) addAudioParams:audioMixParams];
    
    //创建一个可变的音频混合
    AVMutableAudioMix *audioMix =[AVMutableAudioMix audioMix];
    audioMix.inputParameters =[NSArray arrayWithArray:audioMixParams];//从数组里取出处理后的音频轨道参数
    
    //创建一个输出
    AVAssetExportSession *exporter =[[AVAssetExportSession alloc]
                                     initWithAsset:composition
                                     presetName:AVAssetExportPresetAppleM4A];
    exporter.audioMix = audioMix;
    exporter.outputFileType=@"com.apple.m4a-audio";//输出的类型也是 m4a文件
    
    
    //混音后的输出地址
    NSString *exportFile = [NSHomeDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"Documents/music.m4a"]];//和上面的类型保持一致
    
    if([[NSFileManager defaultManager]fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager]removeItemAtPath:exportFile error:nil];
    }
    NSLog(@"输出混音路径===%@",exportFile);
    
    NSURL *exportURL =[NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;

    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        NSLog(@"音频混音完毕，开始合成音频、视频");
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]) {
            //第二步：混音和视频合成
            
            [self theVideoWithMixMusic:exportFile videoPath:videoPath savePath:savePath success:successBlock];


        }
        
    }];
    
}


/**
 音频和视频混合

 @param mixURLPath 混音
 @param videoPath 视频
 @param savePath 保存视频
 @param successBlock 成功
 */
+ (void)theVideoWithMixMusic:(NSString *)mixURLPath videoPath:(NSString *)videoPath savePath:(NSString *)savePath success:(mergeVideoSuccessBlock)successBlock
{
    //声音来源路径（最终混合的音频）
    NSURL   *audio_inputFileUrl =[NSURL fileURLWithPath:mixURLPath];
    
    //视频来源路径
    NSURL   *video_inputFileUrl = [NSURL fileURLWithPath:videoPath];
    
    //最终合成输出路径
    NSURL   *outputFileUrl = [NSURL fileURLWithPath:savePath];
  
    CMTime nextClipStartTime =kCMTimeZero;
    
    //创建可变的音频视频组合
    AVMutableComposition* mixComposition =[AVMutableComposition composition];
    
    //视频采集
    AVURLAsset* videoAsset =[[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack*a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]atTime:nextClipStartTime error:nil];
    
    //声音采集
    AVURLAsset* audioAsset =[[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);//声音长度截取范围==视频长度
    AVMutableCompositionTrack*b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0]atTime:nextClipStartTime error:nil];
    
    //创建一个输出
    AVAssetExportSession* _assetExport =[[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType =AVFileTypeQuickTimeMovie;
    _assetExport.outputURL =outputFileUrl;
    _assetExport.shouldOptimizeForNetworkUse=YES;
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"完成！输出路径==%@",savePath);
            
            if([[NSFileManager defaultManager]fileExistsAtPath:mixURLPath]) {
                [[NSFileManager defaultManager]removeItemAtPath:mixURLPath error:nil];
            }
            successBlock();
 
        });
     }];
}

//通过文件路径建立和添加音频素材
+ (void)setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition*)composition start:(CMTime)start dura:(CMTime)dura offset:(CMTime)offset addAudioParams:(NSMutableArray *)audioMixParams {
    
    AVURLAsset *songAsset =[AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVMutableCompositionTrack *track =[composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *sourceAudioTrack =[[songAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    
    NSError *error =nil;
    BOOL ok =NO;
    
    CMTime startTime = start;
    CMTime trackDuration = dura;
    CMTimeRange tRange =CMTimeRangeMake(startTime,trackDuration);
    
    //设置音量
    //AVMutableAudioMixInputParameters（输入参数可变的音频混合）
    //audioMixInputParametersWithTrack（音频混音输入参数与轨道）
    AVMutableAudioMixInputParameters *trackMix =[AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [trackMix setVolume:0.8f atTime:startTime];
    
    //素材加入数组
    [audioMixParams addObject:trackMix];
    
    //Insert audio into track  //offsetCMTimeMake(0, 44100)
    ok = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:kCMTimeInvalid error:&error];
}



















@end
