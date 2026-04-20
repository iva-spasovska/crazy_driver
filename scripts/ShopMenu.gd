extends CanvasLayer

signal shop_closed

const COLS = 4  # 4 squares per row = 2 rows for 8 colors

var _confirm_panel: Panel
var _confirm_index: int = -1
var _color_buttons: Array = []
var _coin_label: Label

func _ready():
	_build_ui()

func _build_ui():
	# Dark background overlay
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main panel
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-300, -260)
	panel.custom_minimum_size = Vector2(600, 520)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "🎨  CAR SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0))
	vbox.add_child(title)

	# Coins display
	_coin_label = Label.new()
	_coin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_coin_label.add_theme_font_size_override("font_size", 22)
	_coin_label.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(_coin_label)

	# Grid of color squares
	var grid = GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	for i in range(GameManager.CAR_COLORS.size()):
		var data = GameManager.CAR_COLORS[i]
		var btn = _create_color_button(i, data)
		grid.add_child(btn)
		_color_buttons.append(btn)

	# Continue button
	var continue_btn = Button.new()
	continue_btn.text = "▶  CONTINUE PLAYING"
	continue_btn.add_theme_font_size_override("font_size", 24)
	continue_btn.custom_minimum_size = Vector2(0, 55)
	continue_btn.pressed.connect(_on_continue)
	vbox.add_child(continue_btn)

	# Confirm popup (hidden by default)
	_build_confirm_popup()

	_refresh_buttons()

func _create_color_button(index: int, data: Dictionary) -> Control:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(120, 130)

	var color_rect = Button.new()
	color_rect.custom_minimum_size = Vector2(120, 90)
	color_rect.pressed.connect(_on_color_pressed.bind(index))

	# Style the button with the car color
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = data["color"]
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.border_width_top = 3
	normal_style.border_width_bottom = 3
	normal_style.border_width_left = 3
	normal_style.border_width_right = 3
	normal_style.border_color = Color(1, 1, 1, 0.3)
	color_rect.add_theme_stylebox_override("normal", normal_style)
	color_rect.add_theme_stylebox_override("hover", normal_style)
	color_rect.add_theme_stylebox_override("pressed", normal_style)
	container.add_child(color_rect)

	var price_label = Label.new()
	if data["price"] == 0:
		price_label.text = "FREE"
	else:
		price_label.text = "🪙 %d" % data["price"]
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", Color(1, 1, 1))
	container.add_child(price_label)

	return container

func _build_confirm_popup():
	_confirm_panel = Panel.new()
	_confirm_panel.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_panel.position = Vector2(-200, -100)
	_confirm_panel.custom_minimum_size = Vector2(400, 200)
	_confirm_panel.hide()
	add_child(_confirm_panel)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	_confirm_panel.add_child(vbox)

	var label = Label.new()
	label.name = "ConfirmLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(label)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox)

	var yes_btn = Button.new()
	yes_btn.text = "✅  YES"
	yes_btn.custom_minimum_size = Vector2(120, 45)
	yes_btn.add_theme_font_size_override("font_size", 20)
	yes_btn.pressed.connect(_on_confirm_yes)
	hbox.add_child(yes_btn)

	var no_btn = Button.new()
	no_btn.text = "❌  NO"
	no_btn.custom_minimum_size = Vector2(120, 45)
	no_btn.add_theme_font_size_override("font_size", 20)
	no_btn.pressed.connect(_on_confirm_no)
	hbox.add_child(no_btn)

func _refresh_buttons():
	_coin_label.text = "Your coins: 🪙 %d" % GameManager.coins

	for i in range(_color_buttons.size()):
		var container = _color_buttons[i]
		var btn: Button = container.get_child(0)
		var price_label: Label = container.get_child(1)
		var data = GameManager.CAR_COLORS[i]
		var owned = i in GameManager.owned_colors
		var selected = i == GameManager.selected_color

		# Get the existing stylebox and modify it
		var style = btn.get_theme_stylebox("normal").duplicate()

		if selected:
			# Bright border = currently selected
			style.border_color = Color(1, 1, 0, 1)
			style.border_width_top = 5
			style.border_width_bottom = 5
			style.border_width_left = 5
			style.border_width_right = 5
			style.bg_color = data["color"]
			price_label.text = "✔ ACTIVE"
			price_label.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
		elif owned:
			# Owned but not selected — normal bright color
			style.border_color = Color(1, 1, 1, 0.6)
			style.border_width_top = 3
			style.border_width_bottom = 3
			style.border_width_left = 3
			style.border_width_right = 3
			style.bg_color = data["color"]
			price_label.text = "SWITCH"
			price_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			# Not owned — greyed out
			style.bg_color = data["color"].lerp(Color(0.3, 0.3, 0.3), 0.65)
			style.border_color = Color(0.4, 0.4, 0.4)
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_width_left = 2
			style.border_width_right = 2
			if GameManager.coins >= data["price"]:
				price_label.text = "🪙 %d" % data["price"]
				price_label.add_theme_color_override("font_color", Color(1, 1, 1))
			else:
				price_label.text = "🪙 %d" % data["price"]
				price_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

func _on_color_pressed(index: int):
	var data = GameManager.CAR_COLORS[index]
	var owned = index in GameManager.owned_colors

	if owned:
		# Already owned — just switch to it
		GameManager.selected_color = index
		emit_signal("shop_closed")  # Tell player to update color
		_refresh_buttons()
		return

	# Not owned — check if can afford
	if GameManager.coins < data["price"]:
		return  # Can't afford, do nothing

	# Show confirm popup
	_confirm_index = index
	var label = _confirm_panel.get_node("VBox/ConfirmLabel")
	label.text = "Buy %s for 🪙 %d?" % [data["name"], data["price"]]
	_confirm_panel.show()

func _on_confirm_yes():
	if _confirm_index == -1:
		return
	var data = GameManager.CAR_COLORS[_confirm_index]
	GameManager.coins -= data["price"]
	GameManager.owned_colors.append(_confirm_index)
	GameManager.selected_color = _confirm_index
	_confirm_panel.hide()
	_confirm_index = -1
	emit_signal("shop_closed")
	_refresh_buttons()

func _on_confirm_no():
	_confirm_panel.hide()
	_confirm_index = -1

func _on_continue():
	emit_signal("shop_closed")

func open():
	_refresh_buttons()
	show()

func close():
	hide()
