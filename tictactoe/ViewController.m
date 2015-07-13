//
//  ViewController.m
//  tictactoe
//
//  Created by Nicholas Richards on 7/8/15.
//  Copyright (c) 2015 Nicholas Richards. All rights reserved.
//

#import "ViewController.h"
#import "GameEngine.h"

#define DEVELOPMENT_SKIP_CHOICE 0
#define DEBUG_ACTIVITY 0

static const CGFloat kTTTCPUThinkTime = 0.3f; // Artificial delay to make it feel like something is going on

@interface ViewController ()

@property (nonatomic,assign) GamePiece humanPiece;
@property (nonatomic,assign) GamePiece cpuPiece;
@property (nonatomic) GamePiece turn;
@property (nonatomic,retain) GameEngine *gameEngine;

@end

@implementation ViewController

// Initializes the resources and starts the game
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _instructionsText.text = @"Welcome to\nTic-Tac-Toe!";
    _statusText.text = @"";
    
    _gameBoardView.delegate = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#if DEVELOPMENT_SKIP_CHOICE
        _humanPiece = GamePiecePlayerOne;
        _cpuPiece = GamePiecePlayerTwo;
        _turn = _humanPiece;
        [self startGame];
#else
        [self restartButtonPressed:nil];
#endif
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI handling 

// Display popup with cancel, Human first, CPU first choices
- (IBAction)restartButtonPressed:(id)sender {
    // FIXME Test on device. Attempt to avoid leaking alert controllers, seen when Profiling on Simulator.
    // Rumored to be a bug in iOS Simulator: http://stackoverflow.com/questions/26273175/leaks-with-uialertcontroller
    __typeof(self) __weak weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Game"
                                                                   message:@"Who plays first?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *humanFirstAction = [UIAlertAction actionWithTitle:@"Human First" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
#if DEBUG_ACTIVITY
                                                                 NSLog(@"Human First");
#endif
                                                                 _humanPiece = GamePiecePlayerOne;
                                                                 _cpuPiece = GamePiecePlayerTwo;
                                                                 _turn = _humanPiece;
                                                                 [weakSelf startGame];
                                                             }];
    UIAlertAction *cpuFirstAction = [UIAlertAction actionWithTitle:@"CPU First" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
#if DEBUG_ACTIVITY
                                                                 NSLog(@"CPU First");
#endif
                                                                 _humanPiece = GamePiecePlayerTwo;
                                                                 _cpuPiece = GamePiecePlayerOne;
                                                                 _turn = _cpuPiece;
                                                                 [weakSelf startGame];
                                                             }];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {}];
    

    [alert addAction:humanFirstAction];
    [alert addAction:cpuFirstAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - GameBoardView delegate

// Delegate handler for clicks on the game board
- (void)gameBoardView:(GameBoardView *)boardView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_turn == _humanPiece) {
        // Pieces can be pressed once
        [boardView setUserInteraction:NO forPiece:buttonIndex];
        
        [self humanMoveAtIndex:buttonIndex];
    }
    
    // ignore taps received out-of-turn
}

#pragma mark - High level game control

// Starts the game
- (void)startGame {
    _gameEngine = [[GameEngine alloc] init];
    [_gameBoardView showBoard];
    [self nextMoveAsync];
}

// Shuts down the game and displays results
- (void)gameOver {
#if DEBUG_ACTIVITY
    NSLog(@"Game over");
#endif

    // Shut down the board
    for (NSInteger index = 0; index < kGEBoardSize; index++) {
        [_gameBoardView setUserInteraction:NO forPiece:index];
    }
    
    // Update the UI
    NSString *winner;
    BOOL showVector = NO;
    
    if (_gameEngine.winner == _cpuPiece) {
        winner = @"CPU";
        showVector = YES;
    } else if (_gameEngine.winner == _humanPiece) {
        winner = @"Human";
        showVector = YES;
    } else {
        winner = @"Draw";
    }
    
    _statusText.text = [NSString stringWithFormat:@"Game over! Winner: %@", winner];

    if (showVector) {
        [_gameBoardView highlightIdentifier:_gameEngine.winningVectorIdentifier];
    }
}

#pragma mark - Move handling for both Human and CPU

// Convenience method - avoids deep stacks
- (void)nextMoveAsync {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self nextMove];
    });
}

// Turn-taking between the players, and game-over handling
- (void)nextMove {
    // Check if game over
    if (_gameEngine.status == GameEngineStatusComplete) {
        [self gameOver];
        return;
    }
    
    if (_turn == _humanPiece) {
        // Wait for the human
#if DEBUG_ACTIVITY
        NSLog(@"Waiting for the human ...");
#endif
        _statusText.text = @"Human's turn";
    } else if (_turn == _cpuPiece) {
#if DEBUG_ACTIVITY
        NSLog(@"CPU is moving ...");
#endif
        _statusText.text = @"CPU's turn";
        // Artificial wait
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTTTCPUThinkTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cpuMove];
        });
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected player turn %ld", (long)_turn];
        return;
    }
}

// Handle a human's move
- (void)humanMoveAtIndex:(NSInteger)boardIndex {
    // Update the view
    [_gameBoardView setPiece:_humanPiece forIndex:boardIndex];

    // Update the model
    GamePosition position;
    position.row = boardIndex / kGEBoardDimension;
    position.column = boardIndex % kGEBoardDimension;
    [_gameEngine setPosition:position withPiece:_humanPiece];

    // Advance the controller to the next state
    _turn = _cpuPiece;
    [self nextMoveAsync];
}

// Initiate a CPU move
- (void)cpuMove {
    // Solve for the next move
    GamePosition position = {0};
    BOOL solveResult = [_gameEngine solveForPiece:_cpuPiece position:&position];
    
    if (solveResult == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"GameEngine failed to solve for next move"];
        return;
    }
    
    // Update our model
    [_gameEngine setPosition:position withPiece:_cpuPiece];
    
    // Update our view
    NSInteger index = position.row * kGEBoardDimension + position.column;
    [_gameBoardView setPiece:_cpuPiece forIndex:index];
    [_gameBoardView setUserInteraction:NO forPiece:index];
    
    // Advance the controller to the next state
    _turn = _humanPiece;
    [self nextMoveAsync];
}

@end
