//
//  MYViewController.h
//  Scan
//
//  Created by iMac on 2021/5/9.
#import <UIKit/UIKit.h>

int my_globle_var = 10;

int age = 10000;

NS_ASSUME_NONNULL_BEGIN

@interface MYViewController : UIViewController

@property (nonatomic, assign)int  age;


@property (nonatomic, assign)NSString *name;

@property (nonatomic, assign)int what;
@end

NS_ASSUME_NONNULL_END
