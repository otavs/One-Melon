Events.SubscribeRemote("ToggleWeapon", function(player)
  ToggleWeapon(player)
end)

Events.SubscribeRemote("EquipWeapon", function(player, weaponName)
  EquipWeapon(player, weaponName)
end)