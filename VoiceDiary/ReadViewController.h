//
//  ReadViewController.h
//  VoiceDiary
//
//  Created by Symonhay M on 2016. 1. 22..
//  Copyright (c) 2016 T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Voice.h"
@interface ReadViewController : UIViewController
@property Voice *nowVoice;
@property NSInteger readYear;
@property NSInteger readMonth;
@property NSInteger readDate;
@end
