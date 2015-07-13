//
//  GameBoardView.m
//  tictactoe
//
//  Created by Nicholas Richards on 7/11/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import "GameBoardView.h"

#import "GameBoard.h"
#import "UIButton+PLColor.h"

static NSString *kPlayerOneText = @"X";
static NSString *kPlayerTwoText = @"O";

#define DEBUG_PIECE_TAG 0

@interface GameBoardView()
@property (nonatomic,retain) UIColor *normalButtonColor;
@property (nonatomic,retain) UIColor *highlightButtonColor;
@property (nonatomic,retain) UIColor *buttonTitleColor;
@property (nonatomic) CGFloat buttonFramePadding;
@end

@implementation GameBoardView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = YES;
    _normalButtonColor = [UIColor whiteColor];
    _highlightButtonColor = [UIColor lightGrayColor];
    _buttonTitleColor = [UIColor blackColor];
    _buttonFramePadding = 2.0f;
}

- (void)showBoard {
    // reset board
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    // Use our bounds to render play field

    CGFloat pieceWidth = self.bounds.size.width / kGEBoardDimension;
    CGFloat pieceHeight = self.bounds.size.height / kGEBoardDimension;

    for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
        for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
            
            UIButton *piece = [UIButton buttonWithType:UIButtonTypeCustom];
            piece.tag = row * kGEBoardDimension + column; // optimization, an index

#if DEBUG_PIECE_TAG
            [piece setTitle:[NSString stringWithFormat:@"%d",piece.tag] forState:UIControlStateNormal];
#endif
            
            // Layout and look
            CGRect pieceBounds = CGRectMake(0,0, pieceWidth, pieceHeight);
            
            piece.bounds = pieceBounds;
            
            // two colors: one for normal, one pressed
            [piece setBackgroundColor:_normalButtonColor forState:UIControlStateNormal];
            [piece setBackgroundColor:_highlightButtonColor forState:UIControlStateHighlighted];
            [piece setTitleColor:_buttonTitleColor forState:UIControlStateNormal];
            
            piece.layer.borderWidth = _buttonFramePadding;
            
            CGRect pieceFrame = piece.frame;
            // TRICKY: column,row not row,column
            pieceFrame.origin = CGPointMake(column * pieceWidth, row * pieceHeight);
            piece.frame = pieceFrame;
            
            // Press event
            [piece addTarget:self action:@selector(piecePressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:piece];
        }
    }
}

- (void)piecePressed:(UIButton*)button {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(gameBoardView:clickedButtonAtIndex:)]) {
        [_delegate gameBoardView:self clickedButtonAtIndex:button.tag];
    }
}

- (void)setPiece:(GamePiece)piece forIndex:(NSInteger)index
{
    if (index < 0 || index + 1 > [self.subviews count]) {
        [NSException raise:NSInvalidArgumentException format:@"invalid index %d", index];
    }
    
    NSString *titleText;
    switch (piece) {
        case GamePiecePlayerOne:
            titleText = kPlayerOneText;
            break;
        case GamePiecePlayerTwo:
            titleText = kPlayerTwoText;
            break;
        default:
            titleText = @"";
            break;
    }
    
    UIButton *button = [self.subviews objectAtIndex:index];
    NSAssert(button.tag == index, @"Tag %d does not equal index %d", button.tag, index);
    [button setTitle:titleText forState:UIControlStateNormal];
}

- (void)setUserInteraction:(BOOL)enabled forPiece:(NSInteger)index {
    if (index < 0 || index + 1 > [self.subviews count]) {
        [NSException raise:NSInvalidArgumentException format:@"invalid index %d", index];
    }

    UIButton *button = [self.subviews objectAtIndex:index];
    NSAssert(button.tag == index, @"Tag %d does not equal index %d", button.tag, index);
    button.userInteractionEnabled = NO;
}

- (void)highlightVectorIdentifier:(NSUInteger)identifier {
    if (identifier >= kGEBoardVectorCount) {
        [NSException raise:NSInvalidArgumentException format:@"identifier %lu is out of bounds", (unsigned long)identifier];
    } else {
        // Walking approach varies based upon whether it's for row-wise, column-wise, or diagonal-wise
        if (identifier < kGEBoardDimension) {
            // row-wise
            NSUInteger row = identifier;
            
            // Walk through the board examining positions for availability
            for (NSUInteger column = 0; column < kGEBoardDimension; column++) {
                [[[self subviews] objectAtIndex:row * kGEBoardDimension + column] setBackgroundColor:_highlightButtonColor forState:UIControlStateNormal];
            }
        } else if (identifier < kGEBoardDimension * 2) {
            // column-wise
            NSUInteger column = identifier - kGEBoardDimension;
            
            for (NSUInteger row = 0; row < kGEBoardDimension; row++) {
                [[[self subviews] objectAtIndex:row * kGEBoardDimension + column] setBackgroundColor:_highlightButtonColor forState:UIControlStateNormal];
            }
        } else {
            // diagonal-wise
            NSUInteger diagonal = (identifier == kGEBoardVectorCount-2) ? 0 : 1;
            
            // To reduce code duplication, consolidate the calculation code in one loop, and extract the
            // code that changes based upon the 'diagonal' parameter, here.
            const NSUInteger rowStart = (diagonal == 0 ? 0 : kGEBoardDimension-1);
            const NSUInteger rowIncr = (diagonal == 0 ? 1 : -1);
            
            for (NSInteger row = rowStart, column = 0; column != kGEBoardDimension; row += rowIncr, column++) {
                [[[self subviews] objectAtIndex:row * kGEBoardDimension + column] setBackgroundColor:_highlightButtonColor forState:UIControlStateNormal];
            }
        }
    }
}

@end
