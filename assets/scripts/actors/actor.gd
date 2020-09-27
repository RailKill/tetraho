class_name Actor
extends KinematicBody2D
# An actor that can perform actions in the game.


# Emitted when the actor takes damage.
signal damage_taken(attacker, verb, victim, amount)
# Emitted when the actor is dying.
signal dying

export var hp = Constants.PLAYER_HP setget ,get_hp
export var max_hp = Constants.PLAYER_HP setget ,get_maximum_hp
export(float, 0, 1000) var move_speed = Constants.PLAYER_MOVE_SPEED
export var is_invulnerable = false
export(Constants.Team) var team = Constants.Team.MOBS

var checker_resource = load("res://assets/scenes/areas/area_checker.tscn")
var speech_queue = []

onready var collision_shape = $CollisionShape2D
onready var sound_hit = $SoundHit
onready var sound_death = $SoundDeath
onready var sprite = get_node_or_null("AnimatedSprite") setget ,get_sprite


func _to_string():
	return name


# Add given node as a child of this Actor if the string representation of the
# give node does not already exist. If this operation is unsuccessful, the node
# will not have a parent so it MUST be freed to prevent a leak.
func add_child_unique(node: Node2D):
	if not get_node_or_null(str(node)):
		add_child(node)
	else:
		node.queue_free()


# Adds a speech bubble to the queue for this actor to speak.
func add_speech(bubble: SpeechBubble):
	speech_queue.append(bubble)
	call_deferred("add_child", bubble)
	# warning-ignore:return_value_discarded
	bubble.connect("tree_exited", self, "next_speech")
	if speech_queue.size() == 1:
		# warning-ignore:return_value_discarded
		bubble.connect("ready", bubble, "start")


# Checks a given collision and react accordingly. By default, nothing happens.
func check_collision(_collision: KinematicCollision2D):
	pass


# Checks if actor is dead.
func is_dead():
	return hp <= 0


func get_hp():
	return hp


func get_hud():
	return null


func get_maximum_hp():
	return max_hp


func get_sprite():
	return sprite


# Heals the actor by the given amount.
func heal(amount):
	hp = clamp(hp + amount, 0, max_hp)


# Checks if actor is being locked.
func is_locked():
	return GameWorld.is_actor_locked(self)


# Moves the actor to the given linear velocity over delta time. Handles push.
# Returns a list of collider bodies resulting from this Actor's move_and_slide.
func move(velocity: Vector2, delta: float) -> Array:
	# warning-ignore:return_value_discarded
	move_and_slide(velocity)
	
	var colliders = []
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		colliders.append(collision.collider)
		check_collision(collision)
		
		# Keep track of all colliding bodies that were pushed in this move.
		# This is to prevent circular pushes that will result in infinite loop.
		var pushed = []
		# Loop and push all colldiing actors to prevent getting stuck.
		while collision != null and not pushed.has(collision.collider):
			var body = collision.collider
			if body.is_in_group("pushable") and not body.is_locked():
				# push can be null here, so it can break the loop if
				# there are no more pushable bodies to push.
				var push = body.move_and_collide(velocity * delta)
				body.check_collision(push)
				pushed.append(body)
				collision = push
			else:
				# If the colliding body is not pushable, break the loop.
				collision = null
	return colliders


# Process the next speech bubble down the speech_queue.
func next_speech():
	speech_queue.pop_front()
	if not speech_queue.empty():
		speech_queue[0].start()


# Damage the actor.
func oof(damage, bypass_lock=false, attacker=null, message=""):
	if not is_invulnerable and (bypass_lock or not is_locked()):
		hp -= damage
		print("%s took %d damage." % [name, damage])
		emit_signal("damage_taken", attacker, message, self, damage)
		
		if is_dead():
			play_death_animation()
			visible = false
			collision_shape.call_deferred("set_disabled", true)
			emit_signal("dying")
		else:
			sound_hit.play()


# Animate the actor channeling the given ability.
func play_casting_animation(_ability):
	pass


# Animate the actor to finish casting based on the given ability.
func play_casted_animation(_ability):
	pass


# Animate the actor dying.
func play_death_animation():
	if not sound_death.is_playing():
		sound_death.play()
		yield(sound_death, "finished")
		queue_free()


# Animate the actor failing to cast the given ability.
func play_fail_animation(_ability):
	pass


# Unstuck this actor by checking for an empty space in adjacent grid cells.
# Parameter "cause" is the node that triggered this unstuck.
func unstuck(cause=null):
	var deadend = Deadend.new()
	deadend.caster = cause
	add_child_unique(deadend)
