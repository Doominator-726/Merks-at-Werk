extends CanvasLayer

var max_scroll_size: int = 0
var news_scroll_speed: int = 200

var ticker_messages = ["Hey hey hey", "No no no", "Yes yes yes", "Hey hey hey", "No no no", "Yes yes yes", "Hey hey hey", "No no no", "Yes yes yes"]

func _ready() -> void:
	populate_ticker()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		$Message/Label.visible = !$Message/Label.visible
		
	#print(max_scroll_size)
	# Handle News Ticker
	$"News Ticker".scroll_horizontal += news_scroll_speed * delta
	print($"News Ticker".scroll_horizontal, " ", max_scroll_size)
	if $"News Ticker".scroll_horizontal >= max_scroll_size:
		$"News Ticker".scroll_horizontal = 0
		
func populate_ticker():
	var blank_space = Label.new()
	blank_space.text = "                      "
	
	$"News Ticker/HBoxContainer".add_child(blank_space)
	
	for message in ticker_messages:
		var label = Label.new()
		label.text = message
		$"News Ticker/HBoxContainer".add_child(label)
		
	$"News Ticker/HBoxContainer".add_child(blank_space.duplicate())
		
	await get_tree().process_frame
	max_scroll_size = $"News Ticker/HBoxContainer".size.x / 2
