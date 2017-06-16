//
//  ViewController.m
//  音频视频合成为视频
//
//  Created by Mac on 2017/6/16.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "HJImagesToVideo.h"
#import "HJMergeVideoWithMusic.h"
#import "UIImage+scaledSize.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mergeMusicAndVideo];

}
- (void)mergeMusicAndNoMusicVide {
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"Documents/movie.mp4"]];
    
    NSArray * testImageArray = @[ [UIImage imageNamed:@"12.jpeg"],
                                  [UIImage imageNamed:@"1.jpeg"],
                                  [UIImage imageNamed:@"3.jpeg"],
                                  [UIImage imageNamed:@"4.jpeg"],
                                  [UIImage imageNamed:@"5.jpeg"],
                                  [UIImage imageNamed:@"6.jpeg"],
                                  [UIImage imageNamed:@"7.jpeg"],
                                  [UIImage imageNamed:@"8.jpeg"],
                                  [UIImage imageNamed:@"9.jpeg"],
                                  [UIImage imageNamed:@"10.jpeg"],
                                  [UIImage imageNamed:@"11.jpeg"],
                                  [UIImage imageNamed:@"2.jpeg"]];
    
    
    
    CGSize currentSize = CGSizeMake(320, 480);
    
    
    NSMutableArray *imageArray=[NSMutableArray array];
    
    for (int i = 0; i<testImageArray.count; i++) {
        UIImage *imageNew = testImageArray[i];
        //设置image的尺寸
        CGSize imagesize = imageNew.size;
        imagesize.height =currentSize.height;
        imagesize.width =currentSize.width;
        
        //对图片大小进行压缩--
        imageNew = [imageNew imageByScalingAndCroppingForSize:currentSize];
        [imageArray addObject:imageNew];
    }
    
    
    //每次生成视频前，先移除重复名的，
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
    
    NSLog(@"path:%@",path);
    
    //开始合成
    
    __weak typeof(self)weakSelf=self;
    
    [HJImagesToVideo saveVideoToPhotosWithImages:imageArray videoPath:path withSize:currentSize withFPS:1 animateTransitions:YES withCallbackBlock:^(BOOL success) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                NSLog(@"success");
                
                // 最终合成输出路径
                NSString *outPutFilePath = [NSHomeDirectory() stringByAppendingPathComponent:
                                            [NSString stringWithFormat:@"Documents/merge.mp4"]];
                
                [HJMergeVideoWithMusic mergeVideoWithMusic:[[NSBundle mainBundle] pathForResource:@"一个人的冬天" ofType:@"mp3"] noBgMusicVideo:path saveVideoPath:outPutFilePath success:^{
                    
                    NSLog(@"合成成功  %@",outPutFilePath);
                    
                    [weakSelf playWithUrl:outPutFilePath];
                }];
                
            }
            
        });
        
    }];
    

}


/** 播放方法 */
- (void)playWithUrl:(NSString *)urlPath{
    // 传入地址
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:urlPath]];
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.view.frame;
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.view.layer addSublayer:playerLayer];
    // 播放
    [player play];
    
    
}


- (void)mergeMusicAndVideo {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"Documents/movie.mov"]];
    
    
    [HJMergeVideoWithMusic mergeVideoWithMusic:[[NSBundle mainBundle] pathForResource:@"一个人的冬天" ofType:@"mp3"] video:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"] saveVideoPath:path success:^{
        
    }];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
