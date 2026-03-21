Input.Register("ToggleWeapon", "Q")
Input.Bind("ToggleWeapon", InputEvent.Pressed, function()
	Events.CallRemote("ToggleWeapon")
end)

Input.Register("EquipWeapon1", "One")
Input.Bind("EquipWeapon1", InputEvent.Pressed, function()
	Events.CallRemote("EquipWeapon", "MelonGun")
end)

Input.Register("EquipWeapon2", "Two")
Input.Bind("EquipWeapon2", InputEvent.Pressed, function()
	Events.CallRemote("EquipWeapon", "Bonker")
end)

Input.Register("ChangeSkin", "J")
Input.Bind("ChangeSkin", InputEvent.Pressed, function()
	Events.CallRemote("ChangeSkin")
	Play2dSound("click.mp3", 4, 1)
end)

Input.Register("ChangeHat", "K")
Input.Bind("ChangeHat", InputEvent.Pressed, function()
	Events.CallRemote("ChangeHat")
	Play2dSound("click.mp3", 4, 2)
end)

Input.Register("ToggleHelpUI", "H")
Input.Bind("ToggleHelpUI", InputEvent.Pressed, function()
	UI:CallEvent("ToggleHelpUI")
	Play2dSound("help.mp3", 1, 1)
	CenterMouse()
end)

Input.Subscribe("MouseScroll", function(mouse_x, mouse_y, delta)
	Events.CallRemote("ToggleWeapon")
end)

function CenterMouse()
	local size = Viewport.GetViewportSize()
	Viewport.SetMousePosition(Vector2D(size.X / 2, 7 * size.Y / 8))
end