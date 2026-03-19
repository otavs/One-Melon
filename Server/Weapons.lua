function EquipWeapon(player, weaponName)
  if Game.State ~= State.Playing then
    return
  end

  local character = player:GetControlledCharacter()
  if not character or not character:IsValid() then
    return
  end

  local weaponToEquip = player:GetValue(weaponName)
  if not weaponToEquip or not weaponToEquip:IsValid() then
    weaponToEquip = CreateWeapon(weaponName)
    player:SetValue(weaponName, weaponToEquip)
  end

  local currentWeapon = player:GetValue("EquippedWeapon")

  character:PickUp(weaponToEquip)
  player:SetValue("EquippedWeapon", weaponToEquip)
  ShowWeapon(weaponToEquip)

  if currentWeapon and currentWeapon:IsValid() and currentWeapon ~= weaponToEquip then
    HideWeapon(currentWeapon)
  end
end

function CreateWeapons(player)
  local melonGun = CreateWeapon("MelonGun")
  local bonker = CreateWeapon("Bonker")

  player:SetValue("MelonGun", melonGun)
  player:SetValue("Bonker", bonker)

  HideWeapon(player:GetValue("MelonGun"))
  HideWeapon(player:GetValue("Bonker"))

  Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())
end

function CreateWeapon(weaponName)
  if weaponName == "MelonGun" then
    return MelonGun(Vector(), Rotator())
  elseif weaponName == "Bonker" then
    return Bonker(Vector(), Rotator())
  end
end

function ToggleWeapon(player)
  if Game.State ~= State.Playing or not player or not player:IsValid() then
    return
  end
  
  local equippedWeapon = player:GetValue("EquippedWeapon")
  if equippedWeapon:IsA(MelonGun) then
    EquipWeapon(player, "Bonker")
  else
    EquipWeapon(player, "MelonGun")
  end
end

function HideWeapon(weapon)
  if weapon and weapon:IsValid() then
    weapon:SetVisibility(false)
  end
end

function ShowWeapon(weapon)
  if weapon and weapon:IsValid() then
    weapon:SetVisibility(true)
  end
end

function AddAmmo(player, amount)
  if not player or not player:IsValid() then
    return
  end
  local melonGun = player:GetValue("MelonGun")
  if melonGun and melonGun:IsValid() then
    melonGun:AddAmmo(amount)
    Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())
  end
end

function SetAmmo(player, amount)
  if not player or not player:IsValid() then
    return
  end
  local melonGun = player:GetValue("MelonGun")
  if melonGun and melonGun:IsValid() then
    melonGun:SetAmmoSettings(amount, 0)
    Events.CallRemote("UpdateAmmo", player, melonGun:GetAmmoClip())
  end
end

function GetWeaponType(causer)
  if causer then
    if causer:IsA(Melon) then
      return "Melon"
    elseif causer:IsA(Bonker) then
      return "Bonker"
    end
  end
end

function DestroyWeapons(player)
  local melonGun = player:GetValue("MelonGun")
  if melonGun and melonGun:IsValid() then
    melonGun:Destroy()
    player:SetValue("MelonGun", nil)
  end

  local bonker = player:GetValue("Bonker")
  if bonker and bonker:IsValid() then
    bonker:Destroy()
    player:SetValue("Bonker", nil)
  end
end