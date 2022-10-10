extends Node2D

@export var chargeTime : float = 3.0
@export var maxWidth : int = 250 # In pixels
@export var damage : int = 1
@export var firesOnce : bool = true
@export var duration : float = 0.0

# References
@onready var delayTimer = $DelayTimer
@onready var shrinkTimer = $ShrinkTimer

var doesDestroy : bool = false
var hasFired : bool = false

# Delete instead

func Fire():
	$Beam.width = $Marker.width
	$Marker.width = 10
	
func _process(delta):
	$Marker.width = lerp($Marker.width, 251.0, 0.05)
	$Marker.width = clamp($Marker.width, 0, 250)
	if($Marker.width >= 250):
		if(!hasFired):
			$Beam.width += 75
			$Beam.width = clamp($Beam.width, 0, 276)
			if($Beam.width >= 275):
				delayTimer.start()
				shrinkTimer.start()
				$Marker.width = 0
				set_process(false)

func _on_timer_timeout():
	print('STOP')
	$Beam.width = 0
	if(firesOnce):
		queue_free()
	#set_process(false)
	delayTimer.start()

func _on_collider_area_entered(area):
	if(area.get_parent().name == "Player"):
		area.get_parent().health -= damage
		print('HIT')

func _on_delay_timer_timeout():
	$Beam.width = 0
	shrinkTimer.stop()
	if(doesDestroy): # Pointless?
		queue_free()
	set_process(true)

func _on_shrink_timer_timeout():
	$Beam.width = lerp($Beam.width, 0.0, 0.1)
