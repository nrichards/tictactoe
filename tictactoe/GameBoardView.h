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

- (void)presentBoard; // Display cross-hatch and input buttons. Resets board if repeatedly called.
- (void)setPiece:(GameEnginePiece)piece forIndex:(NSInteger)index;
- (void)setUserInteraction:(BOOL)enabled forPiece:(NSInteger)index; // Control piece's userInteraction

@end

@protocol GameBoardViewDelegate <NSObject>
@optional

// Called when a button is clicked.
- (void)gameBoardView:(GameBoardView *)boardView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
