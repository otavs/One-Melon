Skins = {
    "SK_Female",
    "SK_Male",
    "SK_Mannequin",
    "SK_Mannequin_Female",
    "SK_PostApocalyptic",
    "SK_ClassicMale",
    "SK_Adventure_01_Full_01",
    "SK_Adventure_01_Full_02",
    "SK_Adventure_02_Full_01",
    "SK_Adventure_02_Full_02",
    "SK_Adventure_03_Full_01",
    "SK_Adventure_03_Full_02",
    "SK_Adventure_04_Full_01",
    "SK_Adventure_04_Full_02",
    "SK_Adventure_05_Full_01",
    "SK_Adventure_05_Full_02"
}

function ChangeSkin(player) 
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        local skinId = player:GetValue("SkinId") or 0
        skinId = (skinId % #Skins) + 1
        local skin = Skins[skinId]
        character:SetMesh("nanos-world::" .. skin)
        player:SetValue("SkinId", skinId)
        ChangeHat(player, true)
    end
end
