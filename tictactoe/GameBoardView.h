//
//  GameBoardView.h
//  tictactoe
//
//  Created by Nicholas Richards on 7/11/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameBoard.h"

@protocol GameBoardViewDelegate;

@interface GameBoardView : UIView

@property(nonatomic,assign) id delegate; // GameBoardViewDelegate weak reference

- (void)showBoard; // Display cross-hatch and input buttons. May be called repeatedly, clears prior contents.

- (void)setPiece:(GamePiece)piece forIndex:(NSInteger)index;

- (void)setUserInteraction:(BOOL)enabled forPiece:(NSInteger)index; // Control single piece's userInteraction
- (void)highlightIdentifier:(NSUInteger)vectorIdentifier; // Use to illustrate the winning moves

@end

@protocol GameBoardViewDelegate <NSObject>

- (void)gameBoardView:(GameBoardView *)boardView clickedButtonAtIndex:(NSInteger)buttonIndex; // Called when a button is clicked

@end
