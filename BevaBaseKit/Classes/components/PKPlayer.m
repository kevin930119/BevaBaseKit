//
//  PKPlayer.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/8/21.
//

#import "PKPlayer.h"

@interface PKPlayerView : UIView

/**
 播放器
 */
@property (nonatomic, strong) AVPlayer *player;

/**
 播放器的渲染layer层
 */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

static void *kPKPlayerInnerPlayerContext = &kPKPlayerInnerPlayerContext;
static void *kPKPlayerCurrentPlayerItemContext = &kPKPlayerCurrentPlayerItemContext;
static float const kPKPlayerDefaultLoadedDurationForPlay = 3.0f;

@interface PKPlayer ()

@property (nonatomic) PKPlayerStatus status;
@property (nonatomic, strong) NSError *error;
@property (nonatomic) NSTimeInterval currentPlaybackTime;
@property (nonatomic) NSTimeInterval currentPlaybackDuration;
@property (nonatomic) NSTimeInterval currentPlaybackLoadedDuration;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) AVPlayer *innerPlayer;

@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic, weak) id innerPlayerTimeObserver;
@property (nonatomic) PKPlayerStatus lastActiveStatus;

@property (nonatomic) NSTimeInterval wantToSeekPosition;

@end

@implementation PKPlayer

#pragma mark - Life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.wantToSeekPosition = -1;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_handleApplicationStateChangeFromNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(_handleApplicationStateChangeFromNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [center addObserver:self selector:@selector(_handleApplicationStateChangeFromNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

#pragma mark - Public methods
- (void)playWithURL:(NSURL *)url {
    if (![url isKindOfClass:[NSURL class]]) {
        NSAssert(false, @"url should not be nil");
        return;
    }
    
    [self stop];
    
    // 设置后台播放模式
    [self _setPlaybackCategoryForAudioSession];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    if (!_innerPlayer) {
        // 创建
        [self _initInnerPlayer];
    }
    
    // 播放
    [_innerPlayer play];
    
    [_innerPlayer replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)playWithURL:(NSURL *)url atTime:(NSTimeInterval)time {
    if (![url isKindOfClass:[NSURL class]]) {
        NSAssert(false, @"url should not be nil");
        return;
    }
    
    if (time > 0) {
        self.wantToSeekPosition = time;
    }
    
    [self playWithURL:url];
}

- (void)play {
    if (!_innerPlayer) {
        return;
    }
    
    [_innerPlayer play];
}

- (void)pause {
    if (!_innerPlayer) {
        return;
    }
    
    [_innerPlayer pause];
}

- (void)stop {
    if (!_innerPlayer) {
        return;
    }
    
    [self _removeKVOObserversForCurrentPlayerItem];
    
    _currentPlayerItem = nil;
    
    [_innerPlayer replaceCurrentItemWithPlayerItem:nil];
    
    self.status = PKPlayerStatusStopped;
    self.currentPlaybackTime = 0;
    self.currentPlaybackDuration = 0;
    self.currentPlaybackLoadedDuration = 0;
}

- (void)clean {
    [self _removeInnerPlayer];
}

- (void)seekToTime:(NSTimeInterval)time completion:(void (^)(BOOL finished))completion {
    if (time < 0) {
        NSAssert(false, @"time should not be lower than 0");
        return;
    }
    
    if (!_innerPlayer) {
        return;
    }
    
    if ([_innerPlayer status] != AVPlayerStatusReadyToPlay) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [_innerPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:CMTimeMakeWithSeconds(0.5f, NSEC_PER_SEC) toleranceAfter:CMTimeMakeWithSeconds(0.5f, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        
        // 播放，解决播放m3u8时没有自动播放的bug
        [weakSelf play];
    }];
}

#pragma mark - Provate methods
- (void)_initInnerPlayer {
    // 销毁播放器
    [self _removeInnerPlayer];
    
    // 初始化播放器
    AVPlayer *player = [[AVPlayer alloc] init];
    if (@available(iOS 10.0, *)) {
        player.automaticallyWaitsToMinimizeStalling = NO;
    }
    self.innerPlayer = player;
    
    PKPlayerView *playerView = [[PKPlayerView alloc] init];
    playerView.player = _innerPlayer;
    playerView.userInteractionEnabled = NO;
    self.playerView = playerView;
    
    // KVO
    [self _addKVOObserversForInnerPlayer];
    
    // 增加播放位置监听
    [self _addPeriodicTimeObserverForInnerPlayer];
    
    self.status = PKPlayerStatusInitFinished;
}

- (void)_removeInnerPlayer {
    if (!_innerPlayer) {
        return;
    }
    
    [self _removeKVOObserversForInnerPlayer];
    
    [self _removeKVOObserversForCurrentPlayerItem];
    
    [self _removePeriodicTimeObserverForInnerPlayer];
    
    _currentPlayerItem = nil;
    
    _error = nil;
    
    _playerView = nil;
    
    _innerPlayer = nil;
    
    self.status = PKPlayerStatusUnknown;
    self.currentPlaybackTime = 0;
    self.currentPlaybackDuration = 0;
    self.currentPlaybackLoadedDuration = 0;
}

- (void)_addKVOObserversForInnerPlayer {
    if (!_innerPlayer) {
        return;
    }
    
    // 增加观察者
    [_innerPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kPKPlayerInnerPlayerContext];
    
    [_innerPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kPKPlayerInnerPlayerContext];
    
    [_innerPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kPKPlayerInnerPlayerContext];
}

- (void)_removeKVOObserversForInnerPlayer {
    if (!_innerPlayer) {
        return;
    }
    
    [_innerPlayer removeObserver:self forKeyPath:@"status"];
    [_innerPlayer removeObserver:self forKeyPath:@"rate"];
    [_innerPlayer removeObserver:self forKeyPath:@"currentItem"];
}

- (void)_handlePropertyChangesForInnerPlayerWithKeyPath:(NSString *)keyPath change:(NSDictionary *)change
{
    if ([keyPath isEqualToString:@"status"]) {
        return;
    }
    
    if ([keyPath isEqualToString:@"rate"]) {
        id oldValue = change[NSKeyValueChangeOldKey];
        id newValue = change[NSKeyValueChangeNewKey];
        
        if (!_currentPlayerItem) {
            return;
        }
        
        // 1.0 -> 0.0, 暂停
        if ([oldValue floatValue] == 1.0f &&
            [newValue floatValue] == 0) {
            
            if (@available(iOS 10.0, *)) {
                [self _updateCurrentPlaybackLoadedDuration];
                
                // 加载时长是否小于可以播放的时长
                float ti = _currentPlaybackLoadedDuration - _currentPlaybackTime;
                if (ti >= 0 &&
                    ti < kPKPlayerDefaultLoadedDurationForPlay) {
                    self.status = PKPlayerStatusBuffering;
                } else {
                    self.status = PKPlayerStatusPaused;
                }
                return;
            }
            
            if ([_currentPlayerItem isPlaybackBufferEmpty] && _currentPlaybackTime > 0 && _currentPlaybackTime < _currentPlaybackDuration) {
                self.status = PKPlayerStatusBuffering;
            } else {
                self.status = PKPlayerStatusPaused;
            }
            return;
        }
        
        // 0.0 -> 1.0, 播放
        if ([oldValue floatValue] == 0 &&
            [newValue floatValue] == 1.0f) {
            if ([_currentPlayerItem isPlaybackBufferEmpty]) {
                self.status = PKPlayerStatusBuffering;
                return;
            }
            
            Float64 rate = CMTimebaseGetRate([_currentPlayerItem timebase]);
            if (rate == 0 &&
                _currentPlaybackLoadedDuration > 0) {
                self.status = PKPlayerStatusBuffering;
            }
            
            self.status = PKPlayerStatusPlaying;
            return;
        }
        
        // 0.0 -> 0.0, 缓冲时暂停
        if ([oldValue floatValue] == 0 &&
            [newValue floatValue] == 0) {
            self.status = PKPlayerStatusPaused;
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"currentItem"]) {
        // 移除当前KVO
        [self _removeKVOObserversForCurrentPlayerItem];
        
        [self _updateInnerPlayerItemWithInnerPlayerCurrentItem];
        
        [self _updateCurrentPlaybackDuration];
        
        [self _updateCurrentPlaybackLoadedDuration];
        
        [self _addKVOObserversForCurrentPlayerItem];
        return;
    }
}

- (void)_addPeriodicTimeObserverForInnerPlayer {
    [self _removePeriodicTimeObserverForInnerPlayer];
    
    if (!_innerPlayer) {
        return;
    }
    
    CMTime interval = CMTimeMakeWithSeconds(0.5f, NSEC_PER_SEC);
    
    __weak __typeof(self)weakSelf = self;
    self.innerPlayerTimeObserver =
    [_innerPlayer addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
        Float64 seconds = CMTimeGetSeconds(time);
        if (isnan(seconds) ||
            isinf(seconds) ||
            seconds < 0) {
            return;
        }
        
        weakSelf.currentPlaybackTime = seconds;
    }];
}

- (void)_removePeriodicTimeObserverForInnerPlayer {
    if (!_innerPlayerTimeObserver) {
        return;
    }
    
    [_innerPlayer removeTimeObserver:_innerPlayerTimeObserver];
    
    self.innerPlayerTimeObserver = nil;
}

- (void)_updateInnerPlayerItemWithInnerPlayerCurrentItem {
    if (!_innerPlayer) {
        return;
    }
    
    self.currentPlayerItem = [_innerPlayer currentItem];
}

- (void)_addKVOObserversForCurrentPlayerItem {
    if (!_currentPlayerItem) {
        return;
    }
    
    [_currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kPKPlayerCurrentPlayerItemContext];
    
    [_currentPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kPKPlayerCurrentPlayerItemContext];
    
    [_currentPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kPKPlayerCurrentPlayerItemContext];
    
    [_currentPlayerItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kPKPlayerCurrentPlayerItemContext];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_currentPlayerItemDidPlayToEndFromNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentPlayerItem];
}

- (void)_removeKVOObserversForCurrentPlayerItem {
    if (!_currentPlayerItem) {
        return;
    }
    
    [_currentPlayerItem removeObserver:self forKeyPath:@"status"];
    [_currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_currentPlayerItem removeObserver:self forKeyPath:@"duration"];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentPlayerItem];
}

- (void)_currentPlayerItemDidPlayToEndFromNotification:(NSNotification *)notification {
    NSString *name = [notification name];
    if (![name isEqualToString:AVPlayerItemDidPlayToEndTimeNotification]) {
        return;
    }
    
    id object = [notification object];
    if (object != _currentPlayerItem) {
        return;
    }
    
    self.status = PKPlayerStatusPlayFinished;
}

- (void)_handlePropertyChangesForCurrentPlayerItemWithKeyPath:(NSString *)keyPath change:(NSDictionary *)change {
    if ([keyPath isEqualToString:@"status"]) {
        switch ([_currentPlayerItem status]) {
            case AVPlayerItemStatusUnknown:
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                if (_wantToSeekPosition > 0) {
                    [self seekToTime:_wantToSeekPosition completion:^(BOOL finished) {
                        
                    }];
                    
                    self.wantToSeekPosition = -1;
                }
            }
                break;
                
            case AVPlayerItemStatusFailed: {
                self.error = [_currentPlayerItem error];
                
                self.status = PKPlayerStatusFailed;
                
                self.wantToSeekPosition = -1;
            }
                break;
                
            default:
                break;
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        id oldValue = change[NSKeyValueChangeOldKey];
        
        if (!oldValue) {
            self.status = PKPlayerStatusBuffering;
            return;
        }
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 获取缓冲时长
        NSArray *loadedTimeRanges = [_currentPlayerItem loadedTimeRanges];
        if ([loadedTimeRanges count] == 0) {
            return;
        }
        
        CMTimeRange timeRange = [loadedTimeRanges[0] CMTimeRangeValue];
        Float64 start = CMTimeGetSeconds(timeRange.start);
        Float64 duration = CMTimeGetSeconds(timeRange.duration);
        if (isnan(start) || isinf(start) || start < 0 ||
            isnan(duration) || isinf(duration) || duration < 0) {
            return;
        }
        
        self.currentPlaybackLoadedDuration = start + duration;
        
        if (_currentPlaybackLoadedDuration == _currentPlaybackDuration) {
            if (_status == PKPlayerStatusBuffering) {
                [self play];
            }
            return;
        }
        
        if (duration > kPKPlayerDefaultLoadedDurationForPlay) {
            if (_status == PKPlayerStatusBuffering) {
                [self play];
            }
            return;
        }
        
        if (@available(iOS 10.0, *)) {
            if ([_currentPlayerItem isPlaybackLikelyToKeepUp]) {
                [self play];
            }
            return;
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"duration"]) {
        Float64 duration = CMTimeGetSeconds([_currentPlayerItem duration]);
        if (isnan(duration) || isinf(duration) || duration < 0) {
            return;
        }
        
        self.currentPlaybackDuration = duration;
        return;
    }
}

- (void)_updateCurrentPlaybackDuration {
    Float64 duration = CMTimeGetSeconds([_currentPlayerItem duration]);
    if (isnan(duration) || isinf(duration) || duration < 0) {
        return;
    }
    
    self.currentPlaybackDuration = duration;
    return;
}

- (void)_updateCurrentPlaybackLoadedDuration {
    NSArray *loadedTimeRanges = [_currentPlayerItem loadedTimeRanges];
    if ([loadedTimeRanges count] == 0) {
        return;
    }
    
    CMTimeRange timeRange = [loadedTimeRanges[0] CMTimeRangeValue];
    Float64 start = CMTimeGetSeconds(timeRange.start);
    Float64 duration = CMTimeGetSeconds(timeRange.duration);
    if (isnan(start) || isinf(start) || start < 0 ||
        isnan(duration) || isinf(duration) || duration < 0) {
        return;
    }
    
    self.currentPlaybackLoadedDuration = start + duration;
}

- (void)_recoverPlayerStatusWithStatus:(PKPlayerStatus)status {
    switch (status) {
        case PKPlayerStatusBuffering: {
            // 播放
            [self play];
        }
            break;
            
        case PKPlayerStatusPlaying: {
            // 播放
            [self play];
        }
            break;
            
        case PKPlayerStatusPaused: {
            // 暂停
            [self pause];
        }
            break;
            
        default:
            break;
    }
}

- (void)_enableBackgroundPlay {
    // 设置媒体播放模式
    [self _setPlaybackCategoryForAudioSession];
}

- (void)_disableBackgroundPlay {
}

- (void)_removePlayerLayerFromItsPlayer {
    if (_playerView) {
        ((PKPlayerView *)_playerView).player = nil;
    }
}

- (void)_restorePlayerLayerToItsPlayer {
    if (_playerView) {
        ((PKPlayerView *)_playerView).player = _innerPlayer;
    }
}

- (void)_setPlaybackCategoryForAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session category] == AVAudioSessionCategoryPlayback) {
        return;
    }
    
    NSError *error = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback error:&error]) {
        return;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == kPKPlayerInnerPlayerContext && object == _innerPlayer) {
        [self _handlePropertyChangesForInnerPlayerWithKeyPath:keyPath change:change];
        return;
    }
    
    if (context == kPKPlayerCurrentPlayerItemContext && object == _currentPlayerItem) {
        [self _handlePropertyChangesForCurrentPlayerItemWithKeyPath:keyPath change:change];
        return;
    }
}

#pragma mark - 通知处理
- (void)_handleApplicationStateChangeFromNotification:(NSNotification *)notification {
    NSString *name = [notification name];
    if ([name isEqualToString:UIApplicationWillResignActiveNotification]) {
        // 保存上个状态
        self.lastActiveStatus = _status;
        
        _allowsBackgroundPlay ? [self _enableBackgroundPlay] :
        [self _disableBackgroundPlay];
        return;
    }
    
    if ([name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        if (!_allowsBackgroundPlay) {
            [self _recoverPlayerStatusWithStatus:_lastActiveStatus];
        }
        
        [self _restorePlayerLayerToItsPlayer];
        return;
    }
    
    if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        if (!_allowsBackgroundPlay) {
            [self pause];
            return;
        }
        
        [self _removePlayerLayerFromItsPlayer];

        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        if (_lastActiveStatus == PKPlayerStatusPlaying) {
            // 播放
            [self play];
        }
        return;
    }
}

#pragma mark - Setters
- (void)setStatus:(PKPlayerStatus)status {
    if (_status == status) {
        return;
    }
    
    _status = status;
    
    if (![_delegate respondsToSelector:@selector(player:didChangeStatus:)]) {
        return;
    }
    [_delegate player:self didChangeStatus:status];
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    _currentPlaybackTime = currentPlaybackTime;
    
    if (![_delegate respondsToSelector:@selector(player:didChangeCurrentPlaybackTime:)]) {
        return;
    }
    [_delegate player:self didChangeCurrentPlaybackTime:currentPlaybackTime];
}

- (void)setCurrentPlaybackDuration:(NSTimeInterval)currentPlaybackDuration {
    _currentPlaybackDuration = currentPlaybackDuration;
    
    if (![_delegate respondsToSelector:@selector(player:didChangeCurrentPlaybackDuration:)]) {
        return;
    }
    [_delegate player:self didChangeCurrentPlaybackDuration:currentPlaybackDuration];
}

- (void)setCurrentPlaybackLoadedDuration:(NSTimeInterval)currentPlaybackLoadedDuration {
    _currentPlaybackLoadedDuration = currentPlaybackLoadedDuration;
    
    if (![_delegate respondsToSelector:@selector(player:didChangeCurrentPlaybackLoadedDuration:)]) {
        return;
    }
    [_delegate player:self didChangeCurrentPlaybackLoadedDuration:currentPlaybackLoadedDuration];
}

@end

@implementation PKPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end


