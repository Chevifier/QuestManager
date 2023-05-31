extends PopupMenu


func _on_popup_hide():
	gui_release_focus()
