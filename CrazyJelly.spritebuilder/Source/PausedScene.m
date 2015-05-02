//
//  PausedScene.m
//  CrazyJelly
//
//  Created by Jigar Patel on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PausedScene.h"

@implementation PausedScene {
}

-(void)resume{
    
    [[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] resume];
}

-(void) exit{
    
    exit(1);
    
}
@end
