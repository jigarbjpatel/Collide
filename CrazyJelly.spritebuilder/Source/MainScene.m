#import "MainScene.h"
#import "Character.h"
#import "Ball.h"

#define ARC4RANDOM_MAX      0x100000000

static const NSString *ballColors[5] = {@"Red", @"Blue",@"Yellow",@"Green",@"Pink"};

@implementation MainScene{
    //Define variables here
    CCSprite *_character;
    NSMutableArray *_balls;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_lifeLabel;
    CCPhysicsNode* _physicsNode;
    CGFloat _levelSpeed;
    CGSize _screenSize;
}

- (void)didLoadFromCCB {
    _balls = [[NSMutableArray alloc] init];
    timeSinceMovement = 0.0f;
    _levelSpeed = 0.25f;
    _screenSize = [CCDirector sharedDirector].viewSize;
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    //[self addChild:_physicsNode];
    //_physicsNode.debugDraw = true;
    //_character.physicsBody.collisionType = @"character";
    [self initialize];

}
-(void)initialize{
    //Initialize the character
    
    
    //Initialize the Balls
    [self addNewRow];
    //Push the row down
    for(CCSprite* sprite in _balls){
        sprite.position = ccp(sprite.position.x, sprite.position.y + 100);
    }
    [self addNewRow];
    for(CCSprite* sprite in _balls){
        sprite.position = ccp(sprite.position.x, sprite.position.y + 100);
    }
    [self addNewRow];
    for(CCSprite* sprite in _balls){
        sprite.position = ccp(sprite.position.x, sprite.position.y + 100);
    }
    [self addNewRow];
    for(CCSprite* sprite in _balls){
        sprite.position = ccp(sprite.position.x, sprite.position.y + 100);
    }
    [self addNewRow];
}
- (void)addNewBall:(NSString *)spriteName xPosition:(CGFloat)xPos{
    //Add 3 balls at top of the scene
    //Ball *ball = (Ball *)[CCBReader load:@"Ball"];
    //    CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"Resources/Balls/Black.png"];
    //    [ball setSpriteFrame:frame];
    //    ball.texture = [[CCSprite spriteWithImageNamed:@"Resources/Balls/Black.png"] texture];
    //ball.spriteFrame = [[CCSprite spriteWithImageNamed:@"Resources/Balls/Black.png"] frame];
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteName];
    sprite.positionType = CCPositionTypeMake(CCPositionTypeNormalized.xUnit, CCPositionTypePoints.yUnit, CCPositionReferenceCornerTopLeft);
    sprite.userObject = spriteName;
//    CGPoint screenPosition = [self convertToWorldSpace:ccp(0, 86)];
//    CGPoint worldPosition = [_physicsNode convertToNodeSpace:screenPosition];
//    sprite.position = worldPosition;

    sprite.position = ccp(xPos, 86);
    sprite.zOrder = 100;
    
    sprite.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:32.0 andCenter:CGPointMake(sprite.position.x+sprite.contentSize.width/2,sprite.position.y - sprite.contentSize.height)];
    sprite.physicsBody.collisionType = @"ball";
    [_physicsNode addChild:sprite];

    [_balls addObject:sprite];
}

-(void)addNewRow{
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX); //value between 0 and 1
    int index = (int)(random * 10.0) % 5;
    NSString* resourceName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Balls/", ballColors[index], @".png"];
    [self addNewBall:resourceName xPosition:0.12f];
    random = ((double)arc4random() / ARC4RANDOM_MAX);
    index = (int)(random * 10.0) % 5;
    resourceName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Balls/", ballColors[index], @".png"];
    [self addNewBall:resourceName xPosition:0.5f];
    random = ((double)arc4random() / ARC4RANDOM_MAX);
    index = (int)(random * 10.0) % 5;
    resourceName = [NSString stringWithFormat:@"%@%@%@", @"Resources/Balls/", ballColors[index], @".png"];
    [self addNewBall:resourceName xPosition:0.88f];
}

- (void)update:(CCTime)delta{
    timeSinceMovement += delta;
    if(timeSinceMovement > _levelSpeed){
//        NSString* count = [NSString stringWithFormat:@"%lu", (unsigned long)_balls.count];
//        NSLog(@"BAlls Array Count = %@",count);
        for(CCSprite* sprite in _balls){
            sprite.position = ccp(sprite.position.x, sprite.position.y + 10);
        }
        timeSinceMovement = 0.0f;
        //If spires have moved out then remove them and add new
        NSMutableArray *offScreenBalls = nil;
        
        for (CCNode *ball in _balls) {
//            CGPoint ballWorldPosition = [_physicsNode convertToWorldSpace:ball.position];
//            CGPoint ballScreenPosition = [self convertToNodeSpace:ballWorldPosition];
//            if (ballScreenPosition.y < -ball.contentSize.height) {
            
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
- (void)touchBegan:(CCTouch *)touch
         withEvent:(CCTouchEvent *)event {
    // this will get called every time the player touches the screen
    // get the x location of touch and move the character there.
    CGPoint touchLocation = [touch locationInNode:self];
    _character.position = ccp(touchLocation.x/_screenSize.width,_character.position.y);
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                     character:(CCNode *)character
                      ball:(CCSprite *)ball {
    
//    NSString* ballColor =
    [ball removeFromParent];
    NSString* ballColor = ball.userObject;
    NSString* characterColor = character.userObject;
    if([ballColor isEqualToString:characterColor]){
        //[character removeFromParent];
    }
    
    //[character removeFromParent];
    
//    
//    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Resources/Character/"];
//    sprite.positionType = CCPositionTypeMake(CCPositionTypeNormalized.xUnit, CCPositionTypePoints.yUnit, CCPositionReferenceCornerTopLeft);
//    
//    //    CGPoint screenPosition = [self convertToWorldSpace:ccp(0, 86)];
//    //    CGPoint worldPosition = [_physicsNode convertToNodeSpace:screenPosition];
//    //    sprite.position = worldPosition;
//    
//    sprite.position = ccp(xPos, 86);
//    sprite.zOrder = 100;
//    
//    sprite.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:32.0 andCenter:CGPointMake(sprite.position.x+sprite.contentSize.width/2,sprite.position.y - sprite.contentSize.height)];
//    sprite.physicsBody.collisionType = @"ball";
//    [_physicsNode addChild:sprite];
    return TRUE;
}
@end
