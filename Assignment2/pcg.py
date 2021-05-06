# PCG Algorithm
# This version adds items randomly onto platforms
# and also generate a end point for the player to reach.

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
PLATFORM = "_"
EMPTY_SPACE = " "
HORIZONTAL_BOARDER = "_"
VERTICAL_BOARDER = "|"

# constants
NUM_COL = 120
NUM_ROW = 15
MAX_JMP_DISTANCE = 3
TOTAL_CONTROL_POINTS = 156
MAX_NUM_PLATFORMS_TO_CREATE = 90

# change this seed value to generate a different set of random platforms
SEED_VALUE = random.randint(0, 255)


# function that generates a random seed
def generate_seed():
    # in 6502 load from a memory address that has random unknown values
    # for now use the built in python rand() function to generate a random seed value
    random.seed(SEED_VALUE)


# function that initializes the structures of the stage
def create_stage():
    table = [[EMPTY_SPACE for x in range(NUM_COL)] for y in range(NUM_ROW)]
    return table


# function that prints out the stage to console to simulate visuals
def print_stage(table):
    for i in range(NUM_ROW - 1):
        for j in range(NUM_COL - 1):
            if table[i][j] == CONTROL_POINT:
                print(" ", end="")
            else:
                print(table[i][j], end="")
        print()


# function that marks control points on the screen
def create_control_points(table):
    counter = 0
    rnd = 0
    for i in range(2, NUM_ROW - MAX_JMP_DISTANCE, MAX_JMP_DISTANCE):
        for j in range(1, NUM_COL - MAX_JMP_DISTANCE, MAX_JMP_DISTANCE):
            if counter % 2 == 0:
                table[i][j] = CONTROL_POINT
                counter += 1
            else:
                table[i][rnd] = CONTROL_POINT
                counter += 1
                rnd += 1



# function that generates platforms by connecting random horizontal control points
def generate_random_platforms(table):
    control_point_counter = 1
    selected_control_points = randomly_select_control_points()
    progress = False
    # go through the table
    for i in range(NUM_ROW - 1):
        for j in range(NUM_COL - 1):
            # count the number of control points
            if table[i][j] == CONTROL_POINT:
                control_point_counter += 1
            # if control point is not one of selected ones, stop extending platform
            if progress and table[i][j] == CONTROL_POINT:
                table[i][j] = PLATFORM
                progress = False
            # extends platform until it reaches next control point
            elif progress:
                table[i][j] = PLATFORM
            # if control point is one of the selected ones, extend platform until next control point
            elif not progress and table[i][j] == CONTROL_POINT and control_point_counter in selected_control_points:
                table[i][j] = PLATFORM
                progress = True
        # stop extending platform at the end of each row
        progress = False


# function that randomly selects a control point
def randomly_select_control_points():
    # choose a rand int
    select = [random.randint(0, 255) % TOTAL_CONTROL_POINTS for x in range(MAX_NUM_PLATFORMS_TO_CREATE)]
    return select


# function that draws a boarder to improve console viewing experience
def draw_boarder(table):
    for i in range(1, NUM_COL - 2):
        # left boarder
        table[0][i] = HORIZONTAL_BOARDER
        # right boarder
        table[NUM_ROW - 2][i] = HORIZONTAL_BOARDER

    for i in range(1, NUM_ROW - 1):
        # left boarder
        table[i][0] = VERTICAL_BOARDER
        # right boarder
        table[i][NUM_COL - 2] = VERTICAL_BOARDER


# function that draws the player denoted by 'X' character
def draw_player(table):
    table[NUM_ROW - 2][2] = PLAYER


# function that finds random platforms and adds a item to it denoted by '$'
def generate_random_items(table):
    for i in range(NUM_ROW - 1):
        for j in range(NUM_COL - 1):
            if table[i][j] == PLATFORM and random.randint(0, 30) == 0:
                table[i][j] = ITEM


# function that marks the end point on the top right most platform denoted by 'E'
def generate_random_end_point(table):
    for i in range(2, NUM_ROW - 1):
        for j in range(NUM_COL - 3, 2, -1):
            if table[i][j] == PLATFORM:
                table[i][j] = END_POINT
                break
        break


# code starts here
def main():
    generate_seed()
    table = create_stage()
    create_control_points(table)
    generate_random_platforms(table)
    generate_random_items(table)
    generate_random_end_point(table)
    draw_boarder(table)
    draw_player(table)
    print_stage(table)


main()
