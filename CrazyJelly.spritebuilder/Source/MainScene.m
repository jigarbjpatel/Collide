#import "MainScene.h"
#import "Character.h"
#import "Ball.h"

#define ARC4RANDOM_MAX      0x100000000

static NSString *ballColors[5] = {@"Red", @"Blue",@"Yellow",@"Green",@"Pink"};

@implementation MainScene{
    //Define variables here
    CCSprite *_character;
    NSMutableArray *_balls;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_lifeLabel;
    CCPhysicsNode* _physicsNode;
    CGFloat _levelSpeed;
    CGSize _screenSize;
    int _lives;
    long _points;
    float _timeSinceMovement;
    BOOL _gameOver;
    CCButton *_restartButton;
}

- (void)didLoadFromCCB {
    _balls = [[NSMutableArray alloc] init];
    _gameOver = false;
    _points = 0;
    _lives = 3;
    _timeSinceMovement = 0.0f;
    _levelSpeed = 0.8f;
    _screenSize = [CCDirector sharedDirector].viewSize;
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _physicsNode.debugDraw = false;
    [self initialize];
    _scoreLabel.visible = true;
    _lifeLabel.visible = true;
    
}
-(void)initialize{
    //Initialize the character
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX); //value between 0 and 1
    int index = (int)(random * 10.0) % 5;
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
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX); //value between 0 and 1
    int index = (int)(random * 10.0) % 5;
    [self addNewBall:ballColors[index] xPosition:0.12f];
    
    random = ((double)arc4random() / ARC4RANDOM_MAX);
    index = (int)(random * 10.0) % 5;
    [self addNewBall:ballColors[index]  xPosition:0.5f];
    
    random = ((double)arc4random() / ARC4RANDOM_MAX);
    index = (int)(random * 10.0) % 5;
    [self addNewBall:ballColors[index]  xPosition:0.88f];
}

- (void)update:(CCTime)delta{
    if(!_gameOver){
        
        _timeSinceMovement += delta;
        if(_timeSinceMovement > _levelSpeed){
            //        NSString* count = [NSString stringWithFormat:@"%lu", (unsigned long)_balls.count];
            //        NSLog(@"BAlls Array Count = %@",count);
            for(CCSprite* sprite in _balls){
                sprite.position = ccp(sprite.position.x, sprite.position.y + 10);
            }
            _timeSinceMovement = 0.0f;
            //If sprites have moved out then remove them and add new
            NSMutableArray *offScreenBalls = nil;
            
            for (CCNode *ball in _balls) {
                if(ball.position.y > (_screenSize.height)){
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
            }
        }
    }
}
- (void)touchBegan:(CCTouch *)touch
         withEvent:(CCTouchEvent *)event {
    // get the x location of touch and move the character there.
    if(!_gameOver){
        CGPoint touchLocation = [touch locationInNode:self];
        _character.position = ccp(touchLocation.x/_screenSize.width,_character.position.y);
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                     character:(CCNode *)character
                          ball:(CCNode *)ball {
    
    NSString* ballColor = (NSString *)ball.userObject;
    NSString* characterColor = (NSString *)character.userObject;
    
    if([ballColor isEqualToString:characterColor]){
        _lives--;
        if(_lives == 0)
            [self gameOver];
    }else{
        _points++;
        [character removeFromParent];
        [self addNewCharacter:ballColor xPosition:character.position.x];
    }
    
    [ball removeFromParent];
    [self showScore];
    
    return TRUE;
}
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
