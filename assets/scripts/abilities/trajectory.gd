class_name Trajectory
extends Ability
# A type of abstract ability that has a trajectory, i.e. a direction and speed
# in which something travels.


# Direction of trajectory.
export(Vector2) var direction = Vector2.ZERO
# Speed of travel.
export(float) var speed = 4
