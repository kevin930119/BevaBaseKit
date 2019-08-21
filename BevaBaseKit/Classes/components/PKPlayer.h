//
//  PKPlayer.h
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/8/21.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PKPlayerStatus) {
    PKPlayerStatusUnknown = 0,
    PKPlayerStatusInitFinished,
    PKPlayerStatusBuffering,
    PKPlayerStatusPlaying,
    PKPlayerStatusPlayFinished,
    PKPlayerStatusPaused,
    PKPlayerStatusStopped,
    PKPlayerStatusFailed
};

@class PKPlayer;

@protocol PKPlayerDelegate <NSObject>

/**
 播放器状态发生改变

 @param player 播放器
 @param status 状态
 */
- (void)player:(PKPlayer *)player didChangeStatus:(PKPlayerStatus)status;

/**
 播放位置发生改变

 @param player 播放器
 @param currentPlaybackTime 当前播放位置
 */
- (void)player:(PKPlayer *)player didChangeCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime;

/**
 当前音视频时长发生改变

 @param player 播放器
 @param currentPlaybackDuration 当前时长
 */
- (void)player:(PKPlayer *)player
didChangeCurrentPlaybackDuration:(NSTimeInterval)currentPlaybackDuration;

/**
 当前音视频缓冲时长发生改变

 @param player 播放器
 @param currentPlaybackLoadedDuration 当前缓冲时长
 */
- (void) player:(PKPlayer *)player
didChangeCurrentPlaybackLoadedDuration:(NSTimeInterval)currentPlaybackLoadedDuration;

@end

@interface PKPlayer : NSObject

/**
 代理
 */
@property (nonatomic, weak, nullable) id <PKPlayerDelegate> delegate;

/**
 播放器状态
 */
@property (nonatomic, readonly) PKPlayerStatus status;

/**
 发生的错误
 */
@property (nonatomic, readonly, strong, nullable) NSError *error;

/**
 当前的播放位置
 */
@property (nonatomic, readonly) NSTimeInterval currentPlaybackTime;

/**
 音视频时长
 */
@property (nonatomic, readonly) NSTimeInterval currentPlaybackDuration;

/**
 音视频缓冲时长
 */
@property (nonatomic, readonly) NSTimeInterval currentPlaybackLoadedDuration;

/**
 视频的渲染视图，请在接受到PKPlayerStatusInitFinished状态后使用
 */
@property (nonatomic, strong, readonly, nullable) UIView *playerView;

/**
 内部的播放器
 */
@property (nonatomic, strong, readonly, nullable) AVPlayer *innerPlayer;

/**
 是否允许后台播放，默认NO
 */
@property (nonatomic, assign) BOOL allowsBackgroundPlay;

/**
 播放URL

 @param url url
 */
- (void)playWithURL:(NSURL *)url;

/**
 在指定位置播放URL

 @param url url
 @param time 位置
 */
- (void)playWithURL:(NSURL *)url atTime:(NSTimeInterval)time;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 停止
 */
- (void)stop;

/**
 清除播放器
 */
- (void)clean;

/**
 seek操作

 @param time 位置
 @param completion 回调
 */
- (void)seekToTime:(NSTimeInterval)time completion:(void (^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
