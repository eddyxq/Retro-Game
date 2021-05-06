# user starts at the left bottom of the screen
# goal is always at the right top of the screen
# generates platforms randomly with random length (6~12)
# generates coin somewhere on platforms randomly

# still working on the distance between the platforms

import random

#variables
player = "X"
coin = "$"
platform = "___"
space = "   "
goal = "G"

# screen height and width
column = 23
row = 23

#haven't used it yet
distance = 3

# function that initializes the stage
def createStage():
    table = [[space for x in range(column)] for y in range(row)]
    return table

# function that puts user and goal
def addStage(table):
    for i in range(row):
        for j in range(column):
            # setting the inital location of player
            if (i == (column-1)):
                if(j== 0):
                    table[i][j] = player
                else:
                    table[i][j] = platform
            # setting the inital location of goal
            if (i == 0 and j >= (row-3)):
                if(j == row-3):
                    table[i][j] = platform
                else:
                    table[i][j] = goal

# function that generates platforms
def randomPlatforms(table):
    # inital seed value
    seed = random.randint(0, 255)
    # T/F for making sure platform won't be too long
    p = False
    #create platforms and coins
    for i in range(row):
        for j in range(column):
            if (table[i][j] == space):
                if (seed % 13) == 0:
                    while (j < 17 and p == False):
                        # random number for how long a platform will be
                        r = random.randint(2, 4)
                        for k in range(r):
                            # random number for deciding to put coin or not
                            c = random.randint(1,20)
                            if(c % 7 == 0):
                                table[i][j] = coin
                            # putting platform (# of r)
                            else:
                                table[i][j] = platform
                            j += 1
                            # stop making the platform longer
                            p = True
                # start making a new platform
                else:
                    p = False

        # this give more random platforms & random chosen numbers
                # new seed value
                seed = (7 * seed + 17) % 777
            # new seed value
            seed = (3 * seed + 17) % 333
        # new seed value
        seed = (5 * seed + 17) % 333

def distance(table):
    print("working with distance betweeen platforms")

# main function
def main():
    # create table
    table = createStage()
    randomPlatforms(table)
    distance(table)
    addStage(table)
    # print table
    for i in table:
        for j in i:
            print(j,end = '')
        print()

main()
