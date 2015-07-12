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

// My Tic-Tac-Toe algorithm has two phases.
// It breaks down the board into eight "success vectors" and defensively
// chooses the vector with the highest need for competitive attention.
// Then it determines if it would be a safe move to continue offensively
// building up a vector primarily made up of its own pieces.
//
// Vectors are the rows, columns, and diagonals of the board.
// Each vector has a score which is the weight, positive or negative, of
// the cumulative efforts of player one or player two, respectively.
// Vectors have a convenience field "isPlayable" to help the algorithm skip
// consideration of unplayable solutions quickly.
//
// Vector identifiers for a 3x3 tictactoe board. E.g. 4 is the middle column,
// and 7 is the diagonal from bottom-left to top-right.
//   6 3 4 5
//   0 ~ ~ ~
//   1 ~ ~ ~
//   2 ~ ~ ~
//   7

- (NSArray*)orderByTacticalWorthAscending:(NSArray*)attributes forPiece:(GameEnginePiece)piece {
    NSAssert(GameEnginePiecePlayerTwo < 0, @"My ordering logic assumes player two contributes negatively to the score, and player one positively");
    
    // Defensive
    
    NSArray *sortedAttributes = [attributes sortedArrayUsingComparator:^(GameBoardVectorAttributes *attribute1, GameBoardVectorAttributes *attribute2) {
        NSComparisonResult result = NSOrderedSame;
        
        // Consider score
        if (attribute1.score > attribute2.score) {
            result = NSOrderedDescending;
        }
        
        if (attribute1.score < attribute2.score) {
            result = NSOrderedAscending;
        }
        
        // Consider which piece we're ordering for - flip order if needed
        // ASSUME player one's score is positive (+)
        if (result != NSOrderedSame && piece == GameEnginePiecePlayerOne) {
            if (result == NSOrderedAscending) {
                result = NSOrderedDescending;
            } else {
                result = NSOrderedAscending;
            }
        }
        
        // Consider playability. Suppress unplayable attributes.
        if (attribute1.isPlayable == NO && attribute2.isPlayable == YES) {
            result = NSOrderedAscending;
        }
        if (attribute1.isPlayable == YES && attribute2.isPlayable == NO) {
            result = NSOrderedDescending;
        }
        
        // Ensure determinism
        if (result == NSOrderedSame) {
            if (attribute1.identifier > attribute2.identifier) {
                result = NSOrderedDescending;
            } else {
                result = NSOrderedAscending;
            }
        }
        
        return result;
    }];
    
    // Offensive heuristic
    
    NSUInteger index1 = 0, index2 = 0;
    NSInteger myHighScore = 0;
    
    // Find my high score, the first playable vector's score.
    // To be clear, we ignore non-playable vectors because it's no longer possible to use them.
    for (NSUInteger index = 0; index < sortedAttributes.count; index++) {
        GameBoardVectorAttributes *attribute = [sortedAttributes objectAtIndex:index];
        if (attribute.isPlayable) {
            myHighScore = attribute.score;
            index1 = index;
            index2 = kGEBoardVectorCount-1; // serves as a flag
            break; // first only
        }
    }
    
    // Heuristic: if I'm about to win, then quit being defensive and go FTW!
    if (ABS(myHighScore) == kGEBoardDimension-1) {
        if (index1 != index2) {
            NSMutableArray *mutableSortedAttributes = [sortedAttributes mutableCopy];
            id obj = [mutableSortedAttributes objectAtIndex:index1];
            [mutableSortedAttributes removeObjectAtIndex:index1];
            [mutableSortedAttributes addObject:obj];
            sortedAttributes = mutableSortedAttributes;
        }
    }
    
    return sortedAttributes;
}

- (BOOL)solveForPiece:(GameEnginePiece)piece position:(GameEnginePosition*)position {
    BOOL found = NO;
    
    if (position == nil) {
        [NSException raise:NSInvalidArgumentException format:@"position must not be nil"];
    } else {
        // get attribute records
        NSArray *attributes = [[self board] vectorAttributes];
        
        // sort for score playability
        NSArray *sortedAttributes = [self orderByTacticalWorthAscending:attributes forPiece:piece];
        
        // return the highest tactical value record, if any
        GameBoardVectorAttributes *highestValueAttribute = [sortedAttributes lastObject];
        if (highestValueAttribute.isPlayable) {
            found = [[self board] firstPlayablePositionForVectorIdentifier:highestValueAttribute.identifier position:position];
        }
    }
    
    return found;
}

@end
