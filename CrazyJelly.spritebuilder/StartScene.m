//
//  StartScene.m
//  CrazyJelly
//
//  Created by Jigar Patel on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "StartScene.h"
#import "GlobalData.h"

@implementation StartScene {

//    GlobalData *Globals;
}

-(void)play{
//    Globals = [GlobalData sharedInstance];
//    Globals.currentLevel = 1;
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"HelpScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end

