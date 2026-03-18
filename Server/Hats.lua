Hats = Assets.GetStaticMeshes("polygon-hats")
table.insert(Hats, false)

Adjustments = {
    SK_Female = Vector(4, -3, 0),
    SK_Male = Vector(10, 0, 0),
    SK_Mannequin = Vector(0, 0, 0),
    SK_Mannequin_Female = Vector(-5, -2, 0),
    SK_PostApocalyptic = Vector(3, -1, 0),
    SK_ClassicMale = Vector(0, 0, 0),
    SK_Adventure_01_Full_01 = Vector(0, -2, 0),
    SK_Adventure_01_Full_02 = Vector(0, -2, 0),
    SK_Adventure_02_Full_01 = Vector(3, -3, 0),
    SK_Adventure_02_Full_02 = Vector(2, -3, 0),
    SK_Adventure_03_Full_01 = Vector(11, -5, 0),
    SK_Adventure_03_Full_02 = Vector(9, -4, 0),
    SK_Adventure_04_Full_01 = Vector(5, -4, 0),
    SK_Adventure_04_Full_02 = Vector(1, -3, 0),
    SK_Adventure_05_Full_01 = Vector(5, 0, 0),
    SK_Adventure_05_Full_02 = Vector(5, 0, 0),
}

function ChangeHat(player, justUpdate) 
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        local hatId = player:GetValue("HatId") or 0
        if not justUpdate then
            hatId = (hatId % #Hats) + 1
        end
        local hat = Hats[hatId]
        if hat then
            local position = Vector(7, 3, 0)
            local rotation = Rotator(-90, 0, 0)
            if hat.key == "SM_TopHat" or hat.key == "SM_WorkerHat" or hat.key == "SM_queencrown_hat" or hat.key == "SM_PirateHat" or hat.key == "SM_QueenCrown" then
                rotation = Rotator(0, 90, -90)
            end
            if hat.key == "SM_PropellerHat" then
                position = Vector(10, 2, 0)
            end
            character:AddStaticMeshAttached(
                "hat",
                "polygon-hats::" .. hat.key,
                "head",
                position + GetAdjustment(player),
                rotation
            )
        elseif not player:GetValue("HatId") then
            character:RemoveStaticMeshAttached("hat")
        end
        player:SetValue("HatId", hatId)
    end
end

function GetAdjustment(player)
    local skinId = player:GetValue("SkinId") or 0
    local skin = Skins[skinId] or "SK_Mannequin"
    if string.sub(skin, 1, 6) == "Color_" then
        skin = string.match(skin, "Color_[^_]+_(.*)")
    end
    return Adjustments[skin] or Vector(0, 0, 0)
end