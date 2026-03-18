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
end)

Input.Register("ChangeHat", "K")
Input.Bind("ChangeHat", InputEvent.Pressed, function()
	Events.CallRemote("ChangeHat")
end)

Input.Register("ToggleHelpUI", "H")
Input.Bind("ToggleHelpUI", InputEvent.Pressed, function()
	UI:CallEvent("ToggleHelpUI")
end)

Input.Subscribe("MouseScroll", function(mouse_x, mouse_y, delta)
	Events.CallRemote("ToggleWeapon")
end)
