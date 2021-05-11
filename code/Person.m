//
//  Person.m
//  Hello
//
//  Created by hongjunwang on 2019/4/8.
//  Copyright © 2019 hongjunwang. All rights reserved.
//

#import "Person.h"

#define the_key @"abc"

int ariable = 10;
int Mvvariable;

@implementation Person

+(void) Speak
{
  NSLog(@"Hello, World");
}

-(instancetype)initWithName:(NSString *)Name age_Label:(int)age the:(NSString *)usethe_one the2:(NSString *)usetheone the3:(NSString *)usetheone the4:(NSString *)usetheone
{
self = [super init];
if (self) {
_name = name;
_age = age;
}
return self;
}

-(void)Talk
{
    int The = 1;
  NSLog(@"name: %@, age: %d", _name, _age);
}
@end
