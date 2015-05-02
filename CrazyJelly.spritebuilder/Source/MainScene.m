#import "MainScene.h"
#import "Character.h"
#import "Ball.h"
#import "GlobalData.h"

#define ARC4RANDOM_MAX      0x100000000
#define ROW_SIZE    3
#define TOTAL_COLORS 6
#define MAX_ROWS_THAT_CAN_BE_SKIPPED 5
#define MAX_SPECIAL_BALLS 4
#define MAX_MUSHROOMS_AVAILABLE 4
#define MAX_BALLS_IN_ROW 3
#define SPECIALBALL_FREQUENCY 15
#define MUSHROOM_FREQUENCY 5
#define START_MUSHROOM_LEVEL 30

typedef enum  {EASY, MEDIUM, TOUGH, RANDOM} RowType;

static NSString *ballColors[TOTAL_COLORS] = {@"Red", @"Blue",@"Yellow",@"Green",@"Pink",@"White"};
static NSString *specialBallColors[MAX_SPECIAL_BALLS] = {@"Blast", @"Lightning",@"Life",@"Double"};
static CGFloat _ballPositionsX[MAX_BALLS_IN_ROW] = { 0.12, 0.5, 0.88};

@implementation MainScene{
    
    GlobalData *Globals;
    CCSprite *_character;
    NSMutableArray *_balls;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_lifeLabel;
    CCLabelTTF *_skipRowsLabel;
    CCPhysicsNode* _physicsNode;
    CGFloat _levelSpeed;
    CGSize _screenSize;
    int _lives;
    long _points;
    float _timeSinceLastRowAdded;
    int _rowsAddedSinceLastCollision;
    BOOL _gameOver;
    CCButton *_restartButton;
    int _lastRowBallColors[ROW_SIZE];
    RowType _lastRowType;
    int _lastSpecialBallColor;
    int _pointsMultiplier;
    
    int _levelScores[6];
    CCSprite *_playImage, *_pauseImage;

    
    CCLabelTTF *_targetMessageLabel;
    NSString *_helpMessage;
    
    int _lastMushroomColor;
    CCNode *_onboardingNode;
    CCLabelTTF *_helpMessageLabel;
    BOOL _ballWrongCollisionMsgShown,_ballRightCollisionMsgShown,
    _collideMsgShown, _moveJellyMsgShown, _skipRowsMsgShown, _specialBallMsgShown,
    _mushroomMsgShown;
}
#pragma mark - Initialization
- (void)didLoadFromCCB {
    Globals = [GlobalData sharedInstance];

    _balls = [[NSMutableArray alloc] init];
    _gameOver = false;
    _points = 0;
    _pointsMultiplier = 1;
    _lives = 3;
    _timeSinceLastRowAdded = 0.0f;
    _rowsAddedSinceLastCollision = 0;
    _levelSpeed = 0.8f;
    _screenSize = [CCDirector sharedDirector].viewSize;
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _physicsNode.debugDraw = false;
    
    _scoreLabel.visible = true;
    _lifeLabel.visible = true;
    _skipRowsLabel.visible = false;
    _lastRowType = EASY;
    for(int i=0; i<ROW_SIZE; i++)
        _lastRowBallColors[i] = i;
    _lastSpecialBallColor = -1;
    _lastMushroomColor = -1;

    _levelScores[0] = -1;
    _levelScores[1] = 10;
    _levelScores[2] = 20;
    _levelScores[3] = 30;
    _levelScores[4] = 50;
    _levelScores[5] = 100;

    
    if(Globals.currentLevel == 1)
        _pauseImage.visible = false;
    else
        _pauseImage.visible = true;
    
    [self setTargetMessage];
    //Wait for user to read target message
    if(Globals.currentLevel != 0)
        [self performSelector:@selector(initialize) withObject:nil afterDelay:1.5];
    else
        [self initialize]; // For infinite level, initialize immediately
    
    Globals.levelCleared = false;
    
    _ballWrongCollisionMsgShown = false;
    _ballRightCollisionMsgShown = false;
    _collideMsgShown = false;
    _moveJellyMsgShown = false;
    _skipRowsMsgShown = false;
    _specialBallMsgShown = false;
    _mushroomMsgShown = false;
}
-(void)initialize{
    
    _targetMessageLabel.visible = false;
    //Initialize the character
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX); //value between 0 and 1
    int index = (int)(random * 10.0) % TOTAL_COLORS;
    [self addNewCharacter:ballColors[index] xPosition:0.5f];
    
    //Initialize the Balls
    for (int i=0; i < 3; i++) {
        [self addNewRow];
        //Push the row down
        for(CCSprite* sprite in _balls){
            sprite.position = ccp(sprite.position.x, sprite.position.y + 100);
        }
    }
    [self addNewRow];
    
    
    _onboardingNode.visible = false;
    CCNode *onboarding1Scene = [CCBReader loadAsScene:@"Onboarding1" owner:self];
    [_onboardingNode addChild: onboarding1Scene];
    
    if(Globals.currentLevel == 1 && !_moveJellyMsgShown){
        
        _helpMessage = @"Move the Jelly left and right \nby tapping anywhere on screen.";
        
        [_helpMessageLabel setString:_helpMessage];
        _onboardingNode.visible = true;
        
        [[CCDirector sharedDirector] pause];
        _moveJellyMsgShown = true;
    }
}
-(void)addNewCharacter:(NSString *)spriteColor xPosition:(CGFloat)xPos{
    if(spriteColor == NULL)
        return;
    NSString* spriteName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Characters/", spriteColor, @".png"];
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteName];
    sprite.positionType = CCPositionTypeMake(CCPositionTypeNormalized.xUnit,
                                             CCPositionTypePoints.yUnit, CCPositionReferenceCornerBottomLeft);
    [sprite setUserObject:spriteColor];

    sprite.position = ccp(xPos, 50);
    sprite.zOrder = 100;
    
    CGRect rect = CGRectMake(sprite.position.x, sprite.position.y - sprite.contentSize.height + 10,
                             sprite.contentSize.width, sprite.contentSize.height);
    
    sprite.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0 ];
//    sprite.physicsBody.type = CCPhysicsBodyTypeStatic;
    sprite.physicsBody.type = CCPhysicsBodyTypeKinematic;
    sprite.physicsBody.collisionType = @"character";
    [_physicsNode addChild:sprite];
    
    _character = sprite;
    CCActionFadeIn *fadeInAction = [CCActionFadeIn actionWithDuration:0.25];
    [_character runAction:fadeInAction];
}

- (void)addNewBall:(NSString *)spriteColor xPosition:(CGFloat)xPos{
    
    if(spriteColor == NULL)
        return;
    
    NSString* spriteName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Balls/", spriteColor, @".png"];
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteName];
    sprite.positionType = CCPositionTypeMake(CCPositionTypeNormalized.xUnit,
                                             CCPositionTypePoints.yUnit, CCPositionReferenceCornerTopLeft);
    [sprite setUserObject:spriteColor];
  
    sprite.position = ccp(xPos, 86);
    sprite.zOrder = 100;
    CGPoint center = CGPointMake(sprite.position.x + sprite.contentSize.width/2,
                                 sprite.position.y - sprite.contentSize.height + 7);
    sprite.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:32.0
                                                     andCenter:center];
    sprite.physicsBody.collisionType = @"ball";
    [_physicsNode addChild:sprite];
    
    [_balls addObject:sprite];
}
- (void)addNewMushroom:(NSString *)spriteColor xPosition:(CGFloat)xPos{
    
    if(spriteColor == NULL)
        return;
    
    NSString* spriteName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Mushrooms/", spriteColor, @".png"];
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteName];
    sprite.positionType = CCPositionTypeMake(CCPositionTypeNormalized.xUnit,
                                             CCPositionTypePoints.yUnit, CCPositionReferenceCornerTopLeft);
    [sprite setUserObject:spriteColor];
 
    sprite.position = ccp(xPos, 86);
    sprite.zOrder = 100;
    CGPoint center = CGPointMake(sprite.position.x + sprite.contentSize.width/2,
                                 sprite.position.y - sprite.contentSize.height + 7);
    sprite.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:32.0
                                                     andCenter:center];
    sprite.physicsBody.collisionType = @"mushroom";
    [_physicsNode addChild:sprite];
    
    [_balls addObject:sprite];
}
-(void)addNewRow{
    int randomPosition = -1;
    int * nextRowColors = [self getNextRowColors];
    //Last Row Ball Colors array is not aware of any special balls
    for(int i = 0; i < MAX_BALLS_IN_ROW; i++)
        _lastRowBallColors[i] = nextRowColors[i];
    bool specialBall = false;
    bool mushroomBall = false;
    
    //Special ball logic...
    //At every X points introduce a special ball
    if((_points != 0) && ((_points % SPECIALBALL_FREQUENCY) == 0)){
        specialBall = true;
    }else if((_points > START_MUSHROOM_LEVEL) && ((_points % MUSHROOM_FREQUENCY) == 0)){
        //Have mushrooms one in every X rows
        mushroomBall = true;
    }
    if(specialBall || mushroomBall){
        //Generate a random number which determines which ball position will have special ball
        randomPosition = (int)(((double)arc4random() / ARC4RANDOM_MAX) * MAX_BALLS_IN_ROW);
    }
    
    //If random is -1 then there is no special ball to be added
    for(int i = 0; i < MAX_BALLS_IN_ROW; i++){
        if(randomPosition == i){
            if(specialBall){
                //Determine which special ball to use
                _lastSpecialBallColor = (_lastSpecialBallColor + 1) % MAX_SPECIAL_BALLS;
                [self addNewBall:specialBallColors[_lastSpecialBallColor] xPosition:_ballPositionsX[i]];
                
                if(Globals.currentLevel == 2 && !_specialBallMsgShown){
                    _helpMessage = @"Collect as many special balls \nand power ups coming on your way!!!";
                    
                    [[CCDirector sharedDirector] pause];
                    [_helpMessageLabel setString:_helpMessage];
                    _onboardingNode.visible = true;
                    
                    _specialBallMsgShown = true;
                }
                
            }else{
                
                if(Globals.currentLevel > 3 && Globals.currentLevel < 6 && !_mushroomMsgShown){
                    _helpMessage = @"Mushrooms behave exactly opposite to balls\n Hit same color mushrooms to get 2X points\nBut different colored mushroom will take life!!!";
                    
                    [[CCDirector sharedDirector] pause];
                    [_helpMessageLabel setString:_helpMessage];
                    _onboardingNode.visible = true;
                    
                    _mushroomMsgShown = true;
                }
                
                _lastMushroomColor = (_lastMushroomColor + 1) % MAX_MUSHROOMS_AVAILABLE;
                [self addNewMushroom:ballColors[_lastMushroomColor] xPosition:_ballPositionsX[i]];
                
            }
        }else{
            [self addNewBall:ballColors[nextRowColors[i]] xPosition:_ballPositionsX[i]];
        }
    }
    
    free(nextRowColors);
}
//Returns array of indexes (pointing to ballColors array)
//NOTE: Caller must free the memory
-(int *)getNextRowColors{
    
    int * nextRowColors = malloc(sizeof(int) * ROW_SIZE);
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX) * 10.0; //value between 0 and 10
    
    if(_lastRowType == EASY){
        //Get Medium Row i.e.
        //One of the balls color should repeat as previous row
        //but all 3 balls should not have same color
        int positionForColorDuplication = (int)(random) % ROW_SIZE;
        nextRowColors[positionForColorDuplication] = _lastRowBallColors[positionForColorDuplication];
        for(int i = 0; i < ROW_SIZE; i++){
            if(positionForColorDuplication != i){
                int index = (int)(random) % TOTAL_COLORS;
                while(index == _lastRowBallColors[positionForColorDuplication]){
                    random = ((double)arc4random() / ARC4RANDOM_MAX) * 10.0;
                    index = (int)(random) % TOTAL_COLORS;
                }
                nextRowColors[i] = index;
            }
        }
        _lastRowType = MEDIUM;
        
    }else if(_lastRowType == MEDIUM){
        //Get random row
        for(int i = 0; i < ROW_SIZE; i++){
            random = ((double)arc4random() / ARC4RANDOM_MAX) * 10.0;
            nextRowColors[i] = (int)random % TOTAL_COLORS;
        }
        _lastRowType = RANDOM;
        
    }else if(_lastRowType == RANDOM){
        //Get Tough Row i.e.
        //One of the balls color should repeat as previous row at position where character is standing
        //and rest 2 are random
        
        int positionForColorDuplication = 0;
        if(_character.position.x > 0.66 )
            positionForColorDuplication = 2;
        else if(_character.position.x > 0.33 && _character.position.x < 0.66)
            positionForColorDuplication = 1;
        // NSLog(@"Position: %f, Duplicate: %d", _character.position.x, positionForColorDuplication);
        nextRowColors[positionForColorDuplication] = _lastRowBallColors[positionForColorDuplication];
        for(int i = 0; i < ROW_SIZE; i++){
            if(positionForColorDuplication != i){
                random = ((double)arc4random() / ARC4RANDOM_MAX) * 10.0;
                nextRowColors[i] = (int)(random) % TOTAL_COLORS;
            }
        }
        
        _lastRowType = TOUGH;
        
    }else{
        //Get Easy Row i.e.
        //All the ball colors are different and none of them is same as last row
        int i=0,j=0,k=0;
        BOOL usedColor = false;
        for(i=0; i<ROW_SIZE; i++){
            for(; j<TOTAL_COLORS; j++){
                usedColor = false;
                for(k=0; k<ROW_SIZE; k++){
                    if(j == _lastRowBallColors[k]){
                        usedColor = true;
                        break;
                    }
                }
                if(usedColor == false){
                    nextRowColors[i] = j;
                    j++;
                    break;
                }
            }
        }
        _lastRowType = EASY;
    }
    
    return nextRowColors;
}
#pragma mark - Game Loop
- (void)update:(CCTime)delta{

    if(!_gameOver){
        
        _timeSinceLastRowAdded += delta;
        
        if(_timeSinceLastRowAdded > _levelSpeed){
           
            
            for(CCSprite* sprite in _balls){
                sprite.position = ccp(sprite.position.x, sprite.position.y + 10);
            }
            _timeSinceLastRowAdded = 0.0f;
            
            //If sprites have moved out then remove them and add new
            NSMutableArray *offScreenBalls = nil;
            
            for (CCNode *ball in _balls) {
                if(ball.position.y > (_screenSize.height - 50)){
                    if (!offScreenBalls) {
                        offScreenBalls = [NSMutableArray array];
                    }
                    [offScreenBalls addObject:ball];
                }
            }
            
            for (CCNode *ballToRemove in offScreenBalls) {
                
                [ballToRemove removeFromParent];
                [_balls removeObject:ballToRemove];
                
            }
            
            if(offScreenBalls.count > 0){

                if(Globals.currentLevel == 1 && !_collideMsgShown){
                    
                    _helpMessage = @"Collide with a ball of any color\n other than Jelly's color!!!";
                    
                    [[CCDirector sharedDirector] pause];
                    
                    [_helpMessageLabel setString:_helpMessage];
                    
                    _onboardingNode.visible = true;
                    
                    _collideMsgShown = true;
                }
                
                [self addNewRow];
                
                _rowsAddedSinceLastCollision++;
                
                if(_rowsAddedSinceLastCollision > 1){
                    //Start the timer and check if user loses life
                    
                    _skipRowsLabel.string = [NSString stringWithFormat:@"%d", MAX_ROWS_THAT_CAN_BE_SKIPPED - _rowsAddedSinceLastCollision];
                    _skipRowsLabel.visible = true;
                    //Scale the character down to let user know that it will die soon
                    double scaleBy = (1.0 - (double)((double)_rowsAddedSinceLastCollision / (double)MAX_ROWS_THAT_CAN_BE_SKIPPED)) + 0.10;
                    id scaleDownAction = [CCActionEaseInOut
                                          actionWithAction:[CCActionScaleTo actionWithDuration:0.1 scaleX:scaleBy scaleY:scaleBy]
                                          rate:2.0];
                    id blinkAction = [CCActionBlink actionWithDuration:0.1 blinks:1];
                    
                    [_character runAction:scaleDownAction];
                    [_skipRowsLabel runAction:blinkAction];
                    
                    
                    if(_rowsAddedSinceLastCollision >= MAX_ROWS_THAT_CAN_BE_SKIPPED){
                        //Character did not collide for long...it dies
                        _rowsAddedSinceLastCollision = 0;
                        _lives--;
                        
                        _lifeLabel.string = [NSString stringWithFormat:@"%d", _lives];
                        _skipRowsLabel.visible = false;
                        
                        
                        [self bounceCharacter];

                        if(_lives > 0 && Globals.currentLevel == 1 && !_skipRowsMsgShown){
                            
                            _helpMessage = @"Oh no! Jelly just lost one life :(\nJelly can't live long without colliding.\nKeep monitoring the timer at top right.";
                            [[CCDirector sharedDirector] pause];
                            
                            [_helpMessageLabel setString:_helpMessage];
                            _onboardingNode.visible = true;
                            
                            _skipRowsMsgShown = true;
                        }
                        
                        if(_lives == 0)
                            [self gameOver];

                    }
                }
            }
        }
    }
}
#pragma mark - User Interaction
- (void)touchBegan:(CCTouch *)touch
         withEvent:(CCTouchEvent *)event {
    // get the x location of touch and move the character there.
    if(!_gameOver){
        
        _skipRowsLabel.visible = false;
        
        CGPoint touchLocation = [touch locationInNode:self];
        //_character.position = ccp(touchLocation.x/_screenSize.width,_character.position.y);
        
        //Check if Pause/Play image has been cicked
        CGRect playPauseRect =  [_pauseImage boundingBox];
        
        if (CGRectContainsPoint(playPauseRect,touchLocation)){
            
            CCScene *pausedScene = [CCBReader loadAsScene:@"PausedScene"];
            [[CCDirector sharedDirector] pushScene:pausedScene];
        
        }else if (!self.paused){
            
            if(touchLocation.x < (_screenSize.width * .12f + 35))
                _character.position = ccp(.12f, _character.position.y);
            else if(touchLocation.x > (_screenSize.width * .12f + 35) && touchLocation.x < (_screenSize.width * .5f - 35))
                _character.position = ccp(.31f, _character.position.y);
            else if(touchLocation.x > (_screenSize.width * .5f - 35) && touchLocation.x < (_screenSize.width * .5f + 35))
                _character.position = ccp(.5f, _character.position.y);
            else if(touchLocation.x > (_screenSize.width * .5f + 35) && touchLocation.x < (_screenSize.width * .88f - 35))
                _character.position = ccp(.69f, _character.position.y);
            else if(touchLocation.x > (_screenSize.width * .88f - 35))
                _character.position = ccp(.88f, _character.position.y);
        }
    }
}
#pragma mark - Collision Handling
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                     character:(CCNode *)character
                          ball:(CCNode *)ball {
    
    _rowsAddedSinceLastCollision = 0;
    _skipRowsLabel.visible = false;
    
    NSString* ballColor = (NSString *)ball.userObject;
    NSString* characterColor = (NSString *)character.userObject;
    
    if([ballColor isEqualToString:characterColor]){
        
        _lives--;
        
        [self bounceCharacter];
        
        [ball removeFromParent];
        
        if(_lives == 0)
            [self gameOver];

        
        if(Globals.currentLevel == 1 && _lives > 0){
            if(!_ballWrongCollisionMsgShown){
                _helpMessage = @"Oh no! Jelly just lost one life :(\nDo not collide with ball\n of same color as Jelly";
                [[CCDirector sharedDirector] pause];
            
                [_helpMessageLabel setString:_helpMessage];
                _onboardingNode.visible = true;
                
                _ballWrongCollisionMsgShown = true;
            }
        }

        
    }else if([self getSpecialBallIndex:ballColor] != -1){
        //Special Ball Handling
        switch (_lastSpecialBallColor) {
            case 0://Blast
                //Remove all balls of same color as Jelly
                for(CCSprite *ball in _balls){
                    
                    NSString *ballColor = (NSString *)ball.userObject;
                    
                    if([ballColor isEqualToString:characterColor]){
                        
                        [self ballRemoved:ball];
                        
                        _points += _pointsMultiplier;
                    }
                }
                
                break;
            case 1://Lightning
                //Remove all balls from screen
                for(CCSprite* ball in _balls){
                    
                    [self ballRemoved:ball];
                    
                    _points += _pointsMultiplier;
                }
               
                break;
                
            case 2://Life
                _lives++;
                break;
                
            case 3://Double Points rate - 2x
                _pointsMultiplier = _pointsMultiplier * 2;
                break;
                
            default:
                break;
        }

        [self ballRemoved:ball];
        
    }else{
        
        _points += _pointsMultiplier;
        
        if(Globals.currentLevel == 1){
            if(!_ballRightCollisionMsgShown){
                _helpMessage = [NSString stringWithFormat:@"%@%@", @"Yes! Got one point :)\nNotice the color of Jelly.\nIt changed to ",
                                ballColor];

                [[CCDirector sharedDirector] pause];
                [_helpMessageLabel setString:_helpMessage];
                _onboardingNode.visible = true;
                
                _ballRightCollisionMsgShown = true;
            }
        }
        
        
        //Check the level and stop the game if required
        if(Globals.currentLevel != 6 && _points >= (long)_levelScores[Globals.currentLevel] ) {
            Globals.levelCleared = true;
            [self gameOver];
        }
        
        //Adjust speed depending on points scored
        if(_points >= 60)
            _levelSpeed = 0.7f;
        else if(_points >= 100)
            _levelSpeed = 0.6f;
        
        [self ballRemoved:ball];
        
        [self fadeInNewCharacter:ballColor];
        
        [self showMessage:[NSString stringWithFormat:@"%@%d", @"+", _pointsMultiplier ]
               atPosition:_character.positionInPoints];
    }
    
    [self showScore];
    
    return TRUE;
}
-(int)getSpecialBallIndex:(NSString*) ballColor{
    
    int res = -1;
    for(int i=0; i<MAX_SPECIAL_BALLS; i++){
        if([specialBallColors[i] isEqualToString:ballColor])
            return i;
    }
    return res;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                     character:(CCNode *)character
                      mushroom:(CCNode *)mushroom {

    _rowsAddedSinceLastCollision = 0;
    _skipRowsLabel.visible = false;
    
    NSString* mushroomColor = (NSString *)mushroom.userObject;
    NSString* characterColor = (NSString *)character.userObject;
    
    if([mushroomColor isEqualToString:characterColor]){
        
        _points += _pointsMultiplier * 2; //Double the points rate for mushrooms
        
        [self ballRemoved:mushroom];

        [self fadeInNewCharacter:mushroomColor];
        
        [self showMessage:[NSString stringWithFormat:@"%@%d", @"+", _pointsMultiplier * 2 ]
               atPosition:_character.positionInPoints];
        
    }else{
        
        _lives--;
        
        [self bounceCharacter];
        
        [self ballRemoved:mushroom];
        
        if(_lives == 0)
            [self gameOver];
        
    }
    
    [self showScore];
    
    return TRUE;
}
#pragma mark - Other Game logic
- (void)showScore{
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", _points];
    _lifeLabel.string = [NSString stringWithFormat:@"%d", _lives];
}

- (void)gameOver {
    
    if (!_gameOver) {
        _gameOver = TRUE;
       
        [self bounceCharacter];
        
        [_character removeFromParent];
        
        Globals.currentPoints = _points;
        
        if(Globals.currentLevel == 6) //Last Level
            Globals.levelCleared = true;
        
        if(self.paused)
            [[CCDirector sharedDirector] resume];

        [self showMessage:@"Game Over!!!" atPosition:CGPointMake(_screenSize.width/2, _screenSize.height/2)];
        
        CCScene *scene = [CCBReader loadAsScene:@"LevelSelectScene"];
        [[CCDirector sharedDirector] performSelector:@selector(replaceScene:) withObject:scene afterDelay:1.5];
        
        for (CCSprite* ball in _balls) {
            [self ballRemoved:ball];
        }
        
    }
}

- (void)restart {
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.2f];
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:transition];
}
#pragma mark - Animations
-(void) showMessage:(NSString*)message atPosition:(CGPoint)position {
    CCLabelTTF *lblForMessage = [CCLabelTTF labelWithString:message fontName:@"Helvetica" fontSize:18];
    
    lblForMessage.position = position;
    
    [self addChild:lblForMessage];
    
    CCActionFadeOut *fadeAction = [CCActionFadeOut actionWithDuration:0.5];
    CCActionMoveBy *moveUpAction = [CCActionMoveBy actionWithDuration:5 position:ccp(0, 10)];
    CCActionRemove *removeAction = [CCActionRemove action];
    
    CCActionSpawn *spawnAction = [CCActionSpawn actionWithArray:@[fadeAction, moveUpAction]];
    CCActionSequence *sequenceAction = [CCActionSequence actionWithArray:@[spawnAction, removeAction]];
    
    [lblForMessage runAction:sequenceAction];
}
-(void)setTargetMessage{
    _targetMessageLabel.visible = true;
    switch (Globals.currentLevel) {
        case 1:
            [_targetMessageLabel setString:@"Target: 10 points"];
            break;
        case 2:
            [_targetMessageLabel setString:@"Target: 20 points"];
            break;
        case 3:
            [_targetMessageLabel setString:@"Target: 30 points"];
            break;
        case 4:
            [_targetMessageLabel setString:@"Target: 50 points"];
            break;
        case 5:
            [_targetMessageLabel setString:@"Target: 100 points"];
            break;
        default:
            _targetMessageLabel.visible = false;
            break;
    }
}
-(void) bounceCharacter{
    
    CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.15f position:ccp(-5, 5)];
    CCActionInterval *reverseMovement = [moveBy reverse];
    CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
    CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
    [self runAction:bounce];
    
    CCActionRotateBy *rotateBy = [CCActionRotateBy actionWithDuration:0.15f angle:360];
    [_character runAction:rotateBy];
}
-(void) fadeInNewCharacter:(NSString *)color{
//    CCActionFadeOut *fadeOutAction = [CCActionFadeOut actionWithDuration:0.10];
//    CCActionRemove *removeAction = [CCActionRemove action];
//    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.15];
//    CCActionSequence *sequenceAction = [CCActionSequence actionWithArray:@[fadeOutAction, removeAction, delay]];
//    [_character runAction:sequenceAction];
    
    [_character removeFromParent];
    [self addNewCharacter:color xPosition:_character.position.x];
}
- (void) ballRemoved:(CCNode *)ball {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"BallExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the balls position
    explosion.positionType = ball.positionType;
    explosion.position = ball.position;
    // add the particle effect to the same node the ball is on
    [ball.parent addChild:explosion];
    
    // finally, remove the destroyed ball
    [ball removeFromParent];
}
-(void)hideOnboarding{
    _onboardingNode.visible = false;
    [[CCDirector sharedDirector] resume];

}
@end
