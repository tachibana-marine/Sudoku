class_name Progress
extends Node

const STATUS_FILLING = "Step 1/2: Filling Grid"
const STATUS_REMOVING = "Step 2/2: Removing Cells"

var progress_text = "":
  get():
    return progress_text
  set(value):
    progress_text = value
    $ProgressText.text = progress_text
