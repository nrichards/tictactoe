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
    return [NSString stringWithFormat:@"<%@ = %p; %@ = %@; %@ = %@; %@ = %@>", [self class], self,
            @"identifier", @(_identifier), @"score", @(_score), @"isPlayable",@(_isPlayable)];
}

@end

#pragma mark - GameBoard

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

- (instancetype)copyWithZone:(NSZone *)zone {
    GameBoard *newBoard = [[self class] allocWithZone:zone];
    if (_pieces) {
        // FIXME duplicate code
        newBoard->_pieces = malloc(sizeof(GamePiece) * kGEBoardSize);
        memcpy(newBoard->_pieces, _pieces, sizeof(GamePiece) * kGEBoardSize);
    } else {
        newBoard->_pieces = nil;
    }
    return newBoard;
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
            [pieces appendFormat:@"%d%@", _pieces[row * kGEBoardDimension + column], comma];
        }
        [pieces appendString:@"]"];
    }
    
    return [NSString stringWithFormat:@"<%@ = %p; pieces = [%@]>", [self class], self, pieces];
}

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
        NSInteger score = 0;
        
        for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
            GamePiece piece = _pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GamePieceNone) {
                attribute.isPlayable = YES;
            }
        }
        
        attribute.score = score;
        [attributes addObject:attribute];
    }
    
    // Walk across the rows of each column
    for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
        attribute = [[GameBoardVectorAttributes alloc] initWithIdentifier:identifier++];
        NSInteger score = 0;
        
        for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
            GamePiece piece = _pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GamePieceNone) {
                attribute.isPlayable = YES;
            }
        }
        
        attribute.score = score;
        [attributes addObject:attribute];
    }
    
    // Walk across each diagonal, starting at either top-left or bottom-left
    for (NSUInteger diagonal = 0; diagonal < 2; diagonal++) {
        attribute = [[GameBoardVectorAttributes alloc] initWithIdentifier:identifier++];
        NSInteger score = 0;

        // To reduce code duplication, consolidate the calculation code in one loop, and extract the
        // code that changes based upon the 'diagonal' parameter, here.
        const NSUInteger rowStart = (diagonal == 0 ? 0 : kGEBoardDimension-1);
        const NSUInteger rowIncr = (diagonal == 0 ? 1 : -1);

        for (NSInteger row = rowStart, column = 0; column != kGEBoardDimension; row += rowIncr, column++) {
            GamePiece piece = _pieces[row * kGEBoardDimension + column];
            score += piece;
            
            if (piece == GamePieceNone) {
                attribute.isPlayable = YES;
            }
        }
        
        attribute.score = score;
        [attributes addObject:attribute];
    }
    
    return attributes;
}

- (BOOL)won {
    NSArray *vectorAttributes = self.vectorAttributes;
    
    // Check if either player reached the winning score
    for (GameBoardVectorAttributes *attribute in vectorAttributes) {
        if (ABS(attribute.score) == kGEBoardDimension) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)full {
    for (int i = 0; i < 9; i++) {
        if (_pieces[i] == GamePieceNone)
            return NO;
    }
    return YES;
}

- (GamePiece)winner {
    NSArray *attributes = [self vectorAttributes];
    GamePiece winningPiece = GamePieceNone;
    
    for (GameBoardVectorAttributes *attribute in attributes) {
        if (ABS(attribute.score) == kGEBoardDimension) {
            if (winningPiece != GamePieceNone) {
                // Error - corrupt board with more than one winner
                return GamePieceNone;
            }
            
            winningPiece = signbit(attribute.score) ? GamePiecePlayerTwo : GamePiecePlayerOne; // TRICKY
        }
    }
    
    return winningPiece;
}

@end
