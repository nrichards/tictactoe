//
//  GameBoard.h
//  tictactoe
//
//  Created by Nicholas Richards on 7/9/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE:
// "identifier" = 8 id's: row 0,1,2, column 0,1,2, diagonal 0(topleft -> bottomright),1(bottomleft -> topright)

#pragma mark - Support data structures

// Board size
static const NSUInteger kGEBoardDimension = 3;
static const NSUInteger kGEBoardSize = kGEBoardDimension * kGEBoardDimension;
static const NSUInteger kGEBoardIdentifierCount = 2 * kGEBoardDimension + 2; // as above

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

#pragma mark - GameBoard

// Board - the backing data structure and related helpers
@interface GameBoard : NSObject

@property(nonatomic) GamePiece *pieces; // Game model, a simple array. Free the array before setting; it is malloc'd.

- (GamePiece)pieceAtRow:(NSUInteger)row column:(NSUInteger)column; // Get the piece from the given position
- (void)setPiece:(GamePiece)piece atRow:(NSUInteger)row column:(NSUInteger)column; // Put a piece into the given position

- (GamePiece)winner; // Calculate the winning player if any
- (BOOL)full; // Is the game board completely populated with pieces, are there no free spaces
- (BOOL)won; // Has the game been won
- (BOOL)won:(NSUInteger*)identifier winner:(GamePiece*)piece; // Most win. Initializes in/out pointers to defaults, if not-nil.

@end
