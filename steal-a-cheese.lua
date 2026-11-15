local keyURL = "https://direct-link.net/9934473/O18tjCoo5pXr"
local validKey = "KeyKey_DoYouLoveMe?"
local keyFileName = "MozartHubKey.txt"

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal a Cheese | Auto-Farm",
   LoadingTitle = "Loading Hub...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local moonFolderNames = {
    [1] = "MareCheddarium",
    [2] = "SwissHoles",
    [3] = "RindRidge",
    [4] = "CurdCanyon",
    [5] = "FarSide",
    [6] = "BlueVein",
    [7] = "MoltenMare",
    [8] = "GreatWheel"
}

local activeEarthFarms = {}
local activeEarthFarmThreads = {}

local activeMoonFarms = {}
local activeMoonFarmThreads = {}

local activeRiftFarms = {}
local activeRiftFarmThreads = {}

local selectedRarities = {}
local activeRarityFilterCount = 0

local customWalkSpeed = 16
local customJumpPower = 50
local walkSpeedEnabled = false
local jumpPowerEnabled = false
local infiniteJumpEnabled = false
local noclipEnabled = false

local autoOpenEnabled = false
local autoPlaceEnabled = false

local uploadedIdRarityMap = {}

local function buildRarityMap()
    table.clear(uploadedIdRarityMap)
    pcall(function()
        local cheeseModelsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("CheeseModels")
        if not cheeseModelsFolder then return end

        for _, rarityFolder in ipairs(cheeseModelsFolder:GetChildren()) do
            if rarityFolder:IsA("Folder") then
                local rarityName = rarityFolder.Name
                for _, desc in ipairs(rarityFolder:GetDescendants()) do
                    local uploadedId = desc:GetAttribute("UploadedId")
                    if uploadedId then
                        uploadedIdRarityMap[tostring(uploadedId)] = rarityName
                    end

                    if desc:IsA("MeshPart") then
                        if desc.MeshId ~= "" then
                            uploadedIdRarityMap[desc.MeshId] = rarityName
                        end
                        if desc.TextureID ~= "" then
                            uploadedIdRarityMap[desc.TextureID] = rarityName
                        end
                    end
                end
            end
        end
    end)
end

local function isRarityAllowed(prompt)
    if activeRarityFilterCount == 0 then
        return true
    end

    local dimensionFolder = workspace.World:FindFirstChild("Dimension")
    local packageModel = prompt.Parent
    while packageModel and packageModel.Parent and packageModel.Parent ~= workspace.World.Levels and packageModel.Parent ~= workspace.World.Craters and packageModel.Parent ~= dimensionFolder do
        if packageModel.Name:match("Package") or packageModel.Name:match("Wrapped") then
            break
        end
        packageModel = packageModel.Parent
    end

    if not packageModel then return false end

    for _, desc in ipairs(packageModel:GetDescendants()) do
        local uploadedId = desc:GetAttribute("UploadedId")
        if uploadedId then
            local matchedRarity = uploadedIdRarityMap[tostring(uploadedId)]
            if matchedRarity and selectedRarities[matchedRarity] then
                return true
            end
        end

        if desc:IsA("MeshPart") then
            local meshRarity = uploadedIdRarityMap[desc.MeshId] or uploadedIdRarityMap[desc.TextureID]
            if meshRarity and selectedRarities[meshRarity] then
                return true
            end
        end
        
        local rarityAttr = desc:GetAttribute("Rarity") or desc:GetAttribute("Tier")
        if rarityAttr and selectedRarities[tostring(rarityAttr)] then
            return true
        end
    end

    return false
end

-- Earth Farming Loop
local function startEarthFarming(levelNum)
    if activeEarthFarmThreads[levelNum] then return end
    
    activeEarthFarmThreads[levelNum] = task.spawn(function()
        local player = game.Players.LocalPlayer
        
        while activeEarthFarms[levelNum] do
            local levelFolderName = string.format("Level%02d", levelNum)
            local levelFolder = workspace.World.Levels:FindFirstChild(levelFolderName)
            
            if not levelFolder then
                task.wait(2)
                continue
            end

            local foundPrompt = nil
            for _, descendant in ipairs(levelFolder:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.Name == "StealPrompt" and descendant.Enabled then
                    if isRarityAllowed(descendant) then
                        foundPrompt = descendant
                        break
                    end
                end
            end

            if not foundPrompt then
                task.wait(1.5)
                continue
            end

            pcall(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local parentPart = foundPrompt and foundPrompt.Parent

                if root and parentPart and foundPrompt.Enabled then
                    local originalCFrame = root.CFrame
                    
                    root.CFrame = parentPart.CFrame
                    task.wait(0.2)
                    fireproximityprompt(foundPrompt, 0)
                    
                    local startTime = tick()
                    while foundPrompt and foundPrompt.Parent and foundPrompt.Enabled and (tick() - startTime < 1.5) do
                        task.wait(0.1)
                    end
                    
                    char = player.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = originalCFrame
                    end
                end
            end)
            
            task.wait(1.8)
            task.wait(0.8)
        end
        
        activeEarthFarmThreads[levelNum] = nil
    end)
end

-- Moon Farming Loop
local function startMoonFarming(levelNum)
    if activeMoonFarmThreads[levelNum] then return end
    
    activeMoonFarmThreads[levelNum] = task.spawn(function()
        local player = game.Players.LocalPlayer
        
        while activeMoonFarms[levelNum] do
            local craterFolderName = moonFolderNames[levelNum]
            local cratersFolder = workspace.World:FindFirstChild("Craters")
            local craterFolder = cratersFolder and cratersFolder:FindFirstChild(craterFolderName)
            
            if not craterFolder then
                task.wait(2)
                continue
            end

            local foundPrompt = nil
            for _, descendant in ipairs(craterFolder:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.Name == "StealPrompt" and descendant.Enabled then
                    if isRarityAllowed(descendant) then
                        foundPrompt = descendant
                        break
                    end
                end
            end

            if not foundPrompt then
                task.wait(1.5)
                continue
            end

            pcall(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local parentPart = foundPrompt and foundPrompt.Parent

                if root and parentPart and foundPrompt.Enabled then
                    local originalCFrame = root.CFrame
                    
                    root.CFrame = parentPart.CFrame
                    task.wait(0.2)
                    fireproximityprompt(foundPrompt, 0)
                    
                    local startTime = tick()
                    while foundPrompt and foundPrompt.Parent and foundPrompt.Enabled and (tick() - startTime < 1.5) do
                        task.wait(0.1)
                    end
                    
                    char = player.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = originalCFrame
                    end
                end
            end)
            
            task.wait(1.8)
            task.wait(0.8)
        end
        
        activeMoonFarmThreads[levelNum] = nil
    end)
end

-- Rift Farming Loop (Corrected Path: Workspace.World.Dimension.Rift01.Guards...)
local function startRiftFarming(levelNum)
    if activeRiftFarmThreads[levelNum] then return end
    
    activeRiftFarmThreads[levelNum] = task.spawn(function()
        local player = game.Players.LocalPlayer
        
        while activeRiftFarms[levelNum] do
            local riftFolderName = string.format("Rift%02d", levelNum)
            local dimensionFolder = workspace.World:FindFirstChild("Dimension")
            local riftLevelFolder = dimensionFolder and dimensionFolder:FindFirstChild(riftFolderName)
            
            if not riftLevelFolder then
                task.wait(2)
                continue
            end

            local foundPrompt = nil
            for _, descendant in ipairs(riftLevelFolder:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.Name == "StealPrompt" and descendant.Enabled then
                    if isRarityAllowed(descendant) then
                        foundPrompt = descendant
                        break
                    end
                end
            end

            if not foundPrompt then
                task.wait(1.5)
                continue
            end

            pcall(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local parentPart = foundPrompt and foundPrompt.Parent

                if root and parentPart and foundPrompt.Enabled then
                    local originalCFrame = root.CFrame
                    
                    root.CFrame = parentPart.CFrame
                    task.wait(0.2)
                    fireproximityprompt(foundPrompt, 0)
                    
                    local startTime = tick()
                    while foundPrompt and foundPrompt.Parent and foundPrompt.Enabled and (tick() - startTime < 1.5) do
                        task.wait(0.1)
                    end
                    
                    char = player.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = originalCFrame
                    end
                end
            end)
            
            task.wait(1.8)
            task.wait(0.8)
        end
        
        activeRiftFarmThreads[levelNum] = nil
    end)
end

local function unlockHubFeatures()
    buildRarityMap()

    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")

    RunService.Stepped:Connect(function()
        local player = Players.LocalPlayer
        local char = player.Character
        if not char then return end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if walkSpeedEnabled then
                humanoid.WalkSpeed = customWalkSpeed
            end
            if jumpPowerEnabled then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = customJumpPower
            end
        end

        if noclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            local char = Players.LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            if autoOpenEnabled then
                pcall(function()
                    local plotsFolder = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Lobby") and workspace.World.Lobby:FindFirstChild("Plots")
                    if plotsFolder then
                        for _, plot in ipairs(plotsFolder:GetChildren()) do
                            local owner = plot:FindFirstChild("Owner") or plot:GetAttribute("Owner")
                            local isOwner = false
                            if owner == Players.LocalPlayer or owner == Players.LocalPlayer.Name or (typeof(owner) == "Instance" and owner.Value == Players.LocalPlayer) then
                                isOwner = true
                            else
                                local plate = plot:FindFirstChild("Plate")
                                if plate then
                                    for _, slot in ipairs(plate:GetChildren()) do
                                        if slot:FindFirstChild("OpenPrompt") then
                                            isOwner = true
                                            break
                                        end
                                    end
                                end
                            end

                            if isOwner then
                                local plate = plot:FindFirstChild("Plate")
                                if plate then
                                    for _, slot in ipairs(plate:GetChildren()) do
                                        local prompt = slot:FindFirstChild("OpenPrompt")
                                        if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                            fireproximityprompt(prompt, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1.0)
            if autoPlaceEnabled then
                pcall(function()
                    local placeAllRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("PlaceAll")
                    if placeAllRemote then
                        placeAllRemote:FireServer()
                    end
                end)
            end
        end
    end)

    local FarmTab = Window:CreateTab("Farm", 4483362458)
    local PlayerTab = Window:CreateTab("Player", 4483362458)
    local AutomationTab = Window:CreateTab("Automation", 4483362458)
    local ImportantTab = Window:CreateTab("Important", 4483362458)

    local earthLevelOptions = {
        "Level 1", "Level 2", "Level 3", "Level 4",
        "Level 5", "Level 6", "Level 7", "Level 8",
        "Level 9", "Level 10", "Level 11", "Level 12"
    }

    local moonLevelOptions = {
        "Level 1", "Level 2", "Level 3", "Level 4",
        "Level 5", "Level 6", "Level 7", "Level 8"
    }

    local riftLevelOptions = {
        "Level 1", "Level 2", "Level 3", "Level 4",
        "Level 5", "Level 6", "Level 7", "Level 8",
        "Level 9", "Level 10"
    }

    local rarityOptions = {
        "Common", "Uncommon", "Rare", "Epic",
        "Legendary", "Mythic", "Divine", "Ancient",
        "Cosmic", "Golden"
    }

    FarmTab:CreateDropdown({
       Name = "Filter by Rarity",
       Options = rarityOptions,
       CurrentOption = {},
       MultipleOptions = true,
       Flag = "RarityFilterDropdown",
       Callback = function(SelectedOptions)
           table.clear(selectedRarities)
           activeRarityFilterCount = #SelectedOptions
           for _, rarity in ipairs(SelectedOptions) do
               selectedRarities[rarity] = true
           end
       end,
    })

    FarmTab:CreateDropdown({
       Name = "Steal Earth",
       Options = earthLevelOptions,
       CurrentOption = {},
       MultipleOptions = true,
       Flag = "StealEarthDropdown",
       Callback = function(SelectedOptions)
           local selectedSet = {}
           for _, opt in ipairs(SelectedOptions) do
               local levelNum = tonumber(opt:match("%d+"))
               if levelNum then
                   selectedSet[levelNum] = true
               end
           end

           for i = 1, 12 do
               local shouldFarm = selectedSet[i] or false
               activeEarthFarms[i] = shouldFarm
               if shouldFarm then
                   startEarthFarming(i)
               end
           end
       end,
    })

    FarmTab:CreateDropdown({
       Name = "Steal Moon",
       Options = moonLevelOptions,
       CurrentOption = {},
       MultipleOptions = true,
       Flag = "StealMoonDropdown",
       Callback = function(SelectedOptions)
           local selectedSet = {}
           for _, opt in ipairs(SelectedOptions) do
               local levelNum = tonumber(opt:match("%d+"))
               if levelNum then
                   selectedSet[levelNum] = true
               end
           end

           for i = 1, 8 do
               local shouldFarm = selectedSet[i] or false
               activeMoonFarms[i] = shouldFarm
               if shouldFarm then
                   startMoonFarming(i)
               end
           end
       end,
    })

    FarmTab:CreateDropdown({
       Name = "Steal Rift",
       Options = riftLevelOptions,
       CurrentOption = {},
       MultipleOptions = true,
       Flag = "StealRiftDropdown",
       Callback = function(SelectedOptions)
           local selectedSet = {}
           for _, opt in ipairs(SelectedOptions) do
               local levelNum = tonumber(opt:match("%d+"))
               if levelNum then
                   selectedSet[levelNum] = true
               end
           end

           for i = 1, 10 do
               local shouldFarm = selectedSet[i] or false
               activeRiftFarms[i] = shouldFarm
               if shouldFarm then
                   startRiftFarming(i)
               end
           end
       end,
    })

    PlayerTab:CreateSection("Movement Modifications")

    PlayerTab:CreateSlider({
       Name = "WalkSpeed",
       Range = {16, 500},
       Increment = 1,
       Suffix = " Speed",
       CurrentValue = 16,
       Flag = "WalkSpeedSlider",
       Callback = function(Value)
           customWalkSpeed = Value
           walkSpeedEnabled = (Value ~= 16)
           local char = Players.LocalPlayer.Character
           local humanoid = char and char:FindFirstChildOfClass("Humanoid")
           if humanoid then
               humanoid.WalkSpeed = customWalkSpeed
           end
       end,
    })

    PlayerTab:CreateSlider({
       Name = "JumpPower",
       Range = {50, 300},
       Increment = 5,
       Suffix = " Power",
       CurrentValue = 50,
       Flag = "JumpPowerSlider",
       Callback = function(Value)
           customJumpPower = Value
           jumpPowerEnabled = (Value ~= 50)
           local char = Players.LocalPlayer.Character
           local humanoid = char and char:FindFirstChildOfClass("Humanoid")
           if humanoid then
               humanoid.UseJumpPower = true
               humanoid.JumpPower = customJumpPower
           end
       end,
    })

    PlayerTab:CreateToggle({
       Name = "Infinite Jump",
       CurrentValue = false,
       Flag = "InfiniteJumpToggle",
       Callback = function(Value)
           infiniteJumpEnabled = Value
       end,
    })

    PlayerTab:CreateToggle({
       Name = "Noclip",
       CurrentValue = false,
       Flag = "NoclipToggle",
       Callback = function(Value)
           noclipEnabled = Value
       end,
    })

    PlayerTab:CreateSection("Quick Teleports")

    PlayerTab:CreateButton({
       Name = "Teleport to Earth Safe Zone",
       Callback = function()
           local char = Players.LocalPlayer.Character
           local root = char and char:FindFirstChild("HumanoidRootPart")
           if root then
               root.CFrame = CFrame.new(0, 3, 37.5)
           end
       end,
    })

    PlayerTab:CreateButton({
       Name = "Teleport to Moon Safe Zone",
       Callback = function()
           local char = Players.LocalPlayer.Character
           local root = char and char:FindFirstChild("HumanoidRootPart")
           if root then
               root.CFrame = CFrame.new(0, 3, 20455)
           end
       end,
    })

    PlayerTab:CreateButton({
       Name = "Teleport to Rift Safe Zone",
       Callback = function()
           local char = Players.LocalPlayer.Character
           local root = char and char:FindFirstChild("HumanoidRootPart")
           if root then
               root.CFrame = CFrame.new(6000, 4, 9002)
           end
       end,
    })

    AutomationTab:CreateSection("Plot Automation")

    AutomationTab:CreateToggle({
       Name = "Auto Open Cheese",
       CurrentValue = false,
       Flag = "AutoOpenToggle",
       Callback = function(Value)
           autoOpenEnabled = Value
       end,
    })

    AutomationTab:CreateToggle({
       Name = "Auto Place All",
       CurrentValue = false,
       Flag = "AutoPlaceToggle",
       Callback = function(Value)
           autoPlaceEnabled = Value
       end,
    })

    ImportantTab:CreateSection("Stability & Performance Notes")
    ImportantTab:CreateParagraph({
       Title = "Recommended Setup", 
       Content = "To ensure maximum script stability, prevent gameplay pauses during high-level teleports, and enforce instant prompts cleanly, please execute Infinite Yield and run the required command below."
    })

    ImportantTab:CreateButton({
       Name = "Execute Infinite Yield",
       Callback = function()
           pcall(function()
               loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
           end)
           Rayfield:Notify({
              Title = "Infinite Yield",
              Content = "Infinite Yield executed successfully!",
              Duration = 3,
           })
       end,
    })

    ImportantTab:CreateButton({
       Name = "Copy IY Command (antigameplaypaused\\instantpp)",
       Callback = function()
           if setclipboard then
               setclipboard("antigameplaypaused\\instantpp")
               Rayfield:Notify({
                  Title = "Command Copied!",
                  Content = "Paste 'antigameplaypaused\\instantpp' in your Infinite Yield chat/console.",
                  Duration = 4,
               })
           end
       end,
    })
    
    Rayfield:Notify({
       Title = "Access Granted",
       Content = "Farm, Player, Automation, and Important tabs unlocked!",
       Duration = 4,
    })
end

local hasSavedKey = false
if isfile and readfile and isfile(keyFileName) then
    if readfile(keyFileName) == validKey then
        hasSavedKey = true
    end
end

if hasSavedKey then
    unlockHubFeatures()
else
    local KeyTab = Window:CreateTab("Key System", 4483362458)
    KeyTab:CreateSection("Monetization & Access")

    KeyTab:CreateButton({
       Name = "Copy Linkvertise Key Link",
       Callback = function()
           if setclipboard then
               setclipboard(keyURL)
               Rayfield:Notify({
                  Title = "Link Copied!",
                  Content = "Paste the Linkvertise link in your browser to get your key.",
                  Duration = 5,
               })
           end
       end,
    })

    local enteredKey = ""

    KeyTab:CreateInput({
       Name = "Enter Access Key",
       PlaceholderText = "Paste key here...",
       RemoveTextAfterFocusLost = false,
       Callback = function(Text)
           enteredKey = Text:gsub("%s+", "")
       end,
    })

    local unlocked = false
    KeyTab:CreateButton({
       Name = "Verify Key",
       Callback = function()
           if unlocked then return end
           
           if enteredKey == validKey then
               unlocked = true
               if writefile then
                   writefile(keyFileName, validKey)
               end
               unlockHubFeatures()
           else
               Rayfield:Notify({
                  Title = "Invalid Key",
                  Content = "Incorrect key! Get the valid key via Linkvertise.",
                  Duration = 4,
              })
           end
       end,
    })
end
