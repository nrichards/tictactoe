//
//  GameEngine.m
//  tictactoe
//
//  Created by Nicholas Richards on 7/8/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import "GameEngine.h"

@implementation GameEngineBoard
- (instancetype)init {
    self = [super init];
    if (self) {
        _piecesArr = [NSMutableArray arrayWithCapacity:kGEBoardSize];
        for (int arraySize = 0; arraySize <= kGEBoardSize; arraySize++) {
            [_piecesArr addObject:[NSNumber numberWithInteger:GameEnginePieceNone]];
        }
        
        _pieces = malloc(sizeof(GameEnginePiece) * kGEBoardSize);
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

@end

// ------

@implementation GameEngineBoardVectorAttributes
- (instancetype)initWithVectorId:(NSUInteger)vectorId {
    self = [super init];
    if (self) {
        _vectorId = vectorId;
    }
    return self;
}
@end

// ------

@implementation GameEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = GameEngineStatusClear;
        _board = [[GameEngineBoard alloc] init];
    }
    return self;
}


- (GameEnginePosition)solveForPiece:(GameEnginePiece)piece {
    GameEnginePosition position = {0};
    
    // get summations
    
    // pick the first summation with a free spot
    
    
    
    return position;
}

- (NSArray*)boardVectorAttributes {
    // TODO optimize reallocation
    // TODO remove redundancy
    // TODO optimize over-setting isPlayable
    
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:kGEBoardVectorCount];
    GameEngineBoardVectorAttributes *attribute;
    NSUInteger vectorId = 0;
    
    // Walk across the columns of each row
    for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
        attribute = [[GameEngineBoardVectorAttributes alloc] initWithVectorId:vectorId++];
        [attributes addObject:attribute];
        NSUInteger score = 0;
        
        for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
            GameEnginePiece piece = [self board].pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GameEnginePieceNone) {
                attribute.isPlayable = YES;
            }
        }

        attribute.vectorScore = score;
    }
    
    // Walk across the rows of each column
    for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
        attribute = [[GameEngineBoardVectorAttributes alloc] initWithVectorId:vectorId++];
        [attributes addObject:attribute];
        NSUInteger score = 0;
        
        for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
            GameEnginePiece piece = [self board].pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GameEnginePieceNone) {
                attribute.isPlayable = YES;
            }
        }
        
        attribute.vectorScore = score;
    }
    
    // Walk across each diagonal, starting at either top-left or bottom-left
    for (NSUInteger diagonal = 0; diagonal < 2; diagonal++) {
        attribute = [[GameEngineBoardVectorAttributes alloc] initWithVectorId:vectorId++];
        [attributes addObject:attribute];
        NSUInteger score = 0;

        // Presume two diagonals.
        // TRICKY: Using signed NSInteger for row,column and negative terminal index.
        const NSUInteger rowColumnStart = (diagonal == 0 ? 0 : kGEBoardDimension-1);
        const NSInteger rowColumnEnd = (diagonal == 0 ? kGEBoardDimension : -1);
        const NSInteger rowColumnIncr = (diagonal == 0 ? 1 : -1);
        
        // Walk diagonals keeping indices the same: row == column
        for (NSInteger row = rowColumnStart, column = row; row != rowColumnEnd; row += rowColumnIncr, column = row) {
            GameEnginePiece piece = [self board].pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GameEnginePieceNone) {
                attribute.isPlayable = YES;
            }
        }

        attribute.vectorScore = score;
    }
    
    return attributes;
}


@end
