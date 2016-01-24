//
//  FirstViewController.m
//  TableTest
//
//  Created by wheat on 15/11/20.
//  Copyright © 2015年 wheat. All rights reserved.
//

#import "FirstViewController.h"
#import "FMDB.h"
@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"launcher" ofType:@"db"];
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documents stringByAppendingPathComponent:@"launcher.db"];
    [fm changeCurrentDirectoryPath:documents];
    
    BOOL remove = [fm removeItemAtPath:dbPath error:nil];
    if (remove==YES) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败");
        
    }
    
    BOOL copy = [fm copyItemAtPath:path toPath:dbPath error:nil];
    if (copy==YES) {
        NSLog(@"复制成功");
    }else{
        NSLog(@"复制失败");
 
    }
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    NSArray *appName = @[@"电池",@"网易新闻",@"QQ音乐",@"网易云音乐",@"我的小说",@"付款码",@"酷狗音乐",@"QQ空间",@"QQ浏览器",@"相册",@"VPN",@"电话",@"闹钟",@"今日头条",@"百度"];
    NSArray *bundleIdentifier = @[@"com.tt.set",@"com.netease.news",@"com.tencent.QQMusic",@"com.netease.cloudmusic",@"com.ucweb.iphone.lowversion",@"com.alipay.iphoneclient",@"com.kugou.kugou1002",@"com.tencent.",@"com.tencent.mttlite",@"com.tt.photos",@"com.tt.set",@"com.tt.tel",@"com.tt.clock",@"com.ss.iphone.article.News",@"com.baidu.BaiduMobile"];
    NSArray *urlScheme = @[@"prefs:root=BATTERY_USAGE",@"QQ14AC1032://",@"appid0x5000201://",@"alipayneteasemusic://",@"ucweb-app://ncopennovelbox/",@"alipay://platformapi/startapp?saId=20000056",@"kugouURL://",@"mqzoneopensdk://",@"mqqbrowser://",@"photos-redirect://",@"prefs:root=General&path=VPN",@"mobilephone://",@"clock-alarm://",@"QQ05FA4F2C://",@"bdboxiosqrcode://"];
   NSArray *addgroup = @[@"1",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"1",@"1",@"1",@"1",@"2",@"2"];

    /**批量插入*/
    [db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (int i=0;i<appName.count;i++) {
            NSString *sql = [NSString stringWithFormat:@"insert into DDL_AllSaved_Apps (appName,bundleIdentifier,urlScheme,imageUrl,appGroupType,remark,LocalAppType) values ('%@','%@','%@','%@','%@','1','1')",appName[i],bundleIdentifier[i],urlScheme[i],NULL,addgroup[i]];
            
            BOOL res = [db executeUpdate:sql];
            if (!res){
                NSLog(@"DDL_AllSaved_Apps--insert: (%@) error!",sql);
            }
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    }
    @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    [db executeUpdate:@"delete from DDL_AllSaved_Apps where appName = '获取路线'"];


    FMResultSet *rs = [db executeQuery:@"select *from DDL_AllSaved_Apps where LocalAppType = 1"];
    NSMutableArray *resultArray =[NSMutableArray array];
    NSInteger count = rs.columnCount;
    while ([rs next]) {
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        for (int i = 0; i<count; i++) {
            NSString *name = [rs columnNameForIndex:i];
            id object = [rs objectForColumnIndex:i];
            NSLog(@"name:%@-object%@",name,object);
            [resultDic setObject:object forKey:name];
        }
        [resultArray addObject:resultDic];
    }
    NSLog(@"resultArray:%@",resultArray);
//    NSArray *LocalAppType = @[@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1"];

//    for (int m = 0; m< 15; m++) {
//        NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
//        
//
//    }
    
    FMResultSet *rsUnLoc = [db executeQuery:@"select *from DDL_AllSaved_Apps where LocalAppType > 1"];
    NSMutableArray *resultArrayUnLoc =[NSMutableArray array];
    NSInteger countUnLoc = rsUnLoc.columnCount;
    while ([rsUnLoc next]) {
        NSMutableDictionary *resultDicUnLoc = [NSMutableDictionary dictionary];
        for (int i = 0; i<countUnLoc; i++) {
            NSString *name = [rsUnLoc columnNameForIndex:i];
            id object = [rsUnLoc objectForColumnIndex:i];
            NSLog(@"name:%@-object%@",name,object);
            [resultDicUnLoc setObject:object forKey:name];
        }
        [resultArrayUnLoc addObject:resultDicUnLoc];
    }
    
    NSLog(@"resultArrayUnLoc:%@",resultArrayUnLoc);

    /**删除所有*/
    [db executeUpdate:@"delete from DDL_AllSaved_Apps"];

    /**批量插入*/
    [db beginTransaction];
    BOOL isRollBackSec = NO;
    @try {
        for (int i=0;i<resultArray.count;i++) {
            
            NSDictionary *dic = resultArray[i];
            NSString *sql = [NSString stringWithFormat:@"insert into DDL_AllSaved_Apps (id, appName,bundleIdentifier,urlScheme,imageUrl,appGroupType,remark,LocalAppType) values ('%d','%@','%@','%@','%@','%@','1','1')",i+1,dic[@"appName"],dic[@"bundleIdentifier"],dic[@"urlScheme"],dic[@"imageUrl"],dic[@"appGroupType"]];
            
            BOOL res = [db executeUpdate:sql];
            if (!res){
                NSLog(@"DDL_AllSaved_Apps-111111: (%@) error!",sql);
            }
        }
        
        for (int a=0;a<resultArrayUnLoc.count;a++) {
            NSDictionary *dic = resultArrayUnLoc[a];
            NSString *sql = [NSString stringWithFormat:@"insert into DDL_AllSaved_Apps (id,appName,bundleIdentifier,urlScheme,imageUrl,appGroupType,remark,LocalAppType) values ('%d','%@','%@','%@','%@','%@','%@','%@')",resultArray.count+a+1,dic[@"appName"],dic[@"bundleIdentifier"],dic[@"urlScheme"],dic[@"imageUrl"],dic[@"appGroupType"],dic[@"remark"],dic[@"LocalAppType"]];
            BOOL res = [db executeUpdate:sql];
            if (!res){
                NSLog(@"DDL_AllSaved_Apps-222222222: (%@) error!",sql);
            }
        }
    }
    @catch (NSException *exception) {
        isRollBackSec = YES;
        [db rollback];
    }
    @finally {
        if (!isRollBack) {
            [db commit];
        }
    }

 //insert into DDL_AllSaved_Apps (appName,bundleIdentifier,urlScheme,imageUrl,appGroupType,remark,LocalAppType) values ('微信','bundleIdentifier','urlScheme','imageUrl','1','1','1')
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
