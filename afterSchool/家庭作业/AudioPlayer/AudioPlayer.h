//
//  AudioPlayer.h
//  Share
//
//  Created by Lin Zhang on 11-4-26.
//  Copyright 2011年 www.eoemobile.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AudioStreamer;

@interface AudioPlayer : NSObject {
    AudioStreamer *streamer; 
    NSURL *url;
    NSTimer *timer;
}

@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic, retain) NSURL *url;

- (void)play;
- (void)stop;
-(void)pause;
- (BOOL)isProcessing;
//- (void)updateProgress;
-(float)durationTime;
-(float)progres;
-(void)seek:(double)point;

@end
