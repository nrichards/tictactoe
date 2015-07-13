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
    // FIXME remove magic from 'winning vector' magic number -1
    self = [super init];
    if (self) {
        _status = GameEngineStatusClear;
        _board = [[GameBoard alloc] init];
        _winningVectorIdentifier = 0;
        _winner = GameEnginePieceNone;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@ = %p; %@ = %@; %@ = %p; %@ = %@; %@ = %@>", [self class], self,
            @"status", @(_status), @"board", _board, @"winningVectorIdentifier", @(_winningVectorIdentifier), @"winner", @(_winner)];
}

- (GameEnginePiece)pieceForPosition:(GameEnginePosition)position {
    return [[self board] pieceAtRow:position.row column:position.column];
}

- (void)setPosition:(GameEnginePosition)position withPiece:(GameEnginePiece)piece {
    GameEnginePiece oldPiece = [[self board] pieceAtRow:position.row column:position.column];
    
    if (oldPiece != GameEnginePieceNone) {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot set piece over existing piece"];
        return;
    }
    
    if (_status == GameEngineStatusComplete) {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot set piece when game is complete"];
        return;
    }
    
    [[self board] setPiece:piece atRow:position.row column:position.column];
    
    // Update status
    
    NSArray *vectorAttributes = [[self board] vectorAttributes];
    BOOL isPlayable = NO;
    
    for (GameBoardVectorAttributes *attribute in vectorAttributes) {
        // Check if there are any pieces still playable
        if (attribute.isPlayable) {
            isPlayable = YES;
        }
        
        // Check if either player reached the winning score
        if (ABS(attribute.score) == kGEBoardDimension) {
            _status = GameEngineStatusComplete;
            _winningVectorIdentifier = attribute.identifier;
            _winner = signbit(attribute.score) ? GameEnginePiecePlayerTwo : GameEnginePiecePlayerOne;
            break; // is a terminal finding
        } else if (attribute.isPlayable == NO) {
            // Check if the game may be in progress: having some pieces in play, and some not
            _status = GameEngineStatusInProgress;
        }
    }
    
    // If absolutely no pieces are playable then the game is over, a draw
    if (isPlayable == NO) {
        _status = GameEngineStatusComplete;
    }
}

#pragma mark - Solver

- (BOOL)solveForPiece:(GameEnginePiece)piece position:(GameEnginePosition*)position {
    BOOL found = NO;
    
    if (position == nil) {
        [NSException raise:NSInvalidArgumentException format:@"position must not be nil"];
    } else if (piece != GameEnginePiecePlayerOne && piece != GameEnginePiecePlayerTwo ) {
        [NSException raise:NSInvalidArgumentException format:@"piece %d must be either player one or two", piece];
    } else {
        // Reference:
        // - http://neverstopbuilding.com/minimax
        // - https://en.wikipedia.org/wiki/Minimax#Pseudocode
        // - https://github.com/mattrajca/TTT
        // - https://www.ocf.berkeley.edu/~yosenl/extras/alphabeta/alphabeta.html
        
        GameEnginePiece opposite = piece == GameEnginePiecePlayerOne ? GameEnginePiecePlayerTwo : GameEnginePiecePlayerOne;
        NSInteger score = opposite;
        NSUInteger bestRow = 0;
        NSUInteger bestColumn = 0;
        NSUInteger index = 0;
        
        for (int row = 0; row < kGEBoardDimension; row++) {
            for (int column = 0; column < kGEBoardDimension; column++) {
                index++;
                if (_board.pieces[index] == GameEnginePieceNone) {
                    // Mutate board
                    _board.pieces[index] = piece;
                    
                    // Search board
                    GameEnginePiece helperScore = [self solveForPieceHelper:_board piece:opposite alpha:GameEnginePiecePlayerTwo beta:GameEnginePiecePlayerOne];
                    
                    // Restore board
                    _board.pieces[index] = GameEnginePieceNone;
                    
                    if ((piece == GameEnginePiecePlayerOne && helperScore > score)
                        || (piece == GameEnginePiecePlayerTwo && helperScore < score)) {
                        score = helperScore;
                        bestRow = row;
                        bestColumn = column;
                    }
                }
            }
        }
        
        position->row = bestRow;
        position->column = bestColumn;
        
        found = YES;
    }
    
    return found;
}

- (GameEnginePiece)solveForPieceHelper:(GameBoard*)board piece:(GameEnginePiece)piece alpha:(NSInteger)alpha beta:(NSInteger)beta {
    // Minimax with alpha/beta 
    GameEnginePiece opposite = piece == GameEnginePiecePlayerOne ? GameEnginePiecePlayerTwo : GameEnginePiecePlayerOne;

    if (board.won) {
        return opposite;
    } else if (board.full) {
        return GameEnginePieceNone;
    }
    
    for (NSUInteger index = 0; index < kGEBoardSize; index++) {
        if (board.pieces[index] == GameEnginePieceNone) {
            // Mutate board
            board.pieces[index] = piece;
            
            // Search board
            GameEnginePiece helperScore = [self solveForPieceHelper:board piece:opposite alpha:alpha beta:beta];
            
            // Restore board
            board.pieces[index] = GameEnginePieceNone;
            
            if (piece == GameEnginePiecePlayerOne && helperScore > alpha) {
                alpha = helperScore;
                
                if (alpha >= beta) {
                    return alpha;
                }
            } else if (piece == GameEnginePiecePlayerTwo && helperScore < beta) {
                beta = helperScore;
                
                if (alpha >= beta) {
                    return beta;
                }
            }
        }
    }
    
    return piece == GameEnginePiecePlayerOne ? alpha : beta;
}

@end
