class_name PlayerHUD
extends Control
# Heads up display to show a player's status.


# Health node.
onready var status = $Status/Offset
onready var health = $Status/Offset/Health
onready var hearts = health.get_children()

# Mana nodes.
onready var mana_flask = $Status/Offset/Mana/Flask
onready var dash_ready = $Status/Offset/Mana/DashReady
onready var recharging = $Status/Offset/Mana/Recharging

# Face nodes.
onready var face = $Status/Offset/Head/Face
onready var hat = $Status/Offset/Head/Hat
onready var crown = $Status/Offset/Head/Crown

# Tetromino nodes.
onready var hold = $Status/Offset/Hold
onready var next = $Status/Offset/Next


# Helper function to center the tetromino's position in the HUD.
func center_tetromino(tetromino : Tetromino):
	tetromino.set_position(Vector2.ZERO - tetromino.origin.get_position())


# Updates the HUD based on the given player's HP.
func update_hp(player):
	var hp = player.get_hp()
	var max_hp = player.get_maximum_hp()
	
	var portion = max_hp / hearts.size() # 100 / 5 = 20
	var filled = 0
	var count = 0
	
	# Spread HP out over heart count.
	while count < hearts.size():
		var difference = hp - filled
		if difference >= portion:
			hearts[count].set_frame(0)
			filled += portion
		elif difference > 0:
			hearts[count].set_frame(1)
			filled += difference
		else:
			hearts[count].set_frame(2)
		count += 1
	
	# If player is dead, show skeleton head.
	if player.is_dead():
		face.set_frame(1)
		face.move_local_y(-5)
		hat.set_visible(false)
		crown.set_visible(false)


# Updates the HUD of the given player's dash cooldown.
func update_dash(dash : Dash):
	var not_ready = dash.is_on_cooldown
	mana_flask.set_frame(int(not_ready))
	dash_ready.set_visible(!not_ready)
	recharging.set_visible(not_ready)


func update_tetromino(player):
	var hetromino = player.hold
	if hetromino:
		player.current.toggle_blocks(false)
		hold.remove_child(player.current)
		player.get_parent().add_child(player.current)
		player.current.snap_to_mouse()
		
		hetromino.get_parent().remove_child(hetromino)
		hold.add_child(hetromino)
		center_tetromino(hetromino)
		hetromino.toggle_blocks(true)
	
	# Destroy the old next tetromino to refresh the next UI.
	for extra in range(2, next.get_child_count()):
		next.get_child(extra).queue_free()
	
	var netromino = player.queue.peek().duplicate()
	next.add_child(netromino)
	center_tetromino(netromino)
	netromino.toggle_blocks(true)
	
	
