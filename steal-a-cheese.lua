-- PART 1 of 2: Steal a Cheese Hub
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

-- Shared variables for farming features
local earthSafeZoneCFrame = CFrame.new(0, 3, 37.5)
local moonSafeZoneCFrame  = CFrame.new(0, 3, 20455)

local earthCoordinates = {
    [1]  = CFrame.new(0, 3, -130),
    [2]  = CFrame.new(0, 3, -425.5),
    [3]  = CFrame.new(0, 3, -763),
    [4]  = CFrame.new(0, 3, -1148.5),
    [5]  = CFrame.new(0, 3, -1589.5),
    [6]  = CFrame.new(0, 3, -2094.5),
    [7]  = CFrame.new(0, 3, -2672.5),
    [8]  = CFrame.new(0, 3, -3335),
    [9]  = CFrame.new(0, 3, -4094.5),
    [10] = CFrame.new(0, 3, -4965.5),
    [11] = CFrame.new(0, 3, -5965),
    [12] = CFrame.new(0, 3, -7112),
}

local moonCoordinates = {
    [1] = CFrame.new(285, 3, 21410),  -- MareCheddarium
    [2] = CFrame.new(-325, 3, 22615), -- SwissHoles
    [3] = CFrame.new(345, 3, 24030),  -- RindRidge
    [4] = CFrame.new(-295, 3, 25615), -- CurdCanyon
    [5] = CFrame.new(335, 3, 27465),  -- FarSide
    [6] = CFrame.new(-295, 3, 29565), -- BlueVein
    [7] = CFrame.new(315, 3, 32000),  -- MoltenMare
    [8] = CFrame.new(-260, 3, 34790), -- GreatWheel
}

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

local selectedRarities = {}
local activeRarityFilterCount = 0

-- Player Mod States
local customWalkSpeed = 16
local customJumpPower = 50
local walkSpeedEnabled = false
local jumpPowerEnabled = false
local infiniteJumpEnabled = false
local noclipEnabled = false

-- Automation States
local autoOpenEnabled = false
local autoPlaceEnabled = false

-- Rarity lookup tables
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

-- Rarity validation checking UploadedId across descendants
local function isRarityAllowed(prompt)
    if activeRarityFilterCount == 0 then
        return true
    end

    local packageModel = prompt.Parent
    while packageModel and packageModel.Parent and packageModel.Parent ~= workspace.World.Levels and packageModel.Parent ~= workspace.World.Craters do
        if packageModel.Name:match("Package") then
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
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and earthCoordinates[levelNum] then
                root.CFrame = earthCoordinates[levelNum]
                task.wait(0.6)
            end

            local levelFolderName = string.format("Level%02d", levelNum)
            local levelFolder = workspace.World.Levels:FindFirstChild(levelFolderName)
            
            if not levelFolder then
                task.wait(1)
                continue
            end

            local foundPrompts = {}
            for _, descendant in ipairs(levelFolder:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.Name == "StealPrompt" then
                    if isRarityAllowed(descendant) then
                        table.insert(foundPrompts, descendant)
                    end
                end
            end

            if #foundPrompts == 0 then
                task.wait(3)
                continue
            end

            for _, prompt in ipairs(foundPrompts) do
                if not activeEarthFarms[levelNum] then break end
                
                if prompt and prompt.Parent and prompt.Enabled then
                    char = player.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    local parentPart = prompt.Parent
                    
                    if root and parentPart then
                        root.CFrame = parentPart.CFrame
                        task.wait(0.15)
                        
                        fireproximityprompt(prompt, 0)
                        
                        -- Verification loop
                        local startTime = tick()
                        while prompt and prompt.Parent and prompt.Enabled and (tick() - startTime < 1.5) do
                            task.wait(0.1)
                        end
                        
                        root.CFrame = earthSafeZoneCFrame
                        task.wait(1.0)
                    end
                end
            end
            
            task.wait(0.2)
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
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and moonCoordinates[levelNum] then
                root.CFrame = moonCoordinates[levelNum]
                task.wait(0.6)
            end

            local craterFolderName = moonFolderNames[levelNum]
            local cratersFolder = workspace.World:FindFirstChild("Craters")
            local craterFolder = cratersFolder and cratersFolder:FindFirstChild(craterFolderName)
            
            if not craterFolder then
                task.wait(1)
                continue
            end

            local foundPrompts = {}
            for _, descendant in ipairs(craterFolder:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.Name == "StealPrompt" then
                    if isRarityAllowed(descendant) then
                        table.insert(foundPrompts, descendant)
                    end
                end
            end

            if #foundPrompts == 0 then
                task.wait(3)
                continue
            end

            for _, prompt in ipairs(foundPrompts) do
                if not activeMoonFarms[levelNum] then break end
                
                if prompt and prompt.Parent and prompt.Enabled then
                    char = player.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    local parentPart = prompt.Parent
                    
                    if root and parentPart then
                        root.CFrame = parentPart.CFrame
                        task.wait(0.15)
                        
                        fireproximityprompt(prompt, 0)
                        
                        -- Verification loop
                        local startTime = tick()
                        while prompt and prompt.Parent and prompt.Enabled and (tick() - startTime < 1.5) do
                            task.wait(0.1)
                        end
                        
                        root.CFrame = moonSafeZoneCFrame
                        task.wait(1.0)
                    end
                end
            end
            
            task.wait(0.2)
        end
        
        activeMoonFarmThreads[levelNum] = nil
    end)
end
-- PART 2 of 2: Steal a Cheese Hub
-- Function to construct the main script tabs after key is verified
local function unlockHubFeatures()
    buildRarityMap()

    -- Anti-AFK Initialization
    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)

    -- Background enforcement loops for Player Modifications
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

    -- Background Auto Open Loop
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

    -- Background Auto Place Loop
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

    local rarityOptions = {
        "Common", "Uncommon", "Rare", "Epic",
        "Legendary", "Mythic", "Divine", "Ancient",
        "Cosmic", "Golden"
    }

    -- FARM TAB
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

    -- PLAYER TAB
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
               root.CFrame = earthSafeZoneCFrame
           end
       end,
    })

    PlayerTab:CreateButton({
       Name = "Teleport to Moon Safe Zone",
       Callback = function()
           local char = Players.LocalPlayer.Character
           local root = char and char:FindFirstChild("HumanoidRootPart")
           if root then
               root.CFrame = moonSafeZoneCFrame
           end
       end,
    })

    -- AUTOMATION TAB
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

    -- IMPORTANT TAB
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

-- Check if saved key exists
local hasSavedKey = false
if isfile and readfile and isfile(keyFileName) then
    if readfile(keyFileName) == validKey then
        hasSavedKey = true
    end
end

if hasSavedKey then
    unlockHubFeatures()
else
    -- Show ONLY Key System Tab initially
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
