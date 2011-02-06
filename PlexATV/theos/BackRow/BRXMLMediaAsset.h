/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRBaseMediaAsset.h"

@class NSMutableDictionary;

@interface BRXMLMediaAsset : BRBaseMediaAsset {
@private
	NSMutableDictionary *_info;	// 8 = 0x8
}
@property(retain) id dictionary;	// G=0x32da17d9; S=0x32da1981; converted property
- (id)init;	// 0x32da1e55
- (id)initWithMediaProvider:(id)mediaProvider;	// 0x32d7e699
- (id)artist;	// 0x32da1e09
- (id)assetID;	// 0x32d7e799
- (unsigned)bookmarkTimeInMS;	// 0x32da1a91
- (unsigned)bookmarkTimeInSeconds;	// 0x32da1acd
- (id)cast;	// 0x32d86445
- (id)composer;	// 0x32da17d5
- (id)copyright;	// 0x32d86015
- (id)coverArt;	// 0x32d834f5
- (id)coverArtID;	// 0x32d8336d
- (id)dateAcquired;	// 0x32da1d3d
- (id)dateCreated;	// 0x32da1d29
- (id)datePublished;	// 0x32d865a1
- (void)dealloc;	// 0x32d7eded
- (id)description;	// 0x32da1af9
// converted property getter: - (id)dictionary;	// 0x32da17d9
- (id)directors;	// 0x32d86471
- (long)duration;	// 0x32da1c8d
- (BOOL)forceHDCPProtection;	// 0x32da19b9
- (id)genres;	// 0x32d8669d
- (BOOL)hasCoverArt;	// 0x32d831e9
- (BOOL)hasVideoContent;	// 0x32d7e735
- (id)imageProxy;	// 0x32da1e35
- (BOOL)isExplicit;	// 0x32da1b45
- (BOOL)isHD;	// 0x32da19f9
- (id)mediaSummary;	// 0x32d85fd1
- (id)mediaType;	// 0x32da1b19
- (id)mediaURL;	// 0x32d7e7c9
- (long)parentalControlRatingRank;	// 0x32da1bb5
- (long)parentalControlRatingSystemID;	// 0x32da1c21
- (id)playbackMetadata;	// 0x32da1a49
- (id)previewURL;	// 0x32d82c49
- (id)primaryCollectionTitle;	// 0x32da1ddd
- (id)primaryGenre;	// 0x32d86665
- (id)publisher;	// 0x32da1d85
- (id)rating;	// 0x32d85edd
- (id)resolution;	// 0x32d831bd
// converted property setter: - (void)setDictionary:(id)dictionary;	// 0x32da1981
- (void)setObject:(id)object forKey:(id)key;	// 0x32d7e6fd
- (id)thumbnailArt;	// 0x32d8e105
- (id)thumbnailArtID;	// 0x32d8df65
- (id)thumbnailURL;	// 0x32d8e0a1
- (id)title;	// 0x32d82645
- (id)trickPlayURL;	// 0x32da1db1
@end
