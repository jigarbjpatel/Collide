//
//  HelpScene.m
//  CrazyJelly
//
//  Created by Jigar Patel on 3/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "HelpScene.h"

@implementation HelpScene{

}

- (void)didLoadFromCCB {

}

-(void)loadGame{
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.2f];

    CCScene *gameplayScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
    
}

@end