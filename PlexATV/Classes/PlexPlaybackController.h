//
//  PlexPlaybackController.h
//  plex
//
//  Created by Bob Jelica on 22.02.2011.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@class PlexMediaObject;
@class PlexMediaPart;

@interface PlexPlaybackController : BRController {
    BOOL playbackCancelled;
    BOOL useDirectPlay;
    BOOL userCancel;
}
@property (retain) PlexMediaObject *mediaObject;

@property (retain) PlexMediaPart *currentPart;
@property (assign) NSUInteger currentPartIndex;

@property (retain) NSTimer *playProgressTimer;

- (id)initWithPlexMediaObject:(PlexMediaObject*)aMediaObject;
- (void)startPlaying;
- (void)playbackVideoWithOffset:(int)offset;
- (void)movieFinished:(NSNotification*)event;
- (void)playerStateChanged:(NSNotification*)event;
- (void)playbackAudio;
- (void)postProgress:(NSDictionary*)progressDict;
- (void)showResumeDialog;
@end