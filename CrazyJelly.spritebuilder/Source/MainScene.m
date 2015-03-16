#import "MainScene.h"
#import "Character.h"
#import "Ball.h"

#define ARC4RANDOM_MAX      0x100000000
#define ROW_SIZE    3
#define TOTAL_COLORS 6
#define MAX_ROWS_THAT_CAN_BE_SKIPPED 7
#define MAX_SPECIAL_BALLS 3
static NSString *ballColors[TOTAL_COLORS] = {@"Red", @"Blue",@"Yellow",@"Green",@"Pink",@"White"};
typedef enum  {EASY, MEDIUM, TOUGH, RANDOM} RowType;
static NSString *specialBallColors[MAX_SPECIAL_BALLS] = {@"Blast", @"Lightning",@"Life"};


@implementation MainScene{
    //Define variables here
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
}
#pragma mark - Initialization
- (void)didLoadFromCCB {
    _balls = [[NSMutableArray alloc] init];
    _gameOver = false;
    _points = 0;
    _lives = 3;
    _timeSinceLastRowAdded = 0.0f;
    _rowsAddedSinceLastCollision = 0;
    _levelSpeed = 0.8f;
    _screenSize = [CCDirector sharedDirector].viewSize;
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _physicsNode.debugDraw = false;
    [self initialize];
    _scoreLabel.visible = true;
    _lifeLabel.visible = true;
    _skipRowsLabel.visible = false;
    _lastRowType = EASY;
    for(int i=0; i<ROW_SIZE; i++)
        _lastRowBallColors[i] = i;
    _lastSpecialBallColor = -1;
    
}
-(void)initialize{
    //Initialize the character
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX); //value between 0 and 1
    int index = (int)(random * 10.0) % TOTAL_COLORS;
    [self addNewCharacter:ballColors[index] xPosition:0.5f];
    
    //Initialize the Balls
    for (int i=0; i<4; i++) {
        [self addNewRow];
        //Push the row down
        for(CCSprite* sprite in _balls){
            sprite.position = ccp(sprite.position.x, sprite.position.y + 100);
        }
    }
    [self addNewRow];
}
-(void)addNewCharacter:(NSString *)spriteColor xPosition:(CGFloat)xPos{
    if(spriteColor == NULL)
        return;
    NSString* spriteName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Characters/", spriteColor, @".png"];
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteName];
    sprite.positionType = CCPositionTypeMake(CCPositionTypeNormalized.xUnit,
                                             CCPositionTypePoints.yUnit, CCPositionReferenceCornerBottomLeft);
    [sprite setUserObject:spriteColor];
    //    [sprite setName:@"Character"];
    sprite.position = ccp(xPos, 50);
    sprite.zOrder = 100;
    
    CGRect rect = CGRectMake(sprite.position.x, sprite.position.y - sprite.contentSize.height + 10,
                             sprite.contentSize.width, sprite.contentSize.height);
    
    sprite.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0 ];
    sprite.physicsBody.type = CCPhysicsBodyTypeStatic;
    sprite.physicsBody.collisionType = @"character";
    [_physicsNode addChild:sprite];
    
    _character = sprite;
    
}
- (void)addNewBall:(NSString *)spriteColor xPosition:(CGFloat)xPos{
    //NSLog(@"Ball Color :%@",spriteColor);
    if(spriteColor == NULL)
        return;
    
    NSString* spriteName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Balls/", spriteColor, @".png"];
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteName];
    sprite.positionType = CCPositionTypeMake(CCPositionTypeNormalized.xUnit,
                                             CCPositionTypePoints.yUnit, CCPositionReferenceCornerTopLeft);
    [sprite setUserObject:spriteColor];
    //    [sprite setName:@"Ball"];
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

-(void)addNewRow{
    int random = -1;
    int * nextRowColors = [self getNextRowColors];
    //Special ball logic....
    if(_points != 0 && _points % 15 == 0){
        random = (int)(((double)arc4random() / ARC4RANDOM_MAX) * MAX_SPECIAL_BALLS); //value between 0 and MAX_SPECIAL_BALLS
        
        _lastSpecialBallColor = (_lastSpecialBallColor + 1) % MAX_SPECIAL_BALLS;
        
    }
    for (int i=0; i<3; i++) {
        _lastRowBallColors[i] = nextRowColors[i];
    }
    //NSLog(@"Random = %d, Special Ball = %d",random,_lastSpecialBallColor);
    if(random != 0.0)
        [self addNewBall:ballColors[nextRowColors[0]] xPosition:0.12f];
    else
        [self addNewBall:specialBallColors[_lastSpecialBallColor] xPosition:0.12f];
    if(random != 1.0)
        [self addNewBall:ballColors[nextRowColors[1]] xPosition:0.5f];
    else
        [self addNewBall:specialBallColors[_lastSpecialBallColor] xPosition:0.5f];
    if(random != 2.0)
        [self addNewBall:ballColors[nextRowColors[2]] xPosition:0.88f];
    else
        [self addNewBall:specialBallColors[_lastSpecialBallColor] xPosition:0.88f];
    
    
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
    //NSLog(@"Next Row Colors %d, %d, %d", nextRowColors[0], nextRowColors[1], nextRowColors[2]);
    
    return nextRowColors;
}
#pragma mark - Game Loop
- (void)update:(CCTime)delta{
    if(!_gameOver){
        
        _timeSinceLastRowAdded += delta;
        
        if(_timeSinceLastRowAdded > _levelSpeed){
            //        NSString* count = [NSString stringWithFormat:@"%lu", (unsigned long)_balls.count];
            //        NSLog(@"BAlls Array Count = %@",count);
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
                
                [self addNewRow];
                
                _rowsAddedSinceLastCollision++;
                if(_rowsAddedSinceLastCollision > 1){
                    //Start the timer and check if user loses life
                    _skipRowsLabel.visible = true;
                    _skipRowsLabel.string = [NSString stringWithFormat:@"%d", MAX_ROWS_THAT_CAN_BE_SKIPPED - _rowsAddedSinceLastCollision];
                    if(_rowsAddedSinceLastCollision == MAX_ROWS_THAT_CAN_BE_SKIPPED){
                        _rowsAddedSinceLastCollision = 0;
                        _lives--;
                        _lifeLabel.string = [NSString stringWithFormat:@"%d", _lives];
                        _skipRowsLabel.visible = false;
                        if(_lives == 0)
                            [self gameOver];
                    }
                    
                }
                
                // NSLog(@"_rowsAddedSinceLastCollision = %d",_rowsAddedSinceLastCollision);
                
            }
        }
    }
}
#pragma mark - User Interaction
- (void)touchBegan:(CCTouch *)touch
         withEvent:(CCTouchEvent *)event {
    // get the x location of touch and move the character there.
    if(!_gameOver){
        CGPoint touchLocation = [touch locationInNode:self];
        _character.position = ccp(touchLocation.x/_screenSize.width,_character.position.y);
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
        if(_lives == 0)
            [self gameOver];
        [ball removeFromParent];
    }else if([self getSpecialBallIndex:ballColor] != -1){
        //Special Ball Handling
       // NSLog(@"Special Ball %d", _lastSpecialBallColor);
        switch (_lastSpecialBallColor) {
            case 0://Blast
                //Remove all same color balls
                for(CCSprite* ball in _balls){
                    NSString * ballColor = (NSString *)ball.userObject;
                    if([ballColor isEqualToString:characterColor])
                        [ball removeFromParent];
                }
                
                break;
            case 1://Lightning
                //Remove all balls
                for(CCSprite* ball in _balls){
                    [ball removeFromParent];
                }
                break;
            case 2://Life
                _lives++;
                NSLog(@"Lives %d", _lives);
                break;
            default:
                break;
        }
        [ball removeFromParent];
    }else{
        _points++;
        [character removeFromParent];
        [self addNewCharacter:ballColor xPosition:character.position.x];
        [ball removeFromParent];
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
#pragma mark - Other Game logic
- (void)showScore
{
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", _points];
    _lifeLabel.string = [NSString stringWithFormat:@"%d", _lives];
}
- (void)gameOver {
    if (!_gameOver) {
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        
        [_character removeFromParent];
        for (CCSprite* ball in _balls) {
            [ball removeFromParent];
        }
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}
@end
