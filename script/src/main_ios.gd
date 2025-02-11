extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $Version.text = Constants.VERSION_NUMBER_IOS
  $Sudoku.create_grid()


func _on_sudoku_cell_edited(_cell: Cell):
  if $Sudoku.is_complete():
    $ClearWindow.visible = true
