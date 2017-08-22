//
//  DownloadACDataViewController.m
//  kookongIphone
//
//  Created by shuaiwen on 16/2/29.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import "DownloadACDataViewController.h"
#import "KookongSDK.h"
#define VIEWWIDTH [UIScreen mainScreen].bounds.size
@interface DownloadACDataViewController ()

@end

@implementation DownloadACDataViewController
{
    KookongSDK *  kookongSDK;
    NSArray * airConditionData;
    NSString * AC_RemoteId;
    NSMutableArray * mutableBtnArray;
}

-(id)init
{
    if (self=[super init]) {
        mutableBtnArray=[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkUserAuthority];
    [self createInputBox];
}

-(void)checkUserAuthority
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AC_DataDownloadSuccess:) name:@"downloadsuccess" object:nil];//注册通知，得到空调的数据
     kookongSDK=[KookongSDK shareKooKongSDK];
}

-(void)AC_DataDownloadSuccess:(NSNotification*)notification
{
    airConditionData=[[NSArray alloc] init];
    NSArray * array=[NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"%@",array);
    NSDictionary * dictionary=array[2];
    NSArray * arr=dictionary[@"irDataList"];
    NSDictionary * dictionary2=arr[0];
    if ([dictionary2[@"type"] intValue]==1) {
         airConditionData=dictionary2[@"keys"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createFunctionButton:dictionary2[@"keys"]];
        });
        
    }
    if ([dictionary2[@"type"] intValue]==2) {
         NSLog(@"**************该数据为有状态空调数据,请打开另一个面板***************");
    }
}

-(void)createFunctionButton:(NSArray * )array
{
    [mutableBtnArray removeAllObjects];
    NSInteger scrollviewHight;
    NSInteger num=array.count%3;
    if (num==0) {
        scrollviewHight=array.count/3;
    }
    else
    {
        scrollviewHight=array.count/3+1;
    }
    UIScrollView * myScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 125,VIEWWIDTH.width,VIEWWIDTH.height-125)];
    myScrollView.contentSize=CGSizeMake(VIEWWIDTH.width, scrollviewHight*60);
    myScrollView.scrollEnabled=YES;
    myScrollView.showsHorizontalScrollIndicator=NO;
    myScrollView.showsVerticalScrollIndicator=YES;
    [self.view addSubview:myScrollView];
    static int btnTag=21000;
    static int i=0;
    static int j=0;
    for (NSDictionary * dict in array) {
        if (i==3) {
            j+=1;
            i=0;
        }
        UIButton * button=[[UIButton alloc] initWithFrame:CGRectMake(i*(VIEWWIDTH.width/3)+7, j*55, (VIEWWIDTH.width)/3-13, 45)];
        [button setTitle:dict[@"fname"] forState:UIControlStateNormal];
        button.layer.cornerRadius=3;
        [button setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [myScrollView addSubview:button];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=btnTag;
        i++;
        btnTag++;
        [mutableBtnArray addObject:button];
    }
    i=0;
    j=0;
}

-(void)buttonClick:(UIButton*)button
{
    NSDictionary * _dict=airConditionData[button.tag-21000];
    NSLog(@"%@",_dict[@"pulse"]);
}

-(void)createInputBox
{
    _textfield=[[UITextField alloc] initWithFrame:CGRectMake(2, 65, 280, 50)];
    _textfield.borderStyle=UITextBorderStyleLine;
    _textfield.layer.cornerRadius=2.f;
    _textfield.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    _textfield.textColor=[UIColor blackColor];
    [self.view addSubview:_textfield];
    
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(283, 65, 90, 50);
    button.layer.cornerRadius=2;
    button.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [button setTitle:@"获得数据" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(downloadACData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)downloadACData:(UIButton * )buttom
{
    AC_RemoteId=[NSString stringWithFormat:@"air%@air",_textfield.text];
    [kookongSDK downloadIRDataByIdWithRemoteId:_textfield.text deviceTypeId:[NSNumber numberWithInt:5]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadsuccess" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
