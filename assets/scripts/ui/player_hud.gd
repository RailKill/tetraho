class_name PlayerHUD
extends Control
# Heads up display to show a player's status.


# Speech bubble instance.
var bubble: SpeechBubble

# Health node.
onready var status = $Status/Offset
onready var health = $Status/Offset/Health
onready var hearts = health.get_children()

# Mana nodes.
onready var mana_flask = $Status/Offset/Mana/Flask
onready var dash_ready = $Status/Offset/Mana/DashReady
onready var recharging = $Status/Offset/Mana/Recharging
onready var sound_ready = $SoundReady

# Face nodes.
onready var head = $Status/Offset/Head
onready var face = $Status/Offset/Head/Face
onready var hat = $Status/Offset/Head/Hat
onready var crown = $Status/Offset/Head/Crown

# Tetromino nodes.
onready var hold = $Status/Offset/Hold
onready var next = $Status/Offset/Next

# Speech resource.
onready var talk = preload("res://assets/scenes/ui/speech_bubble.tscn")


# Make the HUD say something with the speech bubble at a given canvas position.
func say(speech : PoolStringArray, 
	position=head.get_global_position() + Vector2(0, -120)):
#		if not is_instance_valid(bubble):
			bubble = talk.instance()
			bubble.speech += speech
			head.add_child(bubble)
			bubble.global_position = position
#		else:
#			bubble.speech += speech


# Updates the HUD based on the given player's HP.
func update_hp(player):
	var portion = player.max_hp / hearts.size() # 100 / 5 = 20
	var filled = 0
	var count = 0
	
	# Spread HP out over heart count.
	while count < hearts.size():
		var difference = player.hp - filled
		if difference >= portion:
			hearts[count].frame = 0
			filled += portion
		elif difference > 0:
			hearts[count].frame = 1
			filled += difference
		else:
			hearts[count].frame = 2
		count += 1
	
	# If player is dead, show skeleton head.
	if player.is_dead():
		face.frame = 1
		face.position.y = -5
		hat.visible = false
		crown.visible = false


# Updates the HUD of the given player's ability cooldown.
func update_ability(ability: Ability):
	var not_ready = ability.is_on_cooldown
	mana_flask.frame = int(not_ready)
	dash_ready.visible = !not_ready
	recharging.visible = not_ready


func update_tetromino(player):
	var hetromino = player.hold
	if hetromino:
		if hold.get_child_count() > 2:
			var holding = hold.get_child(2)
			if holding == player.current:
				player.current.toggle_blocks(false)
				hold.remove_child(player.current)
				player.get_parent().add_child(player.current)
				player.current.snap_to_mouse()
		
		hetromino.get_parent().remove_child(hetromino)
		hold.add_child(hetromino)
		hetromino.position = Vector2.ZERO
		hetromino.toggle_blocks(true)
	
	# Destroy the old next tetromino to refresh the next UI.
	for extra in range(2, next.get_child_count()):
		next.get_child(extra).queue_free()
	
	var netromino = player.queue.peek().duplicate()
	next.add_child(netromino)
	netromino.position = Vector2.ZERO
	netromino.toggle_blocks(true)
	
	
