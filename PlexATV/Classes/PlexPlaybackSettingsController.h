//
//  PlexAudioSettingsController.h
//  atvTwo
//
//  Created by bob on 10/01/2011.
//
//  Inspired by
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//


@interface PlexPlaybackSettingsController : SMFMediaMenuController {}
@property (retain) NSArray *plexStreamingQualities;
- (void)setupList;

@end
