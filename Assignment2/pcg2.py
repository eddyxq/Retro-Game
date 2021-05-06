# PCG Algorithm
# I decided to create another pcg algorithm with the extra time from the assignment extension.
# This pcg recursively backtracks through and carves out a path rather than randomly placing
# platforms so it ensures that all areas and platforms are reachable.

"""
Assumptions:
-GOAL: player's goal is to collect all the items denoted as '$' and then
       move to the end point denoted as 'E'
-player jump height = 4 blocks or ASCII spaces
-player jump distance = 4 blocks or ASCII spaces
-player can jump to a higher platform from a platform that is directly
below. i.e. You are able to jump through a platfrom from below.

"""

import random

# symbols
PLAYER = "X"
ITEM = "$"
CONTROL_POINT = "C"
END_POINT = "E"
PLATFORM = "[]"
EMPTY_SPACE = "  "
HORIZONTAL_BOARDER = "_"
VERTICAL_BOARDER = "|"

# constants
NUM_COL = 45
NUM_ROW = 15
NUM_DIRECTIONS = 4

# change this seed value to generate a different set of random platforms
SEED_VALUE = random.randint(0, 255)


# function that generates a random seed
def generate_seed():
    # in 6502 load from a memory address that has random unknown values
    # for now use the built in python rand() function to generate a random seed value
    random.seed(SEED_VALUE)


# function that initializes the structures of the stage
def create_stage():
    table = []
    for _ in range(NUM_ROW):
        table.append([PLATFORM for i in range(NUM_COL)])

    for i in range(NUM_COL):
        table[0][i] = EMPTY_SPACE
        table[NUM_ROW - 1][i] = EMPTY_SPACE

    for i in range(NUM_ROW):
        table[i][0] = EMPTY_SPACE
        table[i][NUM_COL - 1] = EMPTY_SPACE
    reverse_carve_platforms(2, 2, table)
    return table


# function that prints out the stage to console to simulate visuals
def print_stage(table):
    for row in table:
        for cell in row:
            if cell == PLATFORM:
                print(EMPTY_SPACE, end="")
            elif cell == EMPTY_SPACE:
                print(PLATFORM, end="")
            elif cell == PLAYER:
                print(PLAYER+" ", end="")
            elif cell == ITEM:
                print(ITEM+" ", end="")
            elif cell == END_POINT:
                print(END_POINT+" ", end="")
        print()


# this function recursively carves away platforms and paves a path such that
# all the platforms are within reach
def reverse_carve_platforms(x, y, table):
    upx = [1, -1, 0, 0]
    upy = [0, 0, 1, -1]
    direction = random.randint(0, NUM_DIRECTIONS - 1)
    counter = 0
    while counter < NUM_DIRECTIONS:
        x1 = x + upx[direction]
        y1 = y + upy[direction]
        x2 = x1 + upx[direction]
        y2 = y1 + upy[direction]
        if table[y1][x1] == PLATFORM and table[y2][x2] == PLATFORM:
            table[y1][x1] = EMPTY_SPACE
            table[y2][x2] = EMPTY_SPACE
            reverse_carve_platforms(x2, y2, table)
        else:
            direction = (direction + 1) % NUM_DIRECTIONS
            counter += 1


# this function improves the overall quality of the pcg by carving away single unit platforms
def direct_carve_platforms(table):
    for i in range(1, NUM_ROW - 1):
        for j in range(1, NUM_COL - 1):
            if table[i][j] == EMPTY_SPACE and table[i][j-1] == PLATFORM and table[i][j+1] == PLATFORM:
                table[i][j] = PLATFORM


# function that draws the player denoted by 'X' character
def draw_player(table):
    table[NUM_ROW - 2][2] = PLAYER


# function that draws the endpoint denoted by 'E' character
def draw_end_point(table):
    table[NUM_ROW - 2][NUM_COL - 3] = END_POINT


# function that finds random platforms and adds a item to it denoted by '$'
def generate_random_items(table):
    for i in range(1, NUM_ROW - 1):
        for j in range(1, NUM_COL - 2):
            if table[i-1][j] == EMPTY_SPACE and random.randint(0, 50) == 0:
                table[i][j] = ITEM


# code starts here
def main():
    generate_seed()
    table = create_stage()
    direct_carve_platforms(table)
    generate_random_items(table)
    draw_end_point(table)
    draw_player(table)
    print_stage(table)


main()
