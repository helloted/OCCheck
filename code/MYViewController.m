//
//  MYViewController.m
//  Scan
//
//  Created by iMac on 2021/5/9.
//  Copyright © 2021 iMac. All rights reserved.
//

#import "MYViewController.h"
#import "Person.h"
// #import <UIKit/UIKit.h>

#define kTheKey  @"TheKey"
        int globleVar = 1001;

@interface MYViewController ()

@property (nonatomic, strong)NSString     *theName;

@property (nonatomic, assign)NSInteger    *theAge;


@end

@implementation MYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    startBtn.frame = CGRectMake(100, 200, 50, 50);
    [self.view addSubview:startBtn];
    [self.view addSubview:startBtn];
    [startBtn addTarget:self action:@selector(videoTest) forControlEvents:UIControlEventTouchUpInside];
    globleVar = 20;
}

- (void)compareWithName:(NSString *)myName{
    
}

- (void)videoTest{
int testAge = 10;
}

- (NSString *)buildName{
    NSString * name = @"jello";
    return name;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
