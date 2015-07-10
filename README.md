# tictactoe
Mobile Tic-Tac-Toe game

## Contents

* (_Best place to start!_) Unit tests illustrating the board and engine operation are located in [tictactoeTests/tictactoeTests.m](tictactoeTests/tictactoeTests.m)
* GameEngine to control the game is located in [tictactoe/](tictactoe). Has heuristics for solving the game via `-[solveForPiece:position:]`.
* GameEngineBoard to manage the Tic-Tac-Toe model is located in [tictactoe/](tictactoe). Has helpers to compute details for contemplating the ways to win, called "board vector attributes".
