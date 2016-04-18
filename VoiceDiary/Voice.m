//
//  Voice.m
//  VoiceDiary
//
//  Created by Symonhay M on 2016. 1. 22..
//  Copyright (c) 2016 T. All rights reserved.
//

#import "Voice.h"

@implementation Voice


- (void)setDataWithDateString:(NSString *)inDate withTitle:(NSString *)inTitle withVPath:(NSString*)inPath{
    self.date = inDate;
    self.title = inTitle;
    self.voicePath = inPath;
}
@end
