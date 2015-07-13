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
    
    [[gameEngine board] setPiece:GamePiecePlayerOne atRow:0 column:0];
    [[gameEngine board] setPiece:GamePiecePlayerTwo atRow:0 column:1];
    [[gameEngine board] setPiece:GamePiecePlayerOne atRow:0 column:2];
    [[gameEngine board] setPiece:GamePiecePlayerTwo atRow:1 column:1];
    
    XCTAssertThrows([[gameEngine board] setPiece:GamePiecePlayerTwo atRow:-1 column:-1]);
    XCTAssertThrows([[gameEngine board] setPiece:GamePiecePlayerTwo atRow:9 column:9]);
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

- (void)testGameBoard_pieceSetter {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    // x,o,x
    // ~,~,~
    // ~,~,~
    [[gameEngine board] setPiece:GamePiecePlayerOne atRow:0 column:0];
    [[gameEngine board] setPiece:GamePiecePlayerTwo atRow:0 column:1];
    [[gameEngine board] setPiece:GamePiecePlayerOne atRow:0 column:2];

    XCTAssertEqual([[gameEngine board] pieceAtRow:0 column:0], GamePiecePlayerOne);
    XCTAssertEqual([[gameEngine board] pieceAtRow:0 column:1], GamePiecePlayerTwo);
    XCTAssertEqual([[gameEngine board] pieceAtRow:0 column:2], GamePiecePlayerOne);
}

- (void)testGameBoardVectorAttributes {
    GameEngine* gameEngine = [[GameEngine alloc] init];
    
    // x,o,x
    // ~,~,~
    // ~,~,~
    [[gameEngine board] setPiece:GamePiecePlayerOne atRow:0 column:0];
    [[gameEngine board] setPiece:GamePiecePlayerTwo atRow:0 column:1];
    [[gameEngine board] setPiece:GamePiecePlayerOne atRow:0 column:2];
    
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

- (void)testGameBoard_complete1 {
    GameBoard *board = [[GameBoard alloc] init];
    
    GamePiece piecesStackArr[] = {
        +0, 1,-1,
        -1, 1, 1,
        +0, 0,-1};
    memcpy(board.pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    XCTAssertEqual(board.won, NO);
}

- (void)testGameBoard_complete2 {
    GameBoard *board = [[GameBoard alloc] init];
    
    GamePiece piecesStackArr[] = {
        +0, 1,-1,
        +1, 1, 1,
        +0, 0,-1};
    memcpy(board.pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    XCTAssertEqual(board.won, YES);
}

- (void)testGameBoard_complete3 {
    GameBoard *board = [[GameBoard alloc] init];
    
    GamePiece piecesStackArr[] = {
        +0, 1, 1,
        -1, 1, 1,
        +1, 0,-1};
    memcpy(board.pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    XCTAssertEqual(board.won, YES);
}

#pragma mark - Recursive solver

- (void)testGameEngine_scores1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +0, 1,-1,
        -1, 1, 1,
        +0, 0,-1};
    GamePiece turn = GamePiecePlayerOne;
    
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    [gameEngine.board setPieces:pieces];
    
    // Get score and position
    GamePosition position = {0};
    BOOL solved = [gameEngine solveForPiece:turn position:&position];
    XCTAssertEqual(solved, YES);
}

- (void)testGameEngine_scores2 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1, 0, 0,
        +0, 0, 0,
        +0, 0, 0};
    GamePiece turn = GamePiecePlayerOne;
    
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    [gameEngine.board setPieces:pieces];
    
    // Get score and position
    GamePosition position = {0};
    BOOL solved = [gameEngine solveForPiece:turn position:&position];
    XCTAssertEqual(solved, YES);
}

#pragma mark - Scoring: base/error/in-progress cases, then win by row, column, diagonal

- (void)testGameBoard_scoreForGame0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1, 1, 1,
        +1, 1, 1,
        +1, 1, 1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePieceNone); // error case
}

- (void)testGameBoard_scoreForGame1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +0, 0, 0,
        +0, 0, 0,
        +0, 0, 0};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePieceNone); // base case
}

- (void)testGameBoard_scoreForGame1_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1, 0,-1,
        +0, 0, 0,
        -1, 0, 1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePieceNone); // in progress case
}

- (void)testGameBoard_scoreForGame2_0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1, 1, 1,
        -1,-1, 1,
        +1, 1,-1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerOne);
}

- (void)testGameBoard_scoreForGame2_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1,-1, 1,
        +1, 1, 1,
        -1, 1,-1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerOne);
}

- (void)testGameBoard_scoreForGame2_2 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1,-1,-1,
        -1,-1, 1,
        +1, 1, 1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerOne);
}

- (void)testGameBoard_scoreForGame3_0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        -1, 1,-1,
        -1, 1, 1,
        -1,-1, 1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerTwo);
}

- (void)testGameBoard_scoreForGame3_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1,-1, 1,
        -1,-1, 1,
        +1,-1,-1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerTwo);
}

- (void)testGameBoard_scoreForGame3_2 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1,-1,-1,
        -1, 0,-1,
        +1,-1,-1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerTwo);
}

- (void)testGameBoard_scoreForGame4_0 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        +1,-1, 1,
        -1, 1,-1,
        +1,-1,-1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerOne);
}

- (void)testGameBoard_scoreForGame4_1 {
    GameEngine *gameEngine = [[GameEngine alloc] init];
    
    GamePiece piecesStackArr[] = {
        -1,-1, 1,
        -1, 1,-1,
        +1,-1,-1};
    GamePiece *pieces = malloc(sizeof(piecesStackArr));
    memcpy(pieces, &piecesStackArr, sizeof(piecesStackArr));
    
    [gameEngine.board setPieces:pieces];
    
    GamePiece winner = [gameEngine.board winner];
    XCTAssertEqual(winner, GamePiecePlayerOne);
}


@end
