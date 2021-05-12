extends Node2D

#setup controllable vars
export var num_pits = 2
export var num_boxes = 2
export var puzzle_spawn_area : Rect2 = Rect2(0, 400, 400, 400) #made this 500 x 500

var puzzle_solved = false

#REFACTOR THIS TO HAVE EXPORTS ARRAY: 1 FOR ALL BOX AND 1 FOR ALL PITS
#OR JUST MAKE NEW FUNCTIONALITY THAT HAS THE RANDOMIZED STUFF COMMENTED OUT FOR NOW

var rng = RandomNumberGenerator.new()

#preload pits & boxes
var pit_scene = preload("res://scenes/shared/props/box_and_pit/pit.tscn")
var box_scene = preload("res://scenes/shared/props/box_and_pit/box.tscn")

# Puzzle Signals
signal box_and_pit_puzzle_unsolved
signal box_and_pit_puzzle_solved #maybe add half, third, and three quarters solved signals?
signal box_and_pit_puzzle_solved_count

#setup and make instances
func _ready():
	emit_signal("box_and_pit_puzzle_unsolved")
	rng.randomize()
	
	for _i in range(num_pits):
		instance_pit()
		
	for _i in range(num_boxes):
		instance_box()
	
	
func _process(delta): #constantly check if puzzle solved
	#print("self.get_child_count()", self.get_child_count())
	var all_puzzles = get_tree().get_nodes_in_group("pits")
	#print(all_puzzles)
	var solved_count = 0
	for pit in all_puzzles:
		if pit.puzzle_completed == true:
			emit_signal("box_and_pit_puzzle_solved_count", solved_count)
			solved_count+=1
	
	#print("we have solved ", solved_count, " puzzles")
	if solved_count == num_pits: #we must complete all puzzles to pass
		$PuzzleSolved.play()
		emit_signal("box_and_pit_puzzle_solved")
		puzzle_solved = true
		#print("puzzle solved!")


	
func instance_pit(): #create a pit in the spawn area
	var pit = pit_scene.instance()
	add_child(pit)
	pit.add_to_group("pits") #recording pits to keep track of amt solved
	
	pit.position.x = puzzle_spawn_area.position.x + rng.randf_range(0, puzzle_spawn_area.size.x)
	pit.position.y = puzzle_spawn_area.position.y + rng.randf_range(0, puzzle_spawn_area.size.y)
	
func instance_box():  #create a box in the spawn area
	var box = box_scene.instance()
	add_child(box)
	
	box.position.x = puzzle_spawn_area.position.x + rng.randf_range(0, puzzle_spawn_area.size.x)
	box.position.y = puzzle_spawn_area.position.y + rng.randf_range(0, puzzle_spawn_area.size.y)
	
