//
//  GlobalData.m
//  CrazyJelly
//
//  Created by Jigar Patel on 3/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalData.h"

@implementation GlobalData

static GlobalData *sharedInstance = nil;

@synthesize currentLevel;
@synthesize currentPoints;
@synthesize levelCleared;

+(GlobalData *)sharedInstance{

    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(id) init{
    if (self = [super init]) {
        currentLevel = 0;
        currentPoints = 0;
        levelCleared = false;
    }
    return self;
}

@end