Events.SubscribeRemote("ToggleWeapon", function(player)
  ToggleWeapon(player)
end)

Events.SubscribeRemote("EquipWeapon", function(player, weaponName)
  EquipWeapon(player, weaponName)
end)

Events.SubscribeRemote("ChangeSkin", function(player)
  ChangeSkin(player)
end)

Events.SubscribeRemote("ChangeHat", function(player)
  ChangeHat(player)
end)
