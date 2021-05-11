//
//  Person.h
//  Hello
//
//  Created by hongjunwang on 2019/4/8.
//  Copyright © 2019 hongjunwang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

int globle_person = 10;
// NOLINTNEXTLINE
@interface Person : NSObject
{
  NSString *_name;
  int _age;
}

@property (nonatomic, assign)NSInteger    *theCount;

+(void)personSpeak;

-(instancetype)initWithName:(NSString *)name age:(int)age;
-(void)personTalk;

@end

NS_ASSUME_NONNULL_END
