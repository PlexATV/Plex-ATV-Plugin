/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BackRow-Structs.h"
#import "BRControl.h"

@class BRMediaPlayer, NSString, BRTrackInfoLayer;

__attribute__((visibility("hidden")))
@interface BRTrackInfoControl : BRControl {
@private
	BRTrackInfoLayer *_layer;	// 40 = 0x28
	BRMediaPlayer *_player;	// 44 = 0x2c
	NSString *_lastAssetID;	// 48 = 0x30
}
@property(retain) BRMediaPlayer *player;	// G=0x32dd5749; S=0x32dd5b85; converted property
- (id)init;	// 0x32dd5e45
- (id)_fetchCoverArt;	// 0x32dd5ed5
- (void)_playbackAssetChanged:(id)changed;	// 0x32dd597d
- (void)_playerStateChanged:(id)changed;	// 0x32dd5991
- (BOOL)_supportsShowingArtist:(id)artist;	// 0x32dd5831
- (BOOL)_supportsShowingPrimaryCollectionTitle:(id)title;	// 0x32dd5759
- (void)_updateCoverArt:(id)art;	// 0x32dd58c9
- (void)_updateTrackInfo;	// 0x32dd59c9
- (id)accessibilityLabel;	// 0x32dd5b65
- (void)controlWasActivated;	// 0x32dd5cf9
- (void)controlWasDeactivated;	// 0x32dd5c6d
- (void)dealloc;	// 0x32dd5db1
// converted property getter: - (id)player;	// 0x32dd5749
// converted property setter: - (void)setPlayer:(id)player;	// 0x32dd5b85
@end
