//
//  PlexThemeMusicPlayer.h
//  plex
//
//  Created by ccjensen on 06/05/2011.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class PlexMediaObject;

@interface PlexThemeMusicPlayer : NSObject {}
@property (retain) AVPlayer *themeMusicPlayer;
@property (retain) NSURL *currentlyPlayingThemeUrl;


+ (PlexThemeMusicPlayer*)sharedPlexThemeMusicPlayer;

- (void)startPlayingThemeMusicIfAppropiateForMediaObject:(PlexMediaObject*)mediaObject;
- (void)stopPlayingThemeMusicForMediaObject:(PlexMediaObject*)pmo;
- (AVPlayerItem*)playerItemForURL:(NSURL*)url withVolumeAt:(CGFloat)requestedVolume;

@end
