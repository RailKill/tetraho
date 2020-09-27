extends CanvasLayer
# This CanvasLayer shows the player their menus and statuses.


onready var hud = $PlayerHUD setget ,get_hud
onready var menu = $IngameMenu setget ,get_menu


# Returns the PlayerHUD node.
func get_hud():
	return hud


# Returns the IngameMenu node.
func get_menu():
	return menu
