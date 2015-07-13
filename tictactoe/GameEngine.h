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
@property(nonatomic,readonly) GamePiece winner;
@property(nonatomic,retain) GameBoard *board;

#pragma mark - Pieces and places

- (GamePiece)pieceForPosition:(GamePosition)position;
- (void)setPosition:(GamePosition)position withPiece:(GamePiece)piece; // Capture human moves

#pragma mark - Solver - a Tic-Tac-Toe algorithm

- (BOOL)solveForPiece:(GamePiece)piece position:(GamePosition*)position; // find a desirous available position, return YES setting 'position' if successful, NO otherwise. exhaustive search.

@end
