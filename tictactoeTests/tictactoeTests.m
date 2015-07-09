//
//  tictactoeTests.m
//  tictactoeTests
//
//  Created by Nicholas Richards on 7/8/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GameEngine.h"

@interface tictactoeTests : XCTestCase

@end

@implementation tictactoeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

///////////////////////////////////////////////

// Test Board model
// Test Solution model
// Test GameEngine
// - IsGameOver
// - IsPlaceAvailable
// - SetPlaceWithPiece
// - GetPieceAtPlace
// - ComputeNextCPUPlace
// - SetOptionWithValue
// - (NSArray*) orderByPositiveSum:(NSArray*)solutions
// -

- (void)testCreateGameEngine {
    GameEngine* gameEngine = [[GameEngine alloc] init];

    XCTAssertEqual(gameEngine.status, GameEngineStatusClear);
    XCTAssertNotEqualObjects(gameEngine.board, nil);
}

- (void)testCreateBoard {
    GameEngineBoard* gameEngineBoard = [[GameEngineBoard alloc] init];
    XCTAssert(gameEngineBoard != nil);
}

- (void)testCreateBoardVectorAttributes {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    NSArray* boardVectorAttributes = [gameEngine boardVectorAttributes];
    XCTAssertEqual([boardVectorAttributes count], kGEBoardVectorCount);
}

- (void)testBoardVectorAttributes_sampleGame {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    // row #0, all columns, and all diagonals should all show gameplay in the vector attributes
    // x,o,x
    // ~,~,~
    // ~,~,~
    [gameEngine board].pieces[0 * kGEBoardDimension + 0] = GameEnginePiecePlayerOne;
    [gameEngine board].pieces[0 * kGEBoardDimension + 1] = GameEnginePiecePlayerTwo;
    [gameEngine board].pieces[0 * kGEBoardDimension + 2] = GameEnginePiecePlayerOne;
    
    NSArray* boardVectorAttributes = [gameEngine boardVectorAttributes];
    NSUInteger vectorId;
    
    // row 0 (should describe some gameplay)
    vectorId = 0;
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorId, vectorId);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).isPlayable, NO);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorScore, 1);
    for (NSUInteger row = 1; row <= 2; row++) {
        // row 1,2
        vectorId = row;
        XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorId, vectorId);
        XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).isPlayable, YES);
        XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorScore, 0);
    }
    
    // column 0
    vectorId = 3;
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorId, vectorId);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).isPlayable, YES);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorScore, 1);
    // column 1
    vectorId = 4;
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorId, vectorId);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).isPlayable, YES);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorScore, -1);
    // column 2
    vectorId = 5;
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorId, vectorId);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).isPlayable, YES);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorScore, 1);

    // diagonal 0
    vectorId = 6;
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorId, vectorId);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).isPlayable, YES);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorScore, 1);
    // diagonal 1
    vectorId = 7;
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorId, vectorId);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).isPlayable, YES);
    XCTAssertEqual(((GameEngineBoardVectorAttributes*)[boardVectorAttributes objectAtIndex:vectorId]).vectorScore, 1);

}

@end
