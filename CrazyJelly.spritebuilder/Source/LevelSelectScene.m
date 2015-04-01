//
//  LevelSelectScene.m
//  CrazyJelly
//
//  Created by Jigar Patel on 3/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelSelectScene.h"
#import "GlobalData.h"

@implementation LevelSelectScene{
    GlobalData *Globals;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_bestScoreLabel;
    CCLabelTTF *_successMessageLabel, *_failureMessageLabel;
    CCButton *_l0Button, *_l1Button, *_l2Button, *_l3Button, *_l4Button, *_l5Button, *_nextButton;
    
}
#pragma mark - Initialization
- (void)didLoadFromCCB {
    Globals = [GlobalData sharedInstance];
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", Globals.currentPoints];
    //TODO: BAsed on maxLevelCleared value from NSUserDefaults, enable or disable the levels
    _l1Button.enabled = true;
    _l2Button.enabled = false;
    _l3Button.enabled = false;
    _l4Button.enabled = false;
    _l5Button.enabled = false;
    _l0Button.enabled = false;
    
    //TODO: If last level cleared then only enable next button
    if(Globals.levelCleared){
        _nextButton.enabled = true;
        _successMessageLabel.visible = true;
        _failureMessageLabel.visible = false;
    }else{
        _nextButton.enabled = false;
        _successMessageLabel.visible = false;
        _failureMessageLabel.visible = true;
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)nextLevel{
    if(Globals.currentLevel < 6){
        Globals.currentLevel++;
    }else{
        Globals.currentLevel = 0;
    }
    [self restart];
}
- (void)level1{
    Globals.currentLevel = 1;
    [self restart];
}
- (void)level2{
    Globals.currentLevel = 2;
    [self restart];
}
- (void)level3{
    Globals.currentLevel = 3;
    [self restart];
}
- (void)level4{
    Globals.currentLevel = 4;
    [self restart];
}
- (void)level5{
    Globals.currentLevel = 5;
    [self restart];
}
@end
