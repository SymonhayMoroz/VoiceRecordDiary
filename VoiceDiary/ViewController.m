//
//  ViewController.m
//  VoiceDiary
//
//  Created by Symonhay M on 2016. 1. 22..
//  Copyright (c) 2016 T. All rights reserved.
//

#import "ViewController.h"
#import "ListTableViewController.h"
@interface ViewController ()<UICollectionViewDataSource>{
    NSInteger year;
    NSInteger month;
    NSInteger startDate;
    NSInteger clickedDate;
}
@property (weak, nonatomic) IBOutlet UILabel *yearAndMonthButtonLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collection;

@end

@implementation ViewController


// 0 : Sun 1: Mon 2: Tus 3: Wen 4: Thr 5: Fra 6: Sat
- (NSString *)showDayString:(NSInteger)inNum{
    NSString *tmpString = [NSString stringWithFormat:@""];
    switch ((int)inNum) {
        case 0:
            tmpString = [tmpString stringByAppendingString:@"SUN"];
            break;
        case 1:
            tmpString = [tmpString stringByAppendingString:@"MON"];
            break;
        case 2:
            tmpString = [tmpString stringByAppendingString:@"TUS"];
            break;
        case 3:
            tmpString = [tmpString stringByAppendingString:@"WED"];
            break;
        case 4:
            tmpString = [tmpString stringByAppendingString:@"TUR"];
            break;
        case 5:
            tmpString = [tmpString stringByAppendingString:@"FRI"];
            break;
        case 6:
            tmpString = [tmpString stringByAppendingString:@"SAT"];
            break;
        default:
            break;
    }
    return tmpString;
}


- (void)setYear:(NSInteger)inYear setMonth:(NSInteger)inMonth{
    NSString *tmpString = [NSString stringWithFormat:@"%04d.%02d.",(int)inYear,(int)inMonth];
    
    [self.yearAndMonthButtonLabel setFont:[UIFont fontWithName:@"gnyrwn965" size:10]];
    
    startDate = [self calculateDayWithYear:year withMonth:month withDate:1];
    //  startDate++;
    startDate %= 7;
   // NSLog(@"%d - %d - %d ",year,month,startDate);
    self.yearAndMonthButtonLabel.text = tmpString;
}




- (NSInteger)calculateDayWithYear:(NSInteger)inYear withMonth:(NSInteger)inMonth withDate:(NSInteger)inDate{
    if (inMonth <= 2){
        --inYear;
        inMonth += 12;
    }
    
    NSInteger resultDay = ( (21*((int)inYear/100)/4) + (5*((int)inYear%100)/4) + (26*((int)inMonth+1)/10) + (int)inDate - 1 ) % 7;
    return resultDay;
}


- (IBAction)clickedButton:(id)sender {
    UIButton *tmp = [UIButton alloc];
    tmp = sender;
    NSString *tmpString = [NSString alloc];
    tmpString = [tmp.superview.subviews[1] text];
    clickedDate = [tmpString integerValue];

    
    NSLog(@"day is %@",tmpString);
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ListTableViewController *ltVC = segue.destinationViewController;
    ltVC.nowYear = year;
    ltVC.nowMonth = month;
    ltVC.nowDate = clickedDate;
}


- (IBAction)clickedBeforeButton:(id)sender {
    month--;
    if(month == 0){
        year--;
        month = 12;
    }
    
    
    [self setYear:year setMonth:month];
    [self.collection reloadData];
}

- (IBAction)clickedAfterButton:(id)sender {
    month++;
    if(month == 13){
        year++;
        month = 1;
    }
    [self setYear:year setMonth:month];
    [self.collection reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if((int)indexPath.row < 7){
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DAY_CELL" forIndexPath:indexPath];
        UILabel *dayLabel = (UILabel *)[cell viewWithTag:1];
        dayLabel.text = [self showDayString:indexPath.row];
        return cell;
    }
    else{
        
        NSInteger writeDate = indexPath.row - 6 - startDate;
        NSString *writeDateStr = [NSString alloc];
        
      
        
        if((writeDate <= 0) || (writeDate > 31)){
            
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BLANK_CELL" forIndexPath:indexPath];
            
           // writeDateStr = @" ";
            //BLANK_CELL
            return cell;
        
        }
        else{
            
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DATE_CELL" forIndexPath:indexPath];
            UILabel *dateLabel = (UILabel *)[cell viewWithTag:2];
            
            writeDateStr = [NSString stringWithFormat:@"%d",(int)writeDate];
            
            dateLabel.text = writeDateStr;
            return  cell;
        }
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12 )){
        return 7 + startDate + 31;
    }
    else if(month == 2){
        if(((year % 4) == 0) && ((year % 100 ) != 0) ){
            return 7 + startDate + 29;
        }
        else{
            return 7 + startDate + 28;
        }
    }
    else {
        return 7 + startDate + 30;
    }
    return 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    year = 2016;
    month = 1;
    [self setYear:year setMonth:month];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
