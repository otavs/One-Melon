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
    "SK_Adventure_05_Full_02",

    "Color_RED_SK_Mannequin",
    "Color_GREEN_SK_Mannequin",
    "Color_BLUE_SK_Mannequin",
    "Color_YELLOW_SK_Mannequin",
    "Color_CYAN_SK_Mannequin",
    "Color_MAGENTA_SK_Mannequin",
    "Color_ORANGE_SK_Mannequin",
    "Color_CHARTREUSE_SK_Mannequin",
    "Color_AQUAMARINE_SK_Mannequin",
    "Color_AZURE_SK_Mannequin",
    "Color_VIOLET_SK_Mannequin",
    "Color_BLACK_SK_Mannequin",

    "Color_RED_SK_Female",
    "Color_GREEN_SK_Female",
    "Color_BLUE_SK_Female",
    "Color_YELLOW_SK_Female",
    "Color_CYAN_SK_Female",
    "Color_MAGENTA_SK_Female",
    "Color_ORANGE_SK_Female",
    "Color_CHARTREUSE_SK_Female",
    "Color_AQUAMARINE_SK_Female",
    "Color_AZURE_SK_Female",
    "Color_VIOLET_SK_Female",
    "Color_BLACK_SK_Female",

    "Color_RED_SK_Male",
    "Color_GREEN_SK_Male",
    "Color_BLUE_SK_Male",
    "Color_YELLOW_SK_Male",
    "Color_CYAN_SK_Male",
    "Color_MAGENTA_SK_Male",
    "Color_ORANGE_SK_Male",
    "Color_CHARTREUSE_SK_Male",
    "Color_AQUAMARINE_SK_Male",
    "Color_AZURE_SK_Male",
    "Color_VIOLET_SK_Male",
    "Color_BLACK_SK_Male",
    
    "Color_RED_SK_Mannequin_Female",
    "Color_GREEN_SK_Mannequin_Female",
    "Color_BLUE_SK_Mannequin_Female",
    "Color_YELLOW_SK_Mannequin_Female",
    "Color_CYAN_SK_Mannequin_Female",
    "Color_MAGENTA_SK_Mannequin_Female",
    "Color_ORANGE_SK_Mannequin_Female",
    "Color_CHARTREUSE_SK_Mannequin_Female",
    "Color_AQUAMARINE_SK_Mannequin_Female",
    "Color_AZURE_SK_Mannequin_Female",
    "Color_VIOLET_SK_Mannequin_Female",
    "Color_BLACK_SK_Mannequin_Female",
}

function ChangeSkin(player)
    local character = player:GetControlledCharacter()
    if character and character:IsValid() then
        local skinId = player:GetValue("SkinId") or 0
        skinId = (skinId % #Skins) + 1
        local skin = Skins[skinId]

        if string.sub(skin, 1, 6) == "Color_" then
            local parts = {}
            for part in string.gmatch(skin, "([^_]+)") do
                table.insert(parts, part)
            end
            local colorName = parts[2] or "WHITE"
            local meshName = table.concat({select(3, table.unpack(parts))}, "_") or "SK_Mannequin"

            local color = Color[colorName] or Color.WHITE
            character:SetMesh("nanos-world::" .. meshName)
            character:SetMaterialColorParameter("Tint", color)
        else
            character:SetMesh("nanos-world::" .. skin)
            character:SetMaterialColorParameter("Tint", Color.WHITE)
        end

        player:SetValue("SkinId", skinId)
        ChangeHat(player, true)
    end
end