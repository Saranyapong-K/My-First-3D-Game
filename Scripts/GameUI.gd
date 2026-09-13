extends Control

@onready var coinsLabel = $CoinsLabel

func _process(_delta):
	coinsLabel.text = "%d/%d" % [GameManager.score, GameManager.COINS_TO_WIN]
