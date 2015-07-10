# tictactoe
Mobile Tic-Tac-Toe game

## Contents
* GameEngine to control the game located in [tictactoe/](tictactoe). Has heuristics for solving the game via `-[solveForPiece:position:]`.
* GameEngineBoard to manage the Tic-Tac-Toe model located in [tictactoe/](tictactoe). Has helpers to compute details on the ways to win, called "board vector attributes".
* Unit tests for most of the board and engine in [tictactoeTests/tictactoeTests.m](tictactoeTests/tictactoeTests.m)
