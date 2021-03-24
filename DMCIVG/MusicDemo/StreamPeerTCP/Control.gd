extends Control
var socket

# Pure Data variables
var bpm = 80
var triggerProbability = 1 # probability that beat occurs (rhythm prob); 0 - 1
var loopLength = 16 # number of beats per measure
var noteProbability = 1 # probability that notes in the scale are played; 0 - 1
var scaleSelection = 1 # 0 - 4
var transposition = 0
######

var format_message = "%s %s %s %s %s %s;"

func sendMessage():
	var message = format_message % [bpm, triggerProbability, loopLength, noteProbability, scaleSelection, transposition]
	socket.put_data(message.to_ascii())
	print(message)

func _ready():
	socket = StreamPeerTCP.new()
	print("connecting...")
	socket.connect_to_host("127.0.0.1", 4242)
	sendMessage()

func _on_BPM_value_changed(value):
	bpm = value
	sendMessage()

func _on_Scale0_button_down():
	scaleSelection = 0
	sendMessage()

func _on_Scale1_button_down():
	scaleSelection = 1
	sendMessage()

func _on_Scale2_button_down():
	scaleSelection = 2
	sendMessage()

func _on_Scale3_button_down():
	scaleSelection = 3
	sendMessage()

func _on_Scale4_button_down():
	scaleSelection = 4
	sendMessage()


func _on_LoopLength_value_changed(value):
	loopLength = value
	sendMessage()


func _on_transpose_value_changed(value):
	transposition = value
	sendMessage()


func _on_rhythmProb_value_changed(value):
	triggerProbability = value
	sendMessage()


func _on_noteProb_value_changed(value):
	noteProbability = value
	sendMessage()
