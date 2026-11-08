local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal a Cheese | Auto-Farm",
   LoadingTitle = "Loading Hub...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true,
   KeySettings = {
      Title = "Mozart Hub | Key System",
      Subtitle = "Key System Required",
      Note = "Click 'Copy Key Link', paste it in your browser, complete the steps to get the key!",
      FileName = "MozartHubKey", 
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"MozartCheeseKey2026"},
      Actions = {
         {
            Text = "Copy Key Link",
            OnPress = function()
                setclipboard("https://direct-link.net/9934473/O18tjCoo5pXr")
                
                Rayfield:Notify({
                   Title = "Link Copied!",
                   Content = "Paste the copied Linkvertise link into your browser to get your key.",
                   Duration = 5,
                })
            end
         }
      }
   }
})

local FarmTab = Window:CreateTab("Farm", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

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
local antiGameplayPausedEnabled = true
local antiPauseConnections = {}

local function setAntiGameplayPaused(state)
    antiGameplayPausedEnabled = state

    for _, conn in ipairs(antiPauseConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(antiPauseConnections)

    if state then
        local guiService = game:GetService("GuiService")
        local runService = game:GetService("RunService")

        local renderConn = runService.RenderStepped:Connect(function()
            if antiGameplayPausedEnabled then
                pcall(function()
                    if guiService.GameplayPaused then
                        guiService.GameplayPaused = false
                    end
                end)
            end
        end)
        table.insert(antiPauseConnections, renderConn)

        local propConn = guiService:GetPropertyChangedSignal("GameplayPaused"):Connect(function()
            if antiGameplayPausedEnabled and guiService.GameplayPaused then
                pcall(function()
                    guiService.GameplayPaused = false
                end)
            end
        end)
        table.insert(antiPauseConnections, propConn)

        pcall(function()
            local robloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
            if robloxGui then
                local pauseGui = robloxGui:FindFirstChild("GameplayPaused") or robloxGui:FindFirstChild("PauseMenu")
                if pauseGui then
                    pauseGui.Enabled = false
                end
            end
        end)
    end
end

task.spawn(function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)

    setAntiGameplayPaused(true)

    local function makeInstant(prompt)
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
        end
    end
    
    for _, descendant in ipairs(workspace:GetDescendants()) do
        makeInstant(descendant)
    end
    
    workspace.DescendantAdded:Connect(makeInstant)
    
    Rayfield:Notify({
       Title = "Hub Initialized",
       Content = "Anti-Pause, Anti-AFK & Instant Prompts active!",
       Duration = 3,
    })
end)

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
                    table.insert(foundPrompts, descendant)
                end
            end

            if #foundPrompts == 0 then
                task.wait(3)
                continue
            end

            for _, prompt in ipairs(foundPrompts) do
                if not activeFarms[levelNum] then break end
                
                if prompt and prompt.Parent then
                    char = player.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    local parentPart = prompt.Parent
                    
                    if root and parentPart then
                        root.CFrame = parentPart.CFrame
                        task.wait(0.15)
                        
                        fireproximityprompt(prompt, 0)
                        task.wait(0.15)
                        
                        root.CFrame = safeZoneCFrame
                        task.wait(0.5)
                    end
                end
            end
            
            task.wait(0.2)
        end
        
        activeFarmThreads[levelNum] = nil
    end)
end

local earthLevelOptions = {
    "Level 1", "Level 2", "Level 3", "Level 4",
    "Level 5", "Level 6", "Level 7", "Level 8",
    "Level 9", "Level 10", "Level 11", "Level 12"
}

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

SettingsTab:CreateToggle({
   Name = "Instant Proximity Prompt",
   CurrentValue = true,
   Callback = function(Value)
       local function toggleInstant(prompt)
           if prompt:IsA("ProximityPrompt") then
               prompt.HoldDuration = Value and 0 or 0.5
           end
       end
       for _, descendant in ipairs(workspace:GetDescendants()) do
           toggleInstant(descendant)
       end
   end,
})

SettingsTab:CreateToggle({
   Name = "Anti Gameplay Paused",
   CurrentValue = true,
   Callback = function(Value)
       setAntiGameplayPaused(Value)
   end,
})
