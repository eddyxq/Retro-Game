# A very simple and poorly designed pcg algorithm that generates x and y coordinates for platforms
# by modding the seed with primes. ( mod 7 ) for x and ( mod 13 ) for y


import random

seed = random.randint(10, 255)
# seed = 241
platform_coords = []
max_x = 23
max_y = 24


print("seed: " + str(seed))

"""
generates 5 sets of x and y coordinates for platforms by modding seed with 7 for x and 13 for y
Adding seed to the remainder and modding again by 23 is to reduce the chance of generating the same x value multiple times
Modded by 23 for x and 24 for y to get values that go up to 22 for X and up to 23 for y since vic20 screen size is 22 * 23

"""
def generate_platform_coords(seed):
    x_coords = [0, 0, 0, 0, 0]
    y_coords = [0, 0, 0, 0, 0]

    for i in range(len(x_coords)):
        print("New Seed: ", seed)
        x_coords[i] = (seed % 7 + seed) % 23
        y_coords[i] = (seed % 13 + seed) % 24

        platform_coords.append( (x_coords[i],y_coords[i]) )


        seed = (3*seed + 41) % 128


    # for i in range(len(x_coords)):
    #     print("(", x_coords[i], " ,", y_coords[i], " )")


def draw_platforms():
    result = ""
    for y in range(max_y):
        x = 0
        while (x < max_x):
            if (x,y) in platform_coords:
                if (x+4) > max_x:
                    result += "T" * (max_x - x)
                    x += (max_x - x)
                    continue
                else:
                    result += "TTTT"
                    x += 4
                    continue
            else:
                result += "."

            x += 1
    
        result += "\n" #+ str(y+1)

    
    print(result)

    
def main():
    generate_platform_coords(seed)
    draw_platforms()




main()