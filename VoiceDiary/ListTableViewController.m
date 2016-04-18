//
//  ListTableViewController.m
//  VoiceDiary
//
//  Created by Symonhay M on 2016. 1. 22..
//  Copyright (c) 2016 T. All rights reserved.
//

#import "ListTableViewController.h"
#import "WriteViewController.h"
#import "ReadViewController.h"
#import <sqlite3.h>
#import "Voice.h"
@interface ListTableViewController (){
    NSMutableArray *dataList;
    sqlite3 *db;
    NSString *today;
    NSInteger selectIdx;
}
@property (strong, nonatomic) IBOutlet UITableView *table;

@end

@implementation ListTableViewController
// DB open
- (void)openDB{
	// get the file path of database
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbFilePath = [docPath stringByAppendingPathComponent:@"db.sqlite"];
    
    //check the file of database
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL existFile = [fm fileExistsAtPath:dbFilePath];
    
    
	// open database
    int ret = sqlite3_open([dbFilePath UTF8String], &db);
    NSAssert1(SQLITE_OK == ret, @"Error on opening Database : %s", sqlite3_errmsg(db));
    NSLog(@"Success on Opening Database");
    
    
    if ( NO == existFile){
        
		//Create table into database
        const char *createSQL = "CREATE TABLE 'voicetable' ('writeDate' VARCHAR NOT NULL , 'writeTitle' VARCHAR NOT NULL , 'writeVoice' VARCHAR NOT NULL )";
        char *errorMsg;
        ret = sqlite3_exec(db, createSQL, NULL, NULL, &errorMsg);
        if (ret != SQLITE_OK){
            [fm removeItemAtPath:dbFilePath error:nil];
            NSAssert1(SQLITE_OK== ret, @"Error on creating table : %s", errorMsg);
            NSLog(@"creating table with ret : %d", ret);
        }
    }
  
}

- (void)resolveData{
    [dataList removeAllObjects];
    
	// repare to using query in database
    NSString *queryStr = @"SELECT * FROM voicetable";
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &stmt, NULL);
    
   // NSAssert2(SQLITE_OK == ret, @"Error(%d) on resolving data : %s",ret,sqlite3_errmsg(db));
    
    
	// get the info of all rows
    while (SQLITE_ROW == sqlite3_step(stmt)){
        char *date = (char *)sqlite3_column_text(stmt, 0);
        char *title = (char*)sqlite3_column_text(stmt, 1);
        char *voice = (char *)sqlite3_column_text(stmt, 2);
        
        NSString *nsDate = [NSString stringWithCString:date encoding:NSUTF8StringEncoding];
        NSString *nsTitle = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
        NSString *nsVoice = [NSString stringWithCString:voice encoding:NSUTF8StringEncoding];
        if ( [nsDate isEqualToString:today]){            
			//creat voice object
            Voice *one = [[Voice alloc]init];
            [one setDataWithDateString:nsDate withTitle:nsTitle withVPath:nsVoice];
//            NSLog(@"database test : %@ %@ %@",one.date, one.title, one.voicePath);
            
            [dataList addObject:one];
        }
    }
    sqlite3_finalize(stmt);
    
	//update table
    [self.table reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    dataList = [[NSMutableArray alloc]   init];
    [self openDB];
}

- (void)viewWillAppear:(BOOL)animated{
//    NSLog(@"view will Appear in List Table VC %d-%d-%d",(int)self.nowYear,self.nowMonth,self.nowDate);
    today = [NSString stringWithFormat:@"%04d%02d%02d",(int)self.nowYear,(int)self.nowMonth,(int)self.nowDate];
    [self resolveData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//work the collected cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        selectIdx = indexPath.row;
        ReadViewController *readVC = [self.storyboard instantiateViewControllerWithIdentifier:@"READVC"];
        readVC.nowVoice = [dataList objectAtIndex:indexPath.row];
        readVC.readYear = self.nowYear;
        readVC.readMonth = self.nowMonth;
        readVC.readDate = self.nowDate;
        [self.navigationController pushViewController:readVC animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
        WriteViewController *writeVC = segue.destinationViewController;
        writeVC.writeYear = self.nowYear;
        writeVC.writeMonth = self.nowMonth;
        writeVC.writeDate = self.nowDate;

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0)
        return 1;
    else
        return [dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DATE_TABLE_CELL"];
        cell.userInteractionEnabled = NO;
        NSString *tmpDateString = [NSString stringWithFormat:@"%04d. %02d. %02d.",(int)self.nowYear,(int)self.nowMonth,(int)self.nowDate];
        cell.textLabel.text = tmpDateString;
        return cell;
    }
    else if(indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LIST_TABLE_CELL"];
        Voice *tmp = [dataList objectAtIndex:indexPath.row];
        cell.textLabel.text = tmp.title;
        return  cell;
    }
    // Configure the cell...
    return nil;
}
@end
