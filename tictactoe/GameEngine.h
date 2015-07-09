//
//  GameEngine.h
//  tictactoe
//
//  Created by Nicholas Richards on 7/8/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Support data structures

// Board size
static const NSUInteger kGEBoardDimension = 3;
static const NSUInteger kGEBoardSize = kGEBoardDimension * kGEBoardDimension;
static const NSUInteger kGEBoardVectorCount = 2 * kGEBoardDimension + 2; // rows, columns, diagonals

// Status - is the game in progress, or completed?
typedef NS_ENUM(NSUInteger, GameEngineStatus) {
    GameEngineStatusClear,
    GameEngineStatusInProgress,
    GameEngineStatusComplete,
};

// Piece - what piece is played on the board, or none
// Integer value used to score incrementally. Positive is player one. Negative, player two.
typedef NS_ENUM(NSUInteger, GameEnginePiece) {
    GameEnginePieceNone = 0,
    GameEnginePiecePlayerOne = 1,
    GameEnginePiecePlayerTwo = -1,
};

// Position - where on the board, an x,y coordinate
struct GameEnginePosition {
    NSInteger x;
    NSInteger y;
};
typedef struct GameEnginePosition GameEnginePosition;

// Board status - how a particular row/column/diagonal vector is doing tactically
@interface GameEngineBoardVectorAttributes : NSObject
@property(nonatomic,assign) NSUInteger vectorId; // 8 id's: row 0,1,2, column 0,1,2, diagonal 0(topleft -> bottomright),1(bottomleft -> topright)
@property(nonatomic,assign) NSInteger vectorScore; // how much this vector leans to player one or player two
@property(nonatomic,assign) BOOL isPlayable; // if another move can be played in this vector

- (instancetype)initWithVectorId:(NSUInteger)vectorId;
@end

// ------

// TODO: Decide if the board is better off being a dumb property inside the engine

@interface GameEngineBoard : NSObject
@property(nonatomic,retain) NSMutableArray *piecesArr; // 1d array of GameEnginePiece, row * column size
@property(nonatomic) GameEnginePiece *pieces;

- (GameEnginePiece)pieceAtRow:(NSUInteger)row column:(NSUInteger)column;
@end

// ------

#pragma mark - Engine

@interface GameEngine : NSObject

@property(nonatomic,readonly) GameEngineStatus status;
@property(nonatomic,retain) GameEngineBoard *board;

#pragma mark - Pieces and places

- (GameEnginePiece)getPieceForPosition:(GameEnginePosition)position;
- (BOOL)isOpen:(GameEnginePosition)position;
- (void)setPlace:(GameEnginePosition)position withPiece:(GameEnginePiece)piece; // Updates incremental solver

#pragma mark - Solver

- (GameEnginePosition)solveForPiece:(GameEnginePiece)piece; // return a desirous available position

- (NSArray*)boardVectorAttributes; //

@end
