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

static const CGFloat kTTTCPUThinkTime = 0.3f;

@interface ViewController ()

@property (nonatomic,assign) GameEnginePiece humanPiece;
@property (nonatomic,assign) GameEnginePiece cpuPiece;
@property (nonatomic) GameEnginePiece turn;
@property (nonatomic,retain) GameEngine *gameEngine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"viewDidLoad");
    
    _instructionsText.text = @"Welcome to\nTic-Tac-Toe!";
    _statusText.text = @"";
    
    _gameBoardView.delegate = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#if DEVELOPMENT_SKIP_CHOICE
        _humanPiece = GameEnginePiecePlayerOne;
        _cpuPiece = GameEnginePiecePlayerTwo;
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

- (IBAction)restartButtonPressed:(id)sender {
    // Display popup with cancel, Human first, CPU first choices
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Game"
                                                                   message:@"Who plays first?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *humanFirstAction = [UIAlertAction actionWithTitle:@"Human First" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 NSLog(@"Human First");
                                                                 _humanPiece = GameEnginePiecePlayerOne;
                                                                 _cpuPiece = GameEnginePiecePlayerTwo;
                                                                 _turn = _humanPiece;
                                                                 [self startGame];
                                                             }];
    UIAlertAction *cpuFirstAction = [UIAlertAction actionWithTitle:@"CPU First" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 NSLog(@"CPU First");
                                                                 _humanPiece = GameEnginePiecePlayerTwo;
                                                                 _cpuPiece = GameEnginePiecePlayerOne;
                                                                 _turn = _cpuPiece;
                                                                 [self startGame];
                                                             }];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {}];
    

    [alert addAction:humanFirstAction];
    [alert addAction:cpuFirstAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startGame {
    _gameEngine = [[GameEngine alloc] init];
    [_gameBoardView presentBoard];
    [self nextMoveAsync];
}

- (void)gameBoardView:(GameBoardView *)boardView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_turn == _humanPiece) {
        // Pieces can be pressed once
        [boardView setUserInteraction:NO forPiece:buttonIndex];
        
        [self humanMoveAtIndex:buttonIndex];
    }
    
    // ignore taps received out-of-turn
}

- (void)nextMoveAsync {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self nextMove];
    });
}

- (void)nextMove {
    // Check if game over
    if (_gameEngine.status == GameEngineStatusComplete) {
        NSLog(@"Game over");
        
        // Shut down the board
        for (NSInteger index = 0; index < kGEBoardSize; index++) {
            [_gameBoardView setUserInteraction:NO forPiece:index];
        }
        
        // Update the UI
        NSString *winner;
        if (_gameEngine.winner == _cpuPiece) {
            winner = @"CPU";
        } else if (_gameEngine.winner == _humanPiece) {
            winner = @"Human";
        } else {
            winner = @"Draw";
        }
        _statusText.text = [NSString stringWithFormat:@"Game over! Winner: %@", winner];
        return;
    }
    
    if (_turn == _humanPiece) {
        // Wait for the human
        NSLog(@"Waiting for the human ...");
        _statusText.text = @"Human's turn";
    } else if (_turn == _cpuPiece) {
        NSLog(@"CPU is moving ...");
        _statusText.text = @"CPU's turn";
        // Artificial wait
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTTTCPUThinkTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cpuMove];
        });
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected player turn %d", _turn];
        return;
    }
}

- (void)humanMoveAtIndex:(NSInteger)boardIndex {
    // Update the view
    [_gameBoardView setPiece:_humanPiece forIndex:boardIndex];

    // Update the model
    GameEnginePosition position;
    position.row = boardIndex / kGEBoardDimension;
    position.column = boardIndex % kGEBoardDimension;
    [_gameEngine setPosition:position withPiece:_humanPiece];

    // Advance the controller to the next state
    _turn = _cpuPiece;
    [self nextMoveAsync];
}

- (void)cpuMove {
    // Solve for the next move
    GameEnginePosition position = {0};
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
