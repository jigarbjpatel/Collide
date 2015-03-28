//
//  StartScene.m
//  CrazyJelly
//
//  Created by Jigar Patel on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "StartScene.h"
@implementation StartScene {

}

-(void)play{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end

