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
local safeZoneCFrame = CFrame.new(0, 3, 37.5)
local levelCoordinates = {
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

local activeFarms = {}
local activeFarmThreads = {}
local selectedRarities = {}
local activeRarityFilterCount = 0

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
    while packageModel and packageModel.Parent and packageModel.Parent ~= workspace.World.Levels do
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

local function startFarming(levelNum)
    if activeFarmThreads[levelNum] then return end
    
    activeFarmThreads[levelNum] = task.spawn(function()
        local player = game.Players.LocalPlayer
        
        while activeFarms[levelNum] do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and levelCoordinates[levelNum] then
                root.CFrame = levelCoordinates[levelNum]
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
                if not activeFarms[levelNum] then break end
                
                if prompt and prompt.Parent and prompt.Enabled then
                    char = player.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    local parentPart = prompt.Parent
                    
                    if root and parentPart then
                        root.CFrame = parentPart.CFrame
                        task.wait(0.15)
                        
                        fireproximityprompt(prompt, 0)
                        
                        -- Verification loop: wait until prompt disappears or is collected (max timeout 1.5s)
                        local startTime = tick()
                        while prompt and prompt.Parent and prompt.Enabled and (tick() - startTime < 1.5) do
                            task.wait(0.1)
                        end
                        
                        root.CFrame = safeZoneCFrame
                        -- 1 second gap after successfully stealing before targeting the next
                        task.wait(1.0)
                    end
                end
            end
            
            task.wait(0.2)
        end
        
        activeFarmThreads[levelNum] = nil
    end)
end

-- Function to construct the main script tabs after key is verified
local function unlockHubFeatures()
    buildRarityMap()

    -- Initialize global automation functions
    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)

    local FarmTab = Window:CreateTab("Farm", 4483362458)
    local ImportantTab = Window:CreateTab("Important", 4483362458)

    local earthLevelOptions = {
        "Level 1", "Level 2", "Level 3", "Level 4",
        "Level 5", "Level 6", "Level 7", "Level 8",
        "Level 9", "Level 10", "Level 11", "Level 12"
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
               activeFarms[i] = shouldFarm
               if shouldFarm then
                   startFarming(i)
               end
           end
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
       Content = "Farm and Important tabs unlocked!",
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
