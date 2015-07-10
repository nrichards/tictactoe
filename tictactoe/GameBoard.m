//
//  GameBoard.m
//  tictactoe
//
//  Created by Nicholas Richards on 7/9/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import "GameBoard.h"

#pragma mark - GameBoardVectorAttributes

@implementation GameBoardVectorAttributes

- (instancetype)initWithIdentifier:(NSUInteger)identifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p, %@: %@, %@: %@, %@: %@>", [self class], self,
            @"identifier", @(self.identifier), @"score", @(self.score), @"isPlayable",@(self.isPlayable)];
}

@end

#pragma mark - GameBoard

@implementation GameBoard

- (instancetype)init {
    self = [super init];
    if (self) {
        _pieces = malloc(sizeof(GameEnginePiece) * kGEBoardSize); // freed in dealloc
        
        for (int arraySize = 0; arraySize <= kGEBoardSize; arraySize++) {
            _pieces[arraySize] = GameEnginePieceNone;
        }
    }
    return self;
}

- (void)dealloc {
    free(_pieces);
    _pieces = 0ULL;
}

- (GameEnginePiece)pieceAtRow:(NSUInteger)row column:(NSUInteger)column {
    NSUInteger arrayIndex = row * kGEBoardDimension + column;
    if (arrayIndex >= kGEBoardSize) {
        [NSException raise:NSInvalidArgumentException format:@"Row %lu column %lu is out of bounds", (unsigned long)row, (unsigned long)column];
        return GameEnginePieceNone;
    }
    
    GameEnginePiece piece = _pieces[row * kGEBoardDimension + column];
    return piece;
}

- (void)setPiece:(GameEnginePiece)piece atRow:(NSUInteger)row column:(NSUInteger)column {
    NSUInteger arrayIndex = row * kGEBoardDimension + column;
    if (arrayIndex >= kGEBoardSize) {
        [NSException raise:NSInvalidArgumentException format:@"Row %lu column %lu is out of bounds", (unsigned long)row, (unsigned long)column];
        return;
    }
    
    _pieces[row * kGEBoardDimension + column] = piece;
}

// Gather statistics on the status of the board
- (NSArray*)vectorAttributes {
    // FIXME optimize reallocation
    // FIXME remove redundancy
    // FIXME optimize over-setting isPlayable
    
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:kGEBoardVectorCount];
    GameBoardVectorAttributes *attribute;
    NSUInteger identifier = 0;
    
    // Walk across the columns of each row
    for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
        attribute = [[GameBoardVectorAttributes alloc] initWithIdentifier:identifier++];
        [attributes addObject:attribute];
        NSUInteger score = 0;
        
        for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
            GameEnginePiece piece = _pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GameEnginePieceNone) {
                attribute.isPlayable = YES;
            }
        }
        
        attribute.score = score;
    }
    
    // Walk across the rows of each column
    for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
        attribute = [[GameBoardVectorAttributes alloc] initWithIdentifier:identifier++];
        [attributes addObject:attribute];
        NSUInteger score = 0;
        
        for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
            GameEnginePiece piece = _pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GameEnginePieceNone) {
                attribute.isPlayable = YES;
            }
        }
        
        attribute.score = score;
    }
    
    // Walk across each diagonal, starting at either top-left or bottom-left
    for (NSUInteger diagonal = 0; diagonal < 2; diagonal++) {
        attribute = [[GameBoardVectorAttributes alloc] initWithIdentifier:identifier++];
        [attributes addObject:attribute];
        NSUInteger score = 0;
        
        // Presume two diagonals.
        // TRICKY: Using signed NSInteger for row,column and negative terminal index.
        const NSUInteger rowColumnStart = (diagonal == 0 ? 0 : kGEBoardDimension-1);
        const NSInteger rowColumnEnd = (diagonal == 0 ? kGEBoardDimension : -1);
        const NSInteger rowColumnIncr = (diagonal == 0 ? 1 : -1);
        
        // Walk diagonals keeping indices the same: row == column
        for (NSInteger row = rowColumnStart, column = row; row != rowColumnEnd; row += rowColumnIncr, column = row) {
            GameEnginePiece piece = _pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GameEnginePieceNone) {
                attribute.isPlayable = YES;
            }
        }
        
        attribute.score = score;
    }
    
    return attributes;
}

- (BOOL)firstPlayablePositionForVectorIdentifier:(NSUInteger)identifier position:(GameEnginePosition*)position {
    // FIXME reduce redundant logic
    
    BOOL found = NO;
    
    if (identifier >= kGEBoardVectorCount) {
        [NSException raise:NSInvalidArgumentException format:@"identifier %lu is out of bounds", (unsigned long)identifier];
    } else if (position == nil) {
        [NSException raise:NSInvalidArgumentException format:@"position must not be nil"];
    } else {
        // Walking approach varies based upon whether it's for row-wise, column-wise, or diagonal-wise
        if (identifier < kGEBoardDimension) {
            // row-wise
            NSUInteger row = identifier;

            // Walk through the board examining positions for availability
            for (NSUInteger column = 0; !found && column < kGEBoardDimension; column++) {
                if (_pieces[row * kGEBoardDimension + column] == GameEnginePieceNone) {
                    GameEnginePosition pos = {.row=row, .column=column};
                    *position = pos;
                    found = YES;
                }
            }
        } else if (identifier < kGEBoardDimension * 2) {
            // column-wise
            NSUInteger column = identifier - kGEBoardDimension;

            for (NSUInteger row = 0; !found && row < kGEBoardDimension; row++) {
                if (_pieces[row * kGEBoardDimension + column] == GameEnginePieceNone) {
                    GameEnginePosition pos = {.row=row, .column=column};
                    *position = pos;
                    found = YES;
                }
            }
        } else {
            // diagonal-wise
            NSUInteger diagonal = (identifier == kGEBoardVectorCount-2) ? 0 : 1;
        
            const NSUInteger rowColumnStart = (diagonal == 0 ? 0 : kGEBoardDimension-1);
            const NSInteger rowColumnEnd = (diagonal == 0 ? kGEBoardDimension : -1);
            const NSInteger rowColumnIncr = (diagonal == 0 ? 1 : -1);
            
            // Walk diagonals keeping indices the same: row == column
            for (NSInteger row = rowColumnStart, column = row; !found && row != rowColumnEnd; row += rowColumnIncr, column = row) {
                GameEnginePiece piece = _pieces[row * kGEBoardDimension + column];
                
                if (piece == GameEnginePieceNone) {
                    GameEnginePosition pos = {.row=row, .column=column};
                    *position = pos;
                    found = YES;
                }
            }
        }
    }
    
    return found;
}

@end
