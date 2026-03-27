Hats = Assets.GetStaticMeshes("polygon-hats")
table.insert(Hats, "None")
NoneId = #Hats

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

function SetHat(player, hatId)
    if not hatId then
        return
    end

    local character = player:GetControlledCharacter()
    if not character or not character:IsValid() then
        return
    end

    local hat = Hats[hatId]
    if not hat then
        return
    end

    if hat == "None" then
        if HasStaticMeshAttached(character, player:GetValue("HatAsset")) then
            character:RemoveStaticMeshAttached("hat")
        end
        player:SetValue("HatAsset", nil)
    else
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
        player:SetValue("HatAsset", "polygon-hats::" .. hat.key)
    end

    GetSelections(player).hatId = hatId

    player:SetValue("HatId", hatId)
end

function DefineHat(player)
    local sel = GetSelections(player)
    if sel.hatId then
        SetHat(player, sel.hatId)
    else
        ChangeHat(player)
    end
end

function ChangeHat(player) 
    local hatId = player:GetValue("HatId")
    if not hatId then
        local sel = PlayerSelections[player:GetAccountID()]
        if sel and sel.hatId then
            hatId = sel.hatId
        else
            hatId = math.random(1, #Hats)
        end
    end
    hatId = (hatId % #Hats) + 1
    SetHat(player, hatId)
end

function GetAdjustment(player)
    local skinId = player:GetValue("SkinId") or 0
    local skin = Skins[skinId] or "SK_Mannequin"
    if string.sub(skin, 1, 6) == "Color_" then
        skin = string.match(skin, "Color_[^_]+_(.*)")
    end
    return Adjustments[skin] or Vector(0, 0, 0)
end