import random
# Jacob's PCG Algorithm
#
# Backtracking attempt where the goal was to create 
# structure in the scene before placing any platforms
#
# - Places goals scattered across screen
# - Player is placed at goal 0
# - Platforms generated to create paths between goals
# - Enemies generated on paths (if path is at even x and y)

# ASSUMPTIONS:
#	The player starts at the token marked as "P"
#	- Player can jump 4 block high
#	- Player can jump 6 blocks far
#	- Touching an enemy kills the player
#

TOKEN_AIR = " "
TOKEN_PLAYER = "P"
TOKEN_PLATFORM = "@"
TOKEN_ENEMY = "e"
TOKEN_BORDER = "#"


# To be used with algorithm
# to generate scenes
class SceneCreator:
	def __init__(self):
		self.goal_amount = 4


		self.seed = 0

		self.width = 100
		self.height = 25


		# How far until another platform is created
		self.max_platform_distance = 8

		# Should only be odd
		self.platform_width = 3

		# Ensures platform width is odd
		# so that objects can be centered
		# (it is more visually pleasing,
		# but has no effect on the algorithm)
		if (self.platform_width % 2 == 0):
			self.platform_width += 1

		# Offset to find center
		self.platform_center = (self.platform_width // 2)

	def initialize(self):
		self.player = (0,0)
		self.platforms = []
		self.goals = []
		self.enemies = []

	def updateSeed(self):
		# Linear Congruential Generator
		self.seed = (5 * self.seed + 17) % 256

	# PCG Algorithm
	# Randomness comes from goal placement
	# The rest of the algorithm is procedural
	# bottom_margin argument used with Human-Design Content
	def createScene(self, seed, bottom_margin = 0):
		self.seed = seed
		self.initialize()

		# - Place goals randomly across scene (Not within margin on outside)
		# - Place platform below goal
		goal_margin = 2
		for i in range(self.goal_amount):
			# Get a random x value within margins
			self.updateSeed()
			x = goal_margin + (self.seed % (self.width - goal_margin * 2))
			
			# Get a random y value within margins
			self.updateSeed()
			y = goal_margin + (self.seed % (self.height - goal_margin * 2 - bottom_margin))

			self.goals.append((x,y))

			# Place platform centered below goal
			self.platforms.append((x - self.platform_center, y+1, self.platform_width))

		# Create paths between goals using 
		# the slope of a line
		for i in range(0, self.goal_amount - 1):
			origin = self.goals[i]		# Current location
			goal = self.goals[i + 1]	# Goal location

			dist_x = goal[0] - origin[0] # x distance to goal
			dist_y = goal[1] - origin[1] # y distance to goal
			dist = (dist_x ** 2 + dist_y ** 2) ** 0.5 # Linear distance to goal
			
			# Roughly one platform per this distance
			platforms_for_path = int(dist // self.max_platform_distance) + 2
			
			# Leave as float to force round toward zero later
			# (weird thing with python integer division that 
			# was rounding away from zero with negatives)
			run = dist_x / platforms_for_path
			rise = dist_y / platforms_for_path

			# Iterate rise and run placing platforms each step
			for s in range(1, platforms_for_path):
				# Calculate new x and y for platform
				px = origin[0] + int(run * s)
				py = (origin[1] + int(rise * s))

				# Place platform
				self.platforms.append((px, py, self.platform_width))

				# Source of randomness for enemy spawns
				if (px % 2 == 0 and py % 2 == 0):
					# Place enemy on platform center
					self.enemies.append((px + self.platform_center, py - 1))

	# Not to be implemented on Vic20
	# Displays scene as text representation
	def getAsText(self):
		# Setup 2D Array (width x height)
		inner = [TOKEN_AIR] * self.width
		result = [list(inner) for i in range(self.height)]

		# Place n x 1 platforms in array
		for p in self.platforms:
			x = p[0]		# leftmost x of platform
			y = p[1]		# topmost y of platform
			p_width = p[2]	# platform width

			top = min(x + p_width, self.width)
			for i in range(x, top):
				pass
				result[y][i] = TOKEN_PLATFORM

		# Place 1x1 enemies in array
		for e in self.enemies:
			x = e[0]
			y = e[1]

			result[y][x] = TOKEN_ENEMY

		# Place 1x1 goal markers + player in array
		for g in self.goals:
			x = g[0]
			y = g[1]

			num = str(self.goals.index(g))
			
			# Place player
			if (num == "0"):
				num = TOKEN_PLAYER

			result[y][x] = num

		# Convert array to string
		output = TOKEN_BORDER * (self.width + 2) + "\n"
		for row in result:
			output += TOKEN_BORDER
			for col in row:
				output += col

			output += TOKEN_BORDER
			output += "\n"
		output += TOKEN_BORDER * (self.width + 2) + "\n"

		# Return string representation of scene
		return output

	# Custom Level hard coded in (instead of reading from a file)
	# This function alone adds platforms that spell out hello world
	# Code generated from different file
	def customLevel(self):
		self.platforms.append( (1, 19, 1) )
		self.platforms.append( (3, 19, 1) )
		self.platforms.append( (1, 20, 1) )
		self.platforms.append( (3, 20, 1) )
		self.platforms.append( (1, 21, 3) )
		self.platforms.append( (1, 22, 1) )
		self.platforms.append( (3, 22, 1) )
		self.platforms.append( (1, 23, 1) )
		self.platforms.append( (3, 23, 1) )
		self.platforms.append( (5, 19, 3) )
		self.platforms.append( (5, 20, 1) )
		self.platforms.append( (5, 21, 2) )
		self.platforms.append( (5, 22, 1) )
		self.platforms.append( (5, 23, 3) )
		self.platforms.append( (9, 19, 1) )
		self.platforms.append( (9, 20, 1) )
		self.platforms.append( (9, 21, 1) )
		self.platforms.append( (9, 22, 1) )
		self.platforms.append( (9, 23, 3) )
		self.platforms.append( (13, 19, 1) )
		self.platforms.append( (13, 20, 1) )
		self.platforms.append( (13, 21, 1) )
		self.platforms.append( (13, 22, 1) )
		self.platforms.append( (13, 23, 3) )
		self.platforms.append( (17, 19, 3) )
		self.platforms.append( (17, 20, 1) )
		self.platforms.append( (17, 21, 1) )
		self.platforms.append( (17, 22, 1) )
		self.platforms.append( (17, 23, 3) )
		self.platforms.append( (19, 20, 1) )
		self.platforms.append( (19, 21, 1) )
		self.platforms.append( (19, 22, 1) )
		self.platforms.append( (26, 22, 1) )
		self.platforms.append( (25, 19, 1) )
		self.platforms.append( (25, 20, 1) )
		self.platforms.append( (25, 21, 1) )
		self.platforms.append( (25, 22, 1) )
		self.platforms.append( (25, 23, 1) )
		self.platforms.append( (27, 19, 1) )
		self.platforms.append( (27, 20, 1) )
		self.platforms.append( (27, 21, 1) )
		self.platforms.append( (27, 22, 1) )
		self.platforms.append( (27, 23, 1) )
		self.platforms.append( (29, 19, 3) )
		self.platforms.append( (29, 20, 1) )
		self.platforms.append( (29, 21, 1) )
		self.platforms.append( (29, 22, 1) )
		self.platforms.append( (29, 23, 3) )
		self.platforms.append( (31, 20, 1) )
		self.platforms.append( (31, 21, 1) )
		self.platforms.append( (31, 22, 1) )
		self.platforms.append( (33, 19, 2) )
		self.platforms.append( (33, 20, 1) )
		self.platforms.append( (35, 20, 1) )
		self.platforms.append( (33, 21, 2) )
		self.platforms.append( (33, 22, 1) )
		self.platforms.append( (33, 23, 1) )
		self.platforms.append( (35, 22, 1) )
		self.platforms.append( (35, 23, 1) )
		self.platforms.append( (37, 19, 1) )
		self.platforms.append( (37, 20, 1) )
		self.platforms.append( (37, 21, 1) )
		self.platforms.append( (37, 22, 1) )
		self.platforms.append( (37, 23, 3) )
		self.platforms.append( (41, 19, 2) )
		self.platforms.append( (41, 20, 1) )
		self.platforms.append( (41, 21, 1) )
		self.platforms.append( (41, 22, 1) )
		self.platforms.append( (41, 23, 2) )
		self.platforms.append( (43, 20, 1) )
		self.platforms.append( (43, 21, 1) )
		self.platforms.append( (43, 22, 1) )

	# Generates a regular scene with some differences
	# -	the bottom margin is increased by 6
	# - the bottom of the screen holds human designed platforms
	#
	# Note that levels using this function look different
	# because the margin is much higher than the other function
	def humanDesigned(self):
		seed = random.randint(0, 255)
		self.createScene(seed, 6)
		self.customLevel()
		print("Seed = " + str(seed))
		result = self.getAsText()
		print(result)
		input("...")

	def runOnSeed(self, seed):
		print("Seed = " + str(seed))
		self.createScene(seed)
		result = self.getAsText()
		print(result)
		input("...")


if __name__ == "__main__":
	my_scene = SceneCreator()

	user_input = 0
	while (user_input != 5):
		# Print menu
		print("Select which option to use:")
		print("(1) PCG, Random Seed")
		print("(2) PCG, Set Seed")
		print("(3) Human-Designed Level")
		print("(4) Information")
		print("(5) Exit")

		user_input = input("> ")
	
		try:
			user_input = int(user_input)
		except:
			user_input = 0
			print("Please enter an integer")
			print()
			continue

		if (user_input <= 0 or user_input > 5):
			print("Please enter an integer greater than 0 and less than 5")
			print()
			continue

		if (user_input == 1):
			# Max seed value that can be in a 6502 Register
			seed = random.randint(0, 255)
			my_scene.runOnSeed(seed)
		elif (user_input == 2):
			seed = -1
			while (seed < 0 or seed > 255):
				seed = input("Choose seed value [0,255]: ")
				try:
					seed = int(seed)
				except:
					seed = -1
					print("Please enter a valid seed")
					continue

			my_scene.runOnSeed(seed)

		elif (user_input == 3):
			my_scene.humanDesigned()

		elif (user_input == 4):
			print("Token Legend:")
			print("\t'%s' - Air" % TOKEN_AIR)
			print("\t'%s' - Screen Border" % TOKEN_BORDER)
			print("\t'%s' - Player Starting Location" % TOKEN_PLAYER)
			print("\t'%s' - Enemy" % TOKEN_ENEMY)
			print("\t'%s' - Platform" % TOKEN_PLATFORM)
			print()
			print("Assumptions:")
			print("\t- The player can jump 6 blocks horizontally and 4 blocks vertically")
			print("\t- Touching an enemy will kill the player")
			print("\t- The player can kill enemies with a horizontal attack")
			print("\t- The player has to reach each goal in order")
			print()
			print("\tPlatforms are only collidable when moving down")
			print("\t\tie: the player can jump through the bottom of a platform")
			print("\t\t    or walk through a platform on the same height")
			input("...")