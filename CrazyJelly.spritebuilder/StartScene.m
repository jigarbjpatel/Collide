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

}

-(void)play{
    
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.2f];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"HelpScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
}
@end

