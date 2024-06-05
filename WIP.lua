repeat
    task.wait()
until game:IsLoaded()

--// Config
local Config = {
    Enabled = getgenv().GreggConfig.Enabled,
    ResetInYokai = getgenv().GreggConfig.ResetInYokai,
    DisableSpells = getgenv().GreggConfig.DisableSpells,
    WebHookSettings = {
        Enabled = getgenv().GreggConfig.WebHook.Enabled,
        SendPlayerName = getgenv().GreggConfig.WebHook.SendPlayerName,
        Url = getgenv().GreggConfig.WebHook.URL
    }
}

--// Settings
local Materials = {
    Amethyst = 0,
    Gold = 0,
    Obsidian = 0,
    Metal = 0,
}

--// Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--// Variables
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Character = Player.Character or Player.CharacterAdded:Wait()

local dungeonName
local dungeon
local Amount
local Material
local Total
local ReEncoded

local AmethystMaps = {"Yokai Peak", "Aquatic Temple", "Ghastly Harbor", "King's Castle"}
local GoldMaps = {"Gilded Skies", "Volcanic Chambers", "The Canals", "Pirate Island"}
local ObsidianMaps = {"Northern Lands", "Orbital Outpost", "Samurai Palace", "Winter Outpost"}
local MetalMaps = {"Enchanted Forest", "Steampunk Sewers", "Underworld", "Desert Temple"}

--// Functions
local function SendWebhook(Dungeon, Material, Amount, Total)
    local data, url
    task.spawn(function()
        url = Config.WebHookSettings.Url
        data = {
            ["embeds"] = {
                {
                    ["title"] = "Gregg Defeated",
                    ["color"] = tonumber(string.format("0x%X", math.random(0x000000, 0xFFFFFF))),
                    ["type"] = "rich",
                    ["fields"] = {
                        {
                            ["name"] = "Information",
                            ["value"] = `Name: {Player.Name}\nDungeon: {Dungeon}`,
                        },
                        {
                            ["name"] = "Material Information",
                            ["value"] = `Material Type: {Material}\nAmount Added: {Amount}\nTotal Amount: {Total}`
                        }
                    },
                    ["footer"] = {
                        ["icon_url"] = "https://cdn.discordapp.com/avatars/1140186977359102053/1919becaa00c6edf63a35633ba6608d9",
                        ["text"] = "Fuck Off Gregg"
                    }
                }
            }
        }
        repeat
            task.wait()
        until data
        local newdata = HttpService:JSONEncode(data)
        local headers = {
            ["Content-Type"] = "application/json"
        }
        local request = http_request or request or HttpPost or http.request
        local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
        request(abcdef)
    end)
end

local function ResetPlayer()
    Character.Humanoid.Health = 0
    PlayerGui.RevivePrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
        game:GetService("ReplicatedStorage"):WaitForChild("dataRemoteEvent"):FireServer(unpack({[1] = {[1] = {["\3"] = "closeRevive"}, [2] = "\13"}}))
        PlayerGui.RevivePrompt.Enabled = false
    end)
end

local function SeeMaterials()
    for i, v in Materials do
        print(`{i}: {v}`)
    end
end

local function GreggDied()
    print("Reset When Gregg Dies")
    game.Workspace.DescendantRemoving:Connect(function(descendant)
        if descendant.Name == "Gregg" then
            Amount = PlayerGui.CrossDungeonGregg.greggRewards.Material.TextLabel.Text
            for i, v in pairs(AmethystMaps) do
                if dungeonName == v then

                    Material = "Astral Amethyst"
                    Materials.Amethyst += string.sub(Amount, 2)
                    Total = Materials.Amethyst

                    ReEncoded = HttpService:JSONEncode(Materials)
                    writefile("GreggTracker.json", ReEncoded)

                end
            end
            for i, v in pairs(GoldMaps) do
                if dungeonName == v then

                    Material = "Gold Bar"
                    Materials.Gold += string.sub(Amount, 2)
                    Total = Materials.Gold

                    ReEncoded = HttpService:JSONEncode(Materials)
                    writefile("GreggTracker.json", ReEncoded)

                end
            end
            for i, v in pairs(ObsidianMaps) do
                if dungeonName == v then

                    Material = "Obsidian Chunk"
                    Materials.Obsidian += string.sub(Amount, 2)
                    Total = Materials.Obsidian

                    ReEncoded = HttpService:JSONEncode(Materials)
                    writefile("GreggTracker.json", ReEncoded)

                end
            end
            for i, v in pairs(MetalMaps) do
                if dungeonName == v then

                    Material = "Warforged Metal"
                    Materials.Metal += string.sub(Amount, 2)
                    Total = Materials.Metal

                    ReEncoded = HttpService:JSONEncode(Materials)
                    writefile("GreggTracker.json", ReEncoded)

                end
            end
            SendWebhook(dungeonName, Material, Amount, Total)
            ResetPlayer()
        end
    end)
end

--// Lobby
if game.PlaceId == 2414851778 then
    local CraftingMenu = PlayerGui:WaitForChild("CraftingUI"):WaitForChild("Main"):WaitForChild("Topbar")

    task.wait(3)

    Materials.Amethyst = CraftingMenu["Astral Amethyst"].TextLabel.Text
    Materials.Gold = CraftingMenu["Gold Bar"].TextLabel.Text
    Materials.Obsidian = CraftingMenu["Obsidian Chunk"].TextLabel.Text
    Materials.Metal = CraftingMenu["Warforged Metal"].TextLabel.Text

    SeeMaterials()

    local JSON = HttpService:JSONEncode(Materials)

    if not isfile("GreggTracker.json") then
        warn("No config file found! Creating one.")
    else
        warn("Found config file!")
    end
    writefile("GreggTracker.json", JSON)
end

--// Dungeon
if game.PlaceId == 14363263080 then
    dungeon = game.Workspace:WaitForChild("dungeon")
    dungeonName = game.Workspace:WaitForChild("dungeonName").Value

    if isfile("GreggTracker.json") then
        local DecodedJSON = HttpService:JSONDecode(readfile("GreggTracker.json"))
        for i, v in pairs(DecodedJSON) do
            Materials[i] = v
        end
    else
        Player:Kick("No config found!")
    end

    SeeMaterials()

    if dungeonName == "Yokai Peak" then
        if Config.ResetInYokai == true then
            GreggDied()
        end
    else GreggDied()
    end

    if dungeonName == "Samurai Palace" then
        game.Workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Sanada Yukimura" then
                ResetPlayer()
            end
        end)
    elseif dungeonName == "Steampunk Sewers" then
        game.Workspace.dungeon.room4.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Hammer Bot" then
                ResetPlayer()
            end
        end)
    elseif dungeonName == "Orbital Outpost" then
        game.Workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Tesla Master" then
                ResetPlayer()
            end
        end)
    elseif dungeonName == "Volcanic Chambers" then
        game.Workspace.dungeon.room8.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Aggressive Lava Walker" then
                ResetPlayer()
            end
        end)
    elseif dungeonName == "Enchanted Forest" then
        game.Workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Crystal Golem" then
                ResetPlayer()
            end
        end)
    elseif dungeonName == "Gilded Skies" then
        game.Workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "General Cragg" then
                ResetPlayer()
            end
        end)
    end
end

print("Loaded")
