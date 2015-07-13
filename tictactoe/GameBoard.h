//
//  GameBoard.h
//  tictactoe
//
//  Created by Nicholas Richards on 7/9/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - GameBoard support data structures

// Board size
static const NSUInteger kGEBoardDimension = 3;
static const NSUInteger kGEBoardSize = kGEBoardDimension * kGEBoardDimension;
static const NSUInteger kGEBoardVectorCount = 2 * kGEBoardDimension + 2; // rows, columns, diagonals

// Piece - what piece is played on the board, or none
// Integer value used to score incrementally. Positive is player one. Negative, player two.
// TRICKY: Do not change values. App depends upon these integer values for scoring. 
typedef NS_ENUM(NSInteger, GamePiece) {
    GamePieceNone = 0,
    GamePiecePlayerOne = 1,
    GamePiecePlayerTwo = -1,
};

// Position - where on the board
struct GamePosition {
    NSInteger row;
    NSInteger column;
};
typedef struct GamePosition GamePosition;

#pragma mark - GameBoardVectorAttributes

// Board status - how a particular row/column/diagonal success-vector is doing tactically
@interface GameBoardVectorAttributes : NSObject

@property(nonatomic,assign) NSUInteger identifier; // 8 id's: row 0,1,2, column 0,1,2, diagonal 0(topleft -> bottomright),1(bottomleft -> topright)
@property(nonatomic,assign) NSInteger score; // how much this vector leans to player one or player two
@property(nonatomic,assign) BOOL isPlayable; // if another move can be played in this vector

- (instancetype)initWithIdentifier:(NSUInteger)identifier;

@end

#pragma mark - GameBoard

// Board - the backing data structure and related helpers
@interface GameBoard : NSObject <NSCopying>

@property(nonatomic) GamePiece *pieces; // Standard C array. When setting: use with extreme caution, transfers 'malloc'd memory ownership, no side effects.

- (GamePiece)pieceAtRow:(NSUInteger)row column:(NSUInteger)column;
- (void)setPiece:(GamePiece)piece atRow:(NSUInteger)row column:(NSUInteger)column;

- (NSArray*)vectorAttributes; // compute scores and more for each potential game-success vector

- (BOOL)won; // Has the game been won
- (BOOL)full;
- (GamePiece)winner; // Calculate whether the board overall wins for player one, two, or is a draw

@end
