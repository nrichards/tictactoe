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

#pragma mark - Game

- (void)testCreateGameEngine {
    GameEngine* gameEngine = [[GameEngine alloc] init];

    XCTAssertEqual(gameEngine.status, GameEngineStatusClear);
    XCTAssertNotEqualObjects(gameEngine.board, nil);
}

- (void)testGame_setPositionWithPiece {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    [[gameEngine board] setPiece:GameEnginePiecePlayerOne atRow:0 column:0];
    [[gameEngine board] setPiece:GameEnginePiecePlayerTwo atRow:0 column:1];
    [[gameEngine board] setPiece:GameEnginePiecePlayerOne atRow:0 column:2];
    [[gameEngine board] setPiece:GameEnginePiecePlayerTwo atRow:1 column:1];
    
    XCTAssertThrows([[gameEngine board] setPiece:GameEnginePiecePlayerTwo atRow:-1 column:-1]);
    XCTAssertThrows([[gameEngine board] setPiece:GameEnginePiecePlayerTwo atRow:9 column:9]);
}

- (void)DISABLED_testGame_solve {
    GameEngine* gameEngine = [[GameEngine alloc] init];

    // CPU is player one, 'x'
    
    // start:
    // ~,~,~
    // ~,~,~
    // ~,~,~

    // Turn 1 - CPU

    GameEnginePosition position1 = {0};
    BOOL found1 = [gameEngine solveForPiece:GameEnginePiecePlayerOne position:&position1];
    XCTAssertEqual(found1, YES);
    XCTAssertEqual(position1.row, 0);
    XCTAssertEqual(position1.column, 0);
    [gameEngine setPosition:position1 withPiece:GameEnginePiecePlayerOne];

    // X,~,~
    // ~,~,~
    // ~,~,~

    // Test over-setting
    XCTAssertThrows([gameEngine setPosition:position1 withPiece:GameEnginePiecePlayerOne]);

    // Turn 2 - Human

    GameEnginePosition position2 = {.row=1, .column=1};
    [gameEngine setPosition:position2 withPiece:GameEnginePiecePlayerTwo];

    // x,~,~
    // ~,O,~
    // ~,~,~

    // Turn 3
    GameEnginePosition position3 = {0};
    BOOL found3 = [gameEngine solveForPiece:GameEnginePiecePlayerOne position:&position3];
    XCTAssertEqual(found3, YES);
    XCTAssertEqual(position3.row, 0);
    XCTAssertEqual(position3.column, 1);
    [gameEngine setPosition:position3 withPiece:GameEnginePiecePlayerOne];

    // x,X,~
    // ~,o,~
    // ~,~,~

    // Turn 4
    GameEnginePosition position4 = {.row=0, .column=2};
    [gameEngine setPosition:position4 withPiece:GameEnginePiecePlayerTwo];

    // x,x,O
    // ~,o,~
    // ~,~,~
    
    // Turn 5
    GameEnginePosition position5 = {0};
    BOOL found5 = [gameEngine solveForPiece:GameEnginePiecePlayerOne position:&position5];
    XCTAssertEqual(found5, YES);
    XCTAssertEqual(position5.row, 1);
    XCTAssertEqual(position5.column, 0);
    [gameEngine setPosition:position5 withPiece:GameEnginePiecePlayerOne];

    // x,x,o
    // X,o,~
    // ~,~,~

    // Turn 6 - lose the game
    GameEnginePosition position6 = {.row=1, .column=2};
    [gameEngine setPosition:position6 withPiece:GameEnginePiecePlayerTwo];

    // x,x,o
    // x,o,O
    // ~,~,~

    // Turn 7
    GameEnginePosition position7 = {0};
    BOOL found7 = [gameEngine solveForPiece:GameEnginePiecePlayerOne position:&position7];
    XCTAssertEqual(found7, YES);
    XCTAssertEqual(position7.row, 2);
    XCTAssertEqual(position7.column, 0);
    [gameEngine setPosition:position7 withPiece:GameEnginePiecePlayerOne];

    // x,x,o
    // x,o,o
    // X,~,~

    // Status when game has been won by a move
    
    XCTAssertEqual(gameEngine.status, GameEngineStatusComplete);
    XCTAssertEqual(gameEngine.winningVectorIdentifier, 3);
}

#pragma mark - Board

- (void)testCreateBoard {
    GameBoard* gameEngineBoard = [[GameBoard alloc] init];
    XCTAssert(gameEngineBoard != nil);
}

- (void)testCreateBoardVectorAttributes {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    NSArray* vectorAttributes = [[gameEngine board] vectorAttributes];
    XCTAssertEqual([vectorAttributes count], kGEBoardVectorCount);
}

- (void)testBoard_pieceSetter {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    // x,o,x
    // ~,~,~
    // ~,~,~
    [[gameEngine board] setPiece:GameEnginePiecePlayerOne atRow:0 column:0];
    [[gameEngine board] setPiece:GameEnginePiecePlayerTwo atRow:0 column:1];
    [[gameEngine board] setPiece:GameEnginePiecePlayerOne atRow:0 column:2];

    XCTAssertEqual([[gameEngine board] pieceAtRow:0 column:0], GameEnginePiecePlayerOne);
    XCTAssertEqual([[gameEngine board] pieceAtRow:0 column:1], GameEnginePiecePlayerTwo);
    XCTAssertEqual([[gameEngine board] pieceAtRow:0 column:2], GameEnginePiecePlayerOne);
}

- (void)testBoardVectorAttributes {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    // x,o,x
    // ~,~,~
    // ~,~,~
    [[gameEngine board] setPiece:GameEnginePiecePlayerOne atRow:0 column:0];
    [[gameEngine board] setPiece:GameEnginePiecePlayerTwo atRow:0 column:1];
    [[gameEngine board] setPiece:GameEnginePiecePlayerOne atRow:0 column:2];
    
    NSArray* vectorAttributes = [[gameEngine board] vectorAttributes];
    NSUInteger identifier;

    // gameplay activity (score+) should be shown in vector attributes for row #0, all columns, and all diagonals

    // row 0
    identifier = 0;
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).identifier, identifier);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).isPlayable, NO);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).score, 1);
    for (NSUInteger row = 1; row <= 2; row++) {
        // row 1,2
        identifier = row;
        XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).identifier, identifier);
        XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).isPlayable, YES);
        XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).score, 0);
    }
    
    // column 0
    identifier = 3;
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).identifier, identifier);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).isPlayable, YES);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).score, 1);
    // column 1
    identifier = 4;
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).identifier, identifier);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).isPlayable, YES);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).score, -1);
    // column 2
    identifier = 5;
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).identifier, identifier);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).isPlayable, YES);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).score, 1);

    // diagonal 0
    identifier = 6;
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).identifier, identifier);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).isPlayable, YES);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).score, 1);
    // diagonal 1
    identifier = 7;
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).identifier, identifier);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).isPlayable, YES);
    XCTAssertEqual(((GameBoardVectorAttributes*)[vectorAttributes objectAtIndex:identifier]).score, 1);
}

#pragma mark - Recursive solver

- (void)testGameEngine_availablePositionsForBoard {
    // Generate positions available to be moved for a given board
    
}

#pragma mark - Board generator

- (void)testGameEngine_mutateBoardForMove {
    // Generate board for a given hypothetical move
    
    GameEngine *gameEngine = [[GameEngine alloc] init];

    GameEnginePiece piecesStackArr[] = {
        +0, 1,-1,
        -1, 1, 1,
         0, 0,-1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];

    GameEnginePosition position = {.row=2, .column=1};
    GameEnginePiece *mutant = [gameEngine.board mallocBoardWithPiece:GameEnginePiecePlayerOne atPosition:position];
    XCTAssertEqual(mutant[position.row * kGEBoardDimension + position.column], GameEnginePiecePlayerOne);
    free(mutant);
}

#pragma mark - Scoring: base/error/in-progress cases, then win by row, column, diagonal

- (void)testGameEngine_scoreForGame0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1, 1, 1,
        +1, 1, 1,
        +1, 1, 1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePieceNone); // error case
}

- (void)testGameEngine_scoreForGame1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +0, 0, 0,
        +0, 0, 0,
        +0, 0, 0};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePieceNone); // base case
}

- (void)testGameEngine_scoreForGame1_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1, 0,-1,
        +0, 0, 0,
        -1, 0, 1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePieceNone); // in progress case
}

- (void)testGameEngine_scoreForGame2_0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1, 1, 1,
        -1,-1, 1,
        +1, 1,-1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerOne);
}

- (void)testGameEngine_scoreForGame2_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1,-1, 1,
        +1, 1, 1,
        -1, 1,-1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerOne);
}

- (void)testGameEngine_scoreForGame2_2 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1,-1,-1,
        -1,-1, 1,
        +1, 1, 1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerOne);
}

- (void)testGameEngine_scoreForGame3_0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        -1, 1,-1,
        -1, 1, 1,
        -1,-1, 1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerTwo);
}

- (void)testGameEngine_scoreForGame3_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1,-1, 1,
        -1,-1, 1,
        +1,-1,-1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerTwo);
}

- (void)testGameEngine_scoreForGame3_2 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1,-1,-1,
        -1, 0,-1,
        +1,-1,-1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerTwo);
}

- (void)testGameEngine_scoreForGame4_0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        +1,-1, 1,
        -1, 1,-1,
        +1,-1,-1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerOne);
}

- (void)testGameEngine_scoreForGame4_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GameEnginePiece piecesStackArr[] = {
        -1,-1, 1,
        -1, 1,-1,
        +1,-1,-1};
    GameEnginePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GameEnginePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GameEnginePiecePlayerOne);
}


@end
