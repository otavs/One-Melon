Hats = Assets.GetStaticMeshes("polygon-hats")
table.insert(Hats, false)

function ChangeHat(player) 
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        local hatId = player:GetValue("HatId") or 0
        hatId = (hatId % #Hats) + 1
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
                position,
                rotation
            )
        else
            character:RemoveStaticMeshAttached("hat")
        end
        player:SetValue("HatId", hatId)
    end
end
