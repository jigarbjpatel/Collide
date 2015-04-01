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
    CCScene *gameplayScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
}

@end