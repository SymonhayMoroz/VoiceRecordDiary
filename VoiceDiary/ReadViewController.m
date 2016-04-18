//
//  ReadViewController.m
//  VoiceDiary
//
//  Created by Symonhay M on 2016. 1. 22..
//  Copyright (c) 2016 T. All rights reserved.
//

#import "ReadViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ReadViewController () <AVAudioPlayerDelegate>{
    AVAudioPlayer *player;
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UIButton *ListenBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ReadViewController
// update progress
- (void)updateProgress:(NSTimer *)timer{
    self.progress.progress = player.currentTime / player.duration;
}

//replay file
- (void)playMusic:(NSURL *)url{
    if (nil != player) {
        if( [player isPlaying]){
            [player stop];
        }
                
		//init player
        player = nil;
                
		// timer work
        [timer invalidate];
        timer = nil;
    }
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    
    if ([player prepareToPlay]){
        [player play];
        self.statusLabel.text = @"Playing...";
        // 타이머 시작
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
}

// AVAudioPlayerDelegate - finish replay
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    self.statusLabel.text=@"Ready";
    [timer invalidate];
    timer =nil;
}

// get the file path of document folder
- (NSString *)getPullPath:(NSString *)fileName{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:fileName];
}

// AVAudioPlayerDelegate - replay error
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    // issue 
}

- (IBAction)listenVoice:(id)sender {
    NSString *fileName = self.nowVoice.voicePath;
    NSLog(@"hahahahah : %@",fileName);
    NSString *pullFilePath = [self getPullPath:fileName];
    NSLog(@"pull Path : %@",pullFilePath);
    
    NSURL *urlForPlay = [NSURL fileURLWithPath:pullFilePath];
    NSLog(@"test : %@",urlForPlay);
    [self playMusic:urlForPlay];
}

- (void)viewWillAppear:(BOOL)animated{
    self.dateLabel.text = [NSString stringWithFormat:@"%04d.%02d.%02d",self.readYear,self.readMonth,self.readDate];
    self.titleLabel.text = self.nowVoice.title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryAmbient error:&error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
