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

- (void)presentBoard {
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
    NSLog(@"piecePressed %@", button);
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(gameBoardView:clickedButtonAtIndex:)]) {
        [_delegate gameBoardView:self clickedButtonAtIndex:button.tag];
    }
}

- (void)setPiece:(GameEnginePiece)piece forIndex:(NSInteger)index
{
    if (index < 0 || index + 1 > [self.subviews count]) {
        [NSException raise:NSInvalidArgumentException format:@"invalid index %d", index];
    }
    
    NSString *titleText;
    switch (piece) {
        case GameEnginePiecePlayerOne:
            titleText = kPlayerOneText;
            break;
        case GameEnginePiecePlayerTwo:
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

@end