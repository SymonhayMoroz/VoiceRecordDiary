//
//  Voice.h
//  VoiceDiary
//
//  Created by Symonhay M on 2016. 1. 22..
//  Copyright (c) 2016 T. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Voice : NSObject

@property NSString *date;
@property NSString *title;
@property NSString *voicePath;
@property NSString *time;






- (void)setDataWithDateString:(NSString *)inDate withTitle:(NSString *)inTitle withVPath:(NSString*)inPath;
@end
