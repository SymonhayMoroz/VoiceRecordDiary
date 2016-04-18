//
//  WriteViewController.m
//  VoiceDiary
//
//  Created by Symonhay M on 2016. 1. 22..
//  Copyright (c) 2016 T. All rights reserved.
//

#import "WriteViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <sqlite3.h>

@interface WriteViewController ()<AVAudioRecorderDelegate>{
    NSString *voiceFileName;
    AVAudioRecorder *recorder;
    NSTimer *timer;
    NSInteger progressBarTmp;
    sqlite3 *db;
    int dy;
}
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation WriteViewController




- (void)openDB{
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbFilePath = [docPath stringByAppendingPathComponent:@"db.sqlite"];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm fileExistsAtPath:dbFilePath];
    
    
    int ret = sqlite3_open([dbFilePath UTF8String], &db);
    NSAssert1(SQLITE_OK == ret, @"Error on opening Database : %s", sqlite3_errmsg(db));
    NSLog(@"Success on Opening Database");
}

- (void)updateProgress:(NSTimer *)timer{
    progressBarTmp++;
 //   NSLog(@"timer Test : %d",progressBarTmp/300);
    self.progress.progress = ((float)recorder.currentTime / 50);
}


- (NSString *)getPullPath:(NSString *)fileName{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:fileName];
}


- (void)startRecording{
    

    NSLog(@"start Recording");
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"The Current Time is %@",[dateFormatter stringFromDate:now]);
    voiceFileName = [NSString stringWithFormat:@"%04d-%02d-%02d-%@.caf",(int)self.writeYear,(int)self.writeMonth,(int)self.writeDate,[dateFormatter stringFromDate:now]];
    NSString *filePath = [self getPullPath:[NSString stringWithFormat:@"%04d-%02d-%02d-%@.caf",(int)self.writeYear,(int)self.writeMonth,(int)self.writeDate,[dateFormatter stringFromDate:now]]];
    NSLog(@"recording Path : %@",filePath);
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [setting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [setting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    NSError *error;
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    recorder.delegate = self;

    if ([recorder prepareToRecord]){
        
        self.statusLabel.text=@"Recording...";
        
        [recorder recordForDuration:50];
        
        
        progressBarTmp = 0;
        [timer invalidate];
        timer = nil;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        
    }
}

- (void)stopRecording{
    NSLog(@"stop Recording");
    
    [recorder stop];
    
    [timer invalidate];
    timer = nil;
}

- (IBAction)startRecording:(id)sender{
    [self startRecording];
}

- (IBAction)stopRecording:(id)sender{
    [self stopRecording];
}
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    // TODO
    self.statusLabel.text = @"Ready";
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    // TODO
    
}
- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"Write VC : %d-%d-%d",(int)self.writeYear, (int)self.writeMonth, (int)self.writeDate);
    NSString *tmpstring = [NSString stringWithFormat:@"%d. %d. %d",(int)self.writeYear,(int)self.writeMonth, (int)self.writeDate];
    self.dateLabel.text = tmpstring;
    
    
    self.titleTextField.text = @"";
    voiceFileName = @"";
 
}
- (IBAction)clickWriteBtn:(id)sender {
  
    
    
    if([self.titleTextField.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Missing Something" message:@"You have to write Title" delegate:nil cancelButtonTitle:@"OKay" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        
    }
    else if([voiceFileName isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Missing Something" message:@"You have to record Voice" delegate:nil cancelButtonTitle:@"OKay" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
    else{
        NSString *writeDate = [NSString stringWithFormat:@"%04d%02d%02d",(int)self.writeYear,(int)self.writeMonth,(int)self.writeDate];
        NSString *writeTitle = [NSString stringWithString:self.titleTextField.text];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO voicetable (writeDate,writeTitle,writeVoice) VALUES ('%@','%@','%@')",writeDate,writeTitle,voiceFileName];
        NSLog(@"sql : %@",sql);
        
        char *errMsg;
        sqlite3_exec(db, [sql UTF8String], NULL, nil, &errMsg);
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self openDB];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
