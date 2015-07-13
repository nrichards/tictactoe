//
//  GameEngine.m
//  tictactoe
//
//  Created by Nicholas Richards on 7/8/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import "GameEngine.h"

@implementation GameEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = GameEngineStatusClear;
        _board = [[GameBoard alloc] init];
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@ = %p; %@ = %@; %@ = %p; %@ = %@; %@ = %@>", [self class], self,
            @"status", @(_status), @"board", _board, @"winningVectorIdentifier", @(self.winningVectorIdentifier), @"winner", @(self.winner)];
}

#pragma - Getters and setters

- (void)setPosition:(GamePosition)position withPiece:(GamePiece)piece {
    GamePiece oldPiece = [[self board] pieceAtRow:position.row column:position.column];
    
    if (oldPiece != GamePieceNone) {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot set piece over existing piece"];
        return;
    }
    
    if (_status == GameEngineStatusComplete) {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot set piece when game is complete"];
        return;
    }
    
    // Forward to the model
    
    [[self board] setPiece:piece atRow:position.row column:position.column];
    
    // Update status
    
    if (_board.won || _board.full) {
        _status = GameEngineStatusComplete;
    }
}

- (GamePiece)winner {
    return _board.winner;
}

- (NSUInteger)winningVectorIdentifier {
    NSUInteger identifier = 0;
    [_board won:&identifier winner:nil];
    return identifier;
}

#pragma mark - Solver

- (BOOL)solveForPiece:(GamePiece)piece position:(GamePosition*)position {
    BOOL found = NO;
    
    if (position == nil) {
        [NSException raise:NSInvalidArgumentException format:@"position must not be nil"];
    } else if (piece != GamePiecePlayerOne && piece != GamePiecePlayerTwo ) {
        [NSException raise:NSInvalidArgumentException format:@"piece %ld must be solvable for - either player one or two", (long)piece];
    } else {
        // FIXME nearly duplicate board looping code vs in -[solveForPieceHelper:board:alpha:beta]
        
        GamePiece opposite = piece == GamePiecePlayerOne ? GamePiecePlayerTwo : GamePiecePlayerOne;
        NSInteger score = opposite;
        NSUInteger bestRow = 0;
        NSUInteger bestColumn = 0;
        NSUInteger index = 0;
        
        // Micro Minimax to extract row, column solution
        for (int row = 0; row < kGEBoardDimension; row++) {
            for (int column = 0; column < kGEBoardDimension; column++, index++) {
                if (_board.pieces[index] == GamePieceNone) {
                    // Mutate board temporarily
                    _board.pieces[index] = piece;
                    
                    // Search board
                    GamePiece helperScore = [self solveForPieceHelper:opposite board:_board alpha:GamePiecePlayerTwo beta:GamePiecePlayerOne];
                    
                    // Restore board
                    _board.pieces[index] = GamePieceNone;
                    
                    if ((piece == GamePiecePlayerOne && helperScore > score)
                        || (piece == GamePiecePlayerTwo && helperScore < score)) {
                        found = YES;

                        score = helperScore;
                        bestRow = row;
                        bestColumn = column;
                    }
                }
            }
        }
        
        position->row = bestRow;
        position->column = bestColumn;
    }
    
    return found;
}

// Minimax with alpha-beta pruning
- (GamePiece)solveForPieceHelper:(GamePiece)piece board:(GameBoard*)board alpha:(NSInteger)alpha beta:(NSInteger)beta {
    GamePiece opposite = piece == GamePiecePlayerOne ? GamePiecePlayerTwo : GamePiecePlayerOne;

    if (board.won) {
        return opposite;
    } else if (board.full) {
        return GamePieceNone;
    }
    
    for (NSUInteger index = 0; index < kGEBoardSize; index++) {
        if (board.pieces[index] == GamePieceNone) {
            // Mutate board temporarily
            board.pieces[index] = piece;
            
            // Search board
            GamePiece helperScore = [self solveForPieceHelper:opposite board:board alpha:alpha beta:beta];
            
            // Restore board
            board.pieces[index] = GamePieceNone;
            
            if (piece == GamePiecePlayerOne && helperScore > alpha) {
                alpha = helperScore;
                
                if (alpha >= beta) {
                    // Prune
                    return alpha;
                }
            } else if (piece == GamePiecePlayerTwo && helperScore < beta) {
                beta = helperScore;
                
                if (alpha >= beta) {
                    // Prune
                    return beta;
                }
            }
        }
    }
    
    return piece == GamePiecePlayerOne ? alpha : beta;
}

@end
