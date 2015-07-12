//
//  GameEngine.h
//  tictactoe
//
//  Created by Nicholas Richards on 7/8/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameBoard.h"

#pragma mark - GameEngine support data structures

// Status - is the game in progress, or completed?
typedef NS_ENUM(NSUInteger, GameEngineStatus) {
    GameEngineStatusClear,
    GameEngineStatusInProgress,
    GameEngineStatusComplete,
};

// ------

#pragma mark - GameEngine

// Engine - has a board, records arbitrary activity, proposes CPU activity based upon Tic-Tac-Toe algorithm
@interface GameEngine : NSObject

@property(nonatomic,readonly) GameEngineStatus status;
@property(nonatomic,readonly) NSUInteger winningVectorIdentifier;
@property(nonatomic,readonly) GameEnginePiece winner;
@property(nonatomic,retain) GameBoard *board;

#pragma mark - Pieces and places

- (GameEnginePiece)pieceForPosition:(GameEnginePosition)position;
- (void)setPosition:(GameEnginePosition)position withPiece:(GameEnginePiece)piece; // Capture human moves

#pragma mark - Solver - a Tic-Tac-Toe algorithm

- (NSArray*)orderByTacticalWorthAscending:(NSArray*)attributes forPiece:(GameEnginePiece)piece; // order success vectors to use for winning the game
- (BOOL)solveForPiece:(GameEnginePiece)piece position:(GameEnginePosition*)position; // find a desirous available position, return NO if none found, YES otherwise

@end
