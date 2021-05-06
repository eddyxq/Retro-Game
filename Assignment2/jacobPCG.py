import random
# Jacob's PCG Algorithm Test

# To be used with algorithm
# to generate scenes
class SceneCreator:
	def __init__(self):
		self.player = (0,0)
		self.platforms = []

		self.platform_count = 5

		self.seed = 0


		self.width = 22
		self.height = 23

	def newSeed(self):
		self.seed = (3 * self.seed + 17) % 256
		self.seed -= 128

	def createScene(self, seed):
		self.seed = seed
		self.platforms = []

		x_conversion = (256 // self.width)
		y_conversion = (256 // self.height)
		x_offset = 2 * x_conversion
		y_offset = 2 * y_conversion

		# Centerish Origin
		x = 128
		y = 128
		for i in range(self.platform_count):
			self.newSeed()
			x_off = x_offset + (self.seed % x_offset)

			self.newSeed()
			y_off = y_offset + (self.seed % y_offset)

			x += x_off
			y += y_off

			# Implicit in registers
			x %= 256
			y %= 256

			# Division for ascii representation (since screen is only 21x22)
			px = int(x / 12)
			py = int(y / 12)
			self.platforms.append( (px, py) )

		# Position player centered above first platform
		px = self.platforms[0][0] + 1
		py = self.platforms[0][1] - 1
		self.player = (px, py)


	# Not to be implemented on the Vic20
	# 
	def getAsText(self):

		result = ""
		for y in range(self.height):
			x = 0
			while (x < self.width):
				coord = (x, y)

				if (coord == self.player):
					result += "X"
				elif (coord in self.platforms):
					# Add 3 platform blocks at coord
					# If 3 platforms were to exceed width
					# reduce platform amount
					
					next_x = x + 3 # The new x value if 3 platforms were added
					overflow = (next_x % self.width) % next_x # How far the x value goes over the width
					result += "@" * (3 - overflow) # Add platforms from coord to width
					x += 3 # Skip next 3 x coords (since platforms are in those spaces)
					continue
				else:
					result += "."

				x += 1
			result += "\n"

		return result
			




if __name__ == "__main__":
	my_scene = SceneCreator()

	found_seeds = [225, 217]

	seed = random.randint(0, 255)
	print("Seed = " + str(seed))
	my_scene.createScene(seed)
	result = my_scene.getAsText()
	print(result)