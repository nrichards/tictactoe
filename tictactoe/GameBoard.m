//
//  GameBoard.m
//  tictactoe
//
//  Created by Nicholas Richards on 7/9/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import "GameBoard.h"

@implementation GameBoard

- (instancetype)init {
    self = [super init];
    if (self) {
        _pieces = malloc(sizeof(GamePiece) * kGEBoardSize); // freed in dealloc
        
        for (int arraySize = 0; arraySize <= kGEBoardSize; arraySize++) {
            _pieces[arraySize] = GamePieceNone;
        }
    }
    return self;
}

- (void)dealloc {
    free(_pieces);
    _pieces = 0ULL;
}

- (NSString*)description {
    NSMutableString *pieces = [NSMutableString stringWithString:@""];
    
    for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
        if (pieces.length > 0) {
            [pieces appendString:@", "];
        }
        
        [pieces appendString:@"["];
        
        for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
            NSString *comma;
            if (column != kGEBoardDimension - 1) {
                comma = @", ";
            } else {
                comma = @"";
            }
            [pieces appendFormat:@"%ld%@", (long)_pieces[row * kGEBoardDimension + column], comma];
        }
        
        [pieces appendString:@"]"];
    }
    
    return [NSString stringWithFormat:@"<%@ = %p; pieces = [%@]>", [self class], self, pieces];
}

#pragma mark - Getters and setters

- (GamePiece)pieceAtRow:(NSUInteger)row column:(NSUInteger)column {
    NSUInteger arrayIndex = row * kGEBoardDimension + column;
    
    if (arrayIndex >= kGEBoardSize) {
        [NSException raise:NSInvalidArgumentException format:@"Row %lu column %lu is out of bounds", (unsigned long)row, (unsigned long)column];
        return GamePieceNone;
    }
    
    GamePiece piece = _pieces[row * kGEBoardDimension + column];
    return piece;
}

- (void)setPiece:(GamePiece)piece atRow:(NSUInteger)row column:(NSUInteger)column {
    NSUInteger arrayIndex = row * kGEBoardDimension + column;
    
    if (arrayIndex >= kGEBoardSize) {
        [NSException raise:NSInvalidArgumentException format:@"Row %lu column %lu is out of bounds", (unsigned long)row, (unsigned long)column];
        return;
    }
    
    _pieces[row * kGEBoardDimension + column] = piece;
}

- (void)setPieces:(GamePiece *)pieces {
    free(_pieces);
    _pieces = pieces; // Take ownership.
}

- (BOOL)won {
    return [self won:nil winner:nil];
}

- (BOOL)won:(NSUInteger*)pIdentifier winner:(GamePiece *)pWinner {
    NSAssert(kGEBoardDimension == 3, @"Depends upon hardcoded values");
    
    BOOL result = NO;
    NSUInteger identifier = 0;
    GamePiece winner = GamePieceNone;
    
    for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
        GamePiece middleForRow = _pieces[row * kGEBoardDimension + 1];
        GamePiece middleForColumn = _pieces[1 * kGEBoardDimension + row];
        
        if (middleForRow != GamePieceNone) {
            if (middleForRow == _pieces[row * kGEBoardDimension + 0] && middleForRow == _pieces[row * kGEBoardDimension + 2]) {
                result = YES;
                identifier = row;
                winner = middleForRow;
            }
        }

        if (middleForColumn != GamePieceNone) {
            if (middleForColumn == _pieces[0 * kGEBoardDimension + row] && middleForColumn == _pieces[2 * kGEBoardDimension + row]) {
                result = YES;
                identifier = row + kGEBoardDimension;
                winner = middleForColumn;
            }
        }
    }

    if (result == NO) {
        GamePiece middle = _pieces[1 * kGEBoardDimension + 1];
        
        if (middle != GamePieceNone) {
            if (middle == _pieces[0 * kGEBoardDimension + 0] && middle == _pieces[2 * kGEBoardDimension + 2]) {
                result = YES;
                identifier = kGEBoardDimension * 2;
                winner = middle;
            } else if (middle == _pieces[0 * kGEBoardDimension + 2] && middle == _pieces[2 * kGEBoardDimension + 0]) {
                result = YES;
                identifier = kGEBoardDimension * 2 + 1;
                winner = middle;
            }
        }
    }
    
    if (pIdentifier) {
        *pIdentifier = identifier;
    }
    
    if (pWinner) {
        *pWinner = winner;
    }
    
    return result;
}

- (BOOL)full {
    for (NSUInteger index = 0; index < kGEBoardSize; index++) {
        if (_pieces[index] == GamePieceNone) {
            return NO;
        }
    }
    
    return YES;
}

- (GamePiece)winner {
    GamePiece winningPiece = GamePieceNone;
    [self won:nil winner:&winningPiece];
    return winningPiece;
}

@end
