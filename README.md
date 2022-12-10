### Task description
During pandemic times, you need to keep yourself and others safe. Your goal is to reach home, but you forgot the
mask at the library. You might be able to buy the mask on your way to the home.
Your environment is a 9*9 square lattice. 

![alt text](https://i.ibb.co/R45JtBy/grid.jpg)

#### Actor
You start from bottom left. Your goal is to reach home in as minimum number of steps as possible. Your ability to
perceive covid is defined in the “variants section” below. Your algorithms will work on both variants. The actor can
move one step per turn and can move horizontally, vertically and diagonally.
#### Covid
Covid’s perception is only in consecutive cells (Moore neighborhood), shown in figure below. There are 2 covid
agents generated randomly on the map. You do not want to face covid as it ends the game. You are safe from covid
only if you enter its perception zone after visiting the doctor or you already got the mask. 

![covid](https://i.ibb.co/7XPWHKp/image.jpg)
#### Doctor
The doctor is generated randomly on the map but cannot be in the covid zone. You do not know the location of the
doctor’s cell. You can perceive the doctor only when you are inside the doctor’s cell. Once you go inside the doctor’s
cell, you are vaccinated and covid cannot harm you even if you go inside covid infected cells.
#### Home
Home is randomly generated on the map except inside the covid infected cells. You know the location of the home.
#### Mask
Mask is generated randomly and is not in the covid zone. You do not know the location of the mask. You can
perceive mask only when you are inside the mask cell. If you get the mask, covid cannot harm you even if you go
inside covid infected cells.
#### Algorithms
A backtracking search
#### Variants
The algorithms consider two scenarios:
1) In one scenario, you can perceive covid if you are standing next to the covid infected cells
2) In the other scenario, you can perceive covid from a larger distance, which is, when you are 1 square away from
the covid infected cells
#### Input
The algorithms input is a 9*9 square lattice. The map has a single actor, 2 covid agents, a doctor, mask, and home.
The input file would be as such,
[0,0] [0,1] [0,2]….till
[8,0] [8,1] [8,2]…
#### Output
The output comprises of
1) Outcome - Win or lose
2) The number of steps algorithm took to reach home
3) The path on the map. Path can be displayed as, for example,
 [0,0] [1,1] [1,2]…
4) Time taken by the algorithm to reach home
