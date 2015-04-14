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
    CCButton *_l6Button, *_l1Button, *_l2Button, *_l3Button, *_l4Button, *_l5Button, *_nextButton;
    CCButton *_playAgainButton;
    NSMutableArray *_levelButtons;
    CCLayoutBox *_levelSelectLayoutBox;
    NSUserDefaults *prefs;
}
#pragma mark - Initialization
- (void)didLoadFromCCB {
    Globals = [GlobalData sharedInstance];
    prefs = [NSUserDefaults standardUserDefaults];
    NSInteger highestLevelCleared = [prefs integerForKey:@"highestLevelCleared"];
    
    _scoreLabelValue.string = [NSString stringWithFormat:@"%ld", Globals.currentPoints];
    NSInteger bestScore = [prefs integerForKey:@"bestScore"];
    if(Globals.currentPoints > bestScore){
        bestScore = Globals.currentPoints;
        [prefs setInteger:bestScore forKey:@"bestScore"];
    }
    _bestScoreLabelValue.string = [NSString stringWithFormat:@"%ld", bestScore];

    _levelButtons = [[NSMutableArray alloc] init];
    [_levelButtons addObject:_l1Button];
    [_levelButtons addObject:_l2Button];
    [_levelButtons addObject:_l3Button];
    [_levelButtons addObject:_l4Button];
    [_levelButtons addObject:_l5Button];
    [_levelButtons addObject:_l6Button];
    for(CCButton *button in _levelButtons)
        button.enabled = false;
    
    if(Globals.currentLevel == 0){
        //Begining of game
        _nextButton.enabled = false;
        _playAgainButton.enabled = false;
        _successMessageLabel.visible = false;
        _failureMessageLabel.visible = false;
        
        Globals.currentLevel = highestLevelCleared;
        if(highestLevelCleared == 6){ //Last Level
            _nextButton.enabled = true;
            _playAgainButton.enabled = true;
            for(CCButton *button in _levelButtons)
                button.enabled = true;
        }
    }else{
        if(Globals.levelCleared){
            
            if(highestLevelCleared < Globals.currentLevel){
                [prefs setInteger:Globals.currentLevel forKey:@"highestLevelCleared"];
                highestLevelCleared = Globals.currentLevel;
            }
            
            if(highestLevelCleared != 0){
                _nextButton.enabled = true;
                for(int i = 1; i <= highestLevelCleared; i++){
                    CCButton *button = _levelButtons[i-1];
                    button.enabled = true;
                }
                //Enable new level
                if(highestLevelCleared < 6){
                    CCButton *button = _levelButtons[highestLevelCleared];
                    button.enabled = true;
                }
                if(highestLevelCleared == 6){ //Last Level
                    _successMessageLabel.visible = false;
                    _failureMessageLabel.visible = false;
                }else{
                    _successMessageLabel.visible = true;
                    _failureMessageLabel.visible = false;
                }
            }
        }else{
            
            _nextButton.enabled = false;
            _successMessageLabel.visible = false;
            _failureMessageLabel.visible = true;
            for(int i=1; i<=Globals.currentLevel; i++){
                CCButton *button = _levelButtons[i-1];
                button.enabled = true;
            }
            
        }

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
        Globals.currentLevel = 6; // Last Level
    }
    [self restart];
}
-(void)level6{
    Globals.currentLevel = 6;
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
