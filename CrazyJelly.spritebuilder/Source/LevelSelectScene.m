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
    CCLabelTTF *_scoreLabelText, *_scoreLabelValue;
    CCLabelTTF *_bestScoreLabelText, *_bestScoreLabelValue;
    CCLabelTTF *_successMessageLabel, *_failureMessageLabel;
    CCButton *_l0Button, *_l1Button, *_l2Button, *_l3Button, *_l4Button, *_l5Button, *_nextButton;
    CCButton *_playAgainButton;
    NSMutableArray *_levelButtons;
    CCLayoutBox *_levelSelectLayoutBox;
}
#pragma mark - Initialization
- (void)didLoadFromCCB {
    Globals = [GlobalData sharedInstance];
    
//    _scoreLabelText.visible = false;
//    _scoreLabelValue.visible = false;
//    _bestScoreLabelText.visible = false;
//    _bestScoreLabelValue.visible = false;
//    _successMessageLabel.visible = false;
//    _failureMessageLabel.visible = false;
//    _playAgainButton.visible = false;
//    _nextButton.visible = false;
    
    _scoreLabelValue.string = [NSString stringWithFormat:@"%ld", Globals.currentPoints];
    //TODO: BAsed on maxLevelCleared value from NSUserDefaults, enable or disable the levels
    _levelButtons = [[NSMutableArray alloc] init];
    [_levelButtons addObject:_l1Button];
    [_levelButtons addObject:_l2Button];
    [_levelButtons addObject:_l3Button];
    [_levelButtons addObject:_l4Button];
    [_levelButtons addObject:_l5Button];
    for(CCButton *button in _levelButtons)
        button.enabled = false;
    
    _l0Button.enabled = true;
    
    //TODO: If last level cleared then only enable next button
    // FOr the infinite level, it is cleared if the current score beats best score
    if(Globals.levelCleared){
        _nextButton.enabled = true;
        _successMessageLabel.visible = true;
        _failureMessageLabel.visible = false;
        for(int i=0; i<=Globals.currentLevel; i++){
            CCButton *button = _levelButtons[i];
            button.enabled = true;
        }
    }else{
        _nextButton.enabled = false;
        _successMessageLabel.visible = false;
        _failureMessageLabel.visible = true;
        for(int i=0; i<Globals.currentLevel; i++){
            CCButton *button = _levelButtons[i];
            button.enabled = true;
        }
    }
//    if(Globals.currentLevel == 0){
//        _successMessageLabel.visible = false;
//        _failureMessageLabel.visible = false;
//    }
    
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
-(void)level0{
    Globals.currentLevel = 0;
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
