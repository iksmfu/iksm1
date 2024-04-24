-- Services
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local virtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer

-- Player-related variables
local LocalPlayer = Players.LocalPlayer
local localPlayer = Players.LocalPlayer
local Player = game.Players.LocalPlayer

-- Data structures
local Islands = {}
local Interactions = {}

-- Quest and Chest-related variables
local GettingQuest
local ChestTeleporting

-- Create a BindableEvent
local BindableEvent = Instance.new("BindableEvent")
local connection = BindableEvent.Event:Connect(function() end)

spawn(function()
    while wait() do
       if getgenv().Disconnect == true then wait(1)
           connection:Disconnect()
		    getgenv().Disconnect = false
                    getgenv().nexus = false
            return
		else  
			BindableEvent:Fire()  
		end
	end
end)  

function Alive(localPlayer)
    if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and localPlayer.Character:FindFirstChild("Humanoid") ~= nil and localPlayer.Character:FindFirstChild("Head") ~= nil then
        return true
    end
    return false
end

function forceServerHop()
    local Api = "https://games.roblox.com/v1/games/"
    local placeId, jobId = game.PlaceId, game.JobId
    local serversUrl = Api .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"

    local function ListServers(cursor)
        local raw = game:HttpGet(serversUrl .. (cursor and "&cursor=" .. cursor or ""))
        return HttpService:JSONDecode(raw)
    end

    local nextCursor
    repeat
        local serversData = ListServers(nextCursor)
        for _, server in ipairs(serversData.data) do
            if server.playing < server.maxPlayers and server.id ~= jobId then
                local success, result = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, server.id, LocalPlayer)
                if success then
                    break
                end
            end
        end
        nextCursor = serversData.nextPageCursor
    until not nextCursor
end

repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local success, result = pcall(function() 
    while game:GetService("Players").LocalPlayer.PlayerGui.LoadingGui.Frame.Play or game:GetService("Players").LocalPlayer.PlayerGui.LoadingGui.Frame.Play.Visible do wait(1)
        local a = game:GetService("Players").LocalPlayer.PlayerGui.LoadingGui.Frame.Play
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(a.AbsolutePosition.X + a.AbsoluteSize.X/2, a.AbsolutePosition.Y + 50, 0, true, a, 1)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(a.AbsolutePosition.X + a.AbsoluteSize.X/2, a.AbsolutePosition.Y + 50, 0, false, a, 1)
    end
end)

for i,v in pairs(game:GetService("Workspace")["__GAME"]["__SpawnLocations"]:GetChildren()) do
	table.insert(Islands, v.Name)
end

for i,v in pairs(game:GetService("Workspace")["__GAME"]["__Interactions"]:GetChildren()) do
	if not table.find(Interactions, v.Name) then
		table.insert(Interactions, v.Name)
	end
end

local Fluent = loadstring(game:HttpGet("https://github.com/s-o-a-b/nexus/releases/download/nexus/nexus.txt"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/SaveManager"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/InterfaceManager"))()

local Options = Fluent.Options
SaveManager:SetLibrary(Fluent)

--[[
   premium = true
]]

local Window = Fluent:CreateWindow({
    Title = "nexus ", "",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
})

local Tabs = {
    Main = Window:AddTab({
        Title = "Main",
        Icon = "rbxassetid://10723424505"
    }),
    Misc = Window:AddTab({
        Title = "Misc",
        Icon = "rbxassetid://10709818534"
    }),
    Player = Window:AddTab({
        Title = "Player",
        Icon = "rbxassetid://10747373176"
    }),
    Weapon = Window:AddTab({ 
        Title = "Weapon",
        Icon = "rbxassetid://4335480896"
    }),
    Premium = premium == "premium" and Window:AddTab({
        Title = "Premium",
        Icon = "rbxassetid://10709819149"
    }),
    Server = Window:AddTab({
        Title = "Server",
        Icon = "rbxassetid://10734949856"
    }),
    Settings = Window:AddTab({
        Title = "Settings",
        Icon = "settings"
    }),
}

local islandData = {
    ["Starter Island"] = {
        options = {"Bandit", "Strong Bandit", "Bandit Leader"},
        mapping = CFrame.new(3388, 145, 1728),
        point = "Starter Island"
    },
    ["Jungle Island"] = {
        options = {"Monkey", "Gorilla", "King Gorilla"},
        mapping = CFrame.new(1986, 140, 598),
        point = "JunglePoint"
    },
    ["Clown Island"] = {
        options = {"Clown", "Killer Clown", "Clown King"},
        mapping = CFrame.new(3007, 150, -587),
        point = "BuggyPoint"
    },
    ["Marine Island"] = {
        options = {"Marine", "Marine Official", "Lorgan"},
        mapping = CFrame.new(4941, 145, 56),
        point = "MarinePoint"
    },
    ["Lier Island"] = {
        options = {"Cat Pirate", "Mansion Guard", "Buros"},
        mapping = CFrame.new(5557, 150, 2040),
        point = "UsoppPoint"
    },
    ["Baratie"] = {
        options = {"Don Pirate", "Perolado", "Gimbo", "Don Zig"},
        mapping = CFrame.new(1363, 180, 2680),
        point = "BaratiePoint"
    },
    ["AR Park"] = {
        options = {"Marine Soldier", "Captain Rat", "Fishman", "Chewing", "Kolobi"},
        mapping = CFrame.new(-672, 160, 631),
        point = "ArlongPoint"
    },
    ["Lulue Town"] = {
        options = {"Logue Bandit", "Bashigs", "White", "Alvarida", "Logue Marine"},
        mapping = CFrame.new(5791, 140, -3231),
        point = "LoguePoint"
    }
}

local function moveToPosition(position, duration)
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character

    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local LocalHumanoidRootPart = Character.HumanoidRootPart

        local success, err = pcall(function()
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad)
            local tween = game:GetService("TweenService"):Create(LocalHumanoidRootPart, tweenInfo, {CFrame = position})
            tween:Play()
            wait(duration)
        end)
    end 
end

local function getClosestMob(name)
    local closest, maxDist = nil, 9e9
    for _, v in pairs(workspace["__GAME"]["__Mobs"]:GetChildren()) do
        local success, result = pcall(function() 
            for _, mob in pairs(v:GetChildren()) do
                if mob:FindFirstChild("NpcConfiguration") and mob.NpcConfiguration:GetAttribute("Health") > 0 then
                    if mob.NpcConfiguration:GetAttribute("Name") == name then
                        local dist = (mob.PrimaryPart.Position - Player.Character.PrimaryPart.Position).magnitude
                        if dist < maxDist then
                            maxDist = dist
                            closest = mob
                        end
                    end
                end
            end
        end)
    end
    return closest
end

local Toggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(value)
        if value then 
            repeat
                local success, errorInfo = pcall(function()
                task.wait()  
                if not ChestTeleporting and not GettingQuest and Alive(localPlayer) then
                    local tool = Player.Backpack:FindFirstChild("Combat")
                    Player.Character.Humanoid:EquipTool(tool)
                    local enemy = getClosestMob(Options.SelectedMob.Value)
                 
                    moveToPosition(enemy.PrimaryPart.CFrame, 0.03)
                
                    local playerCombat = workspace.__GAME.__Players:FindFirstChild(Player.Name)
                    if playerCombat and playerCombat.Combat and Alive(Player) then
                        local ohTable1 = {  
                            [1] = {  
                                [1] = utf8.char(4),
                                [2] = "Combat",
                                [3] = 1,
                                [4] = false,
                                [5] = playerCombat.Combat,
                                [6] = "Melee"
                            },
                            [2] = {
                                [1] = "	",
                                [2] = enemy,
                                [3] = playerCombat.Combat
                            }
                        }
                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer(ohTable1)
                    end
                end 
            end)
            if not success then
                print("Error in AutoFarm:", errorInfo)
            end
            until not Options.AutoFarm.Value or not connection.Connected  
        end
    end
})

local Dropdownn = Tabs.Main:AddDropdown("SelectedMob", {
    Title = "Select Mob", 
    Values = {},
    Multi = false, 
    Default = false, 
    Callback = function(value)
    end
} )
local Dropdownnn = Tabs.Main:AddDropdown("SelectedWorld", {
    Title = "Select World",
    Values = {"Starter Island", "Jungle Island", "Clown Island", "Marine Island", "Lier Island", "Baratie", "AR Park", "Lulue Town"},
    Multi = false,
    Default = false,
    Callback = function(value)
        Options.SelectedWorld.Value = value
        local island = islandData[Options.SelectedWorld.Value]
        local PointOutput = island.point
        if PointOutput then
            local ohTable1 = {
                [1] = {
                    [1] = utf8.char(3),
                    [2] = "ChangeSpawnPoint",
                    [3] = PointOutput
                }
            }
            game:GetService("ReplicatedStorage").RemoteEvent:FireServer(ohTable1)
        end
        
        local output = island.mapping
        if output then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = output
        end

        Dropdownn:SetValues(island.options)
    end
})

local selectedIslandData = islandData[Options.SelectedWorld.Value]

if selectedIslandData and selectedIslandData.options then
    Dropdownn:SetValues(selectedIslandData.options)
end

local function TP(position, time)
    local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad)
    local tween = game:GetService("TweenService"):Create(humanoidRootPart, info, {CFrame = CFrame.new(position)})
    tween:Play()
end

local areaFolder = game.Workspace.__GAME.__Quests

local function populateDropdown()
    local dropdownValues = {}
    if areaFolder and areaFolder:IsA("Folder") then
        for _, item in ipairs(areaFolder:GetChildren()) do
            if item:IsA("Model") and item:FindFirstChild("HumanoidRootPart") then
                local labelText = item.Head.Icon.TextLabel.Text
                if labelText ~= "" then
                    table.insert(dropdownValues, labelText)
                end
            end
        end
    end 

    table.sort(dropdownValues, function(a, b)
        local numA = tonumber(a:match("(%d+)"))
        local numB = tonumber(b:match("(%d+)"))
        return numA < numB
    end)
    
    return dropdownValues
end


local Toggle = Tabs.Main:AddToggle("AutoQuest", {
    Title = "Auto Start Quest",
    Default = false,
    Callback = function(value)
        if value then 
            repeat task.wait()
                local questName = Options.SelectedQuest.Value or "nil"
                local questNumberStr = questName:match("(%d+)")
                local questNumber = tonumber(questNumberStr)
                local currentPosition = game:GetService("Players").LocalPlayer.PlayerGui.Quests.CurrentQuestContainer.AbsolutePosition  
            
                if currentPosition == Vector2.new(2880, 348.968) and Alive(localPlayer) and Options.SelectedQuest.Value and not ChestTeleporting then
                    GettingQuest = true 
                    for _, item in ipairs(areaFolder:GetChildren()) do
                        if item:IsA("Model") and item:FindFirstChild("HumanoidRootPart") then
                            local itemName = item.Name 
                            local itemNumber = itemName:match("(%d+)")  
            
                            itemNumber = tostring(tonumber(itemNumber)) or itemNumber
            
                            local labelText = item.Head.Icon.TextLabel.Text
                            if labelText == Options.SelectedQuest.Value then
                                moveToPosition(item.HumanoidRootPart.CFrame, 0.5) wait(1)
                                game:GetService("ReplicatedStorage").RemoteEvent:FireServer({{utf8.char(3), "GetQuest", itemNumber}})
                                break
                            end  
                        end
                    end
                    GettingQuest = false 
                end
            until not Options.AutoQuest.Value or not connection.Connected  
        end
    end
})

local Dropdown = Tabs.Main:AddDropdown("SelectedQuest", {
    Title = "Select Quest",
    Values = populateDropdown(), 
    Multi = false,
    Default = false,
    Callback = function(value)
    end
})


areaFolder.ChildAdded:Connect(function()
    Dropdown:SetValues(populateDropdown())
end)

areaFolder.ChildRemoved:Connect(function()
    Dropdown:SetValues(populateDropdown())
end)

local availableTools = {} 

local Dropdown = Tabs.Weapon:AddDropdown("SelectedWeapon", {
    Title = "Weapon",
    Values = {},  
    Multi = false,
    Default = "Select",
    Callback = function(value)
    end
})

local function updateDropdownValues()
    local dropdownValues = {}

    for toolName, _ in pairs(availableTools) do
        table.insert(dropdownValues, toolName)
    end

    local equippedTool = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if equippedTool then
        table.insert(dropdownValues, equippedTool.Name)
    end

    Dropdown:SetValues(dropdownValues)
end

game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") then
        availableTools[tool.Name] = true
        updateDropdownValues()
    end
end)

game.Players.LocalPlayer.Backpack.ChildRemoved:Connect(function(tool)
    if tool:IsA("Tool") then
        availableTools[tool.Name] = nil
        updateDropdownValues()
    end
end)

for _, tool in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
    if tool:IsA("Tool") then
        availableTools[tool.Name] = true
    end
end
updateDropdownValues()

local function equipSelectedTool()
    local selectedToolName = Options.SelectedWeapon.Value
    local player = game:GetService("Players").LocalPlayer

    if player.Character then
        local equippedTool = player.Character:FindFirstChildOfClass("Tool")
        local selectedTool = player.Backpack:FindFirstChild(selectedToolName)

        if selectedTool and (not equippedTool or equippedTool.Name ~= selectedToolName) then
            equippedTool = equippedTool or player.Character:FindFirstChildOfClass("Tool")

            if equippedTool then
                equippedTool.Parent = player.Backpack
            end

            selectedTool.Parent = player.Character
        end
    end
end

local Toggle = Tabs.Weapon:AddToggle("AutoLvWeapon", {
    Title = "Auto Lv Weapon",
    Default = false,
    Callback = function(value)
        if value then 
            repeat task.wait()
                equipSelectedTool()
                require(game:GetService("ReplicatedStorage").SharedModules.Controllers.ToolController).UseTool("Combat", Enum.UserInputState.Begin)  
            until not Options.AutoLvWeapon.Value or not connection.Connected  
        end
    end
})

local Toggle = Tabs.Weapon:AddToggle("AutoLvAll", {
    Title = "Auto Lv All Weapons",
    Default = false,
    Callback = function(value)
        if value then 
            repeat task.wait()
                local Player = game:GetService("Players").LocalPlayer
                local Humanoid = Player.Character:FindFirstChild("Humanoid")

                if Player and Player.Character and Humanoid then
                    local success, result = pcall(function() 

                        Humanoid:UnequipTools()
                        for i, Tool in pairs(Player.Backpack:GetChildren()) do
                            if Tool:IsA("Tool") and Humanoid then
                                Tool.Parent = Player.Character wait(0.1)
                                require(game:GetService("ReplicatedStorage").SharedModules.Controllers.ToolController).UseTool("Combat", Enum.UserInputState.Begin)
                                wait(.2)
                                Tool.Parent = Player.Backpack
                            end
                        end
                    end)  
                end
           
            until not Options.AutoLvAll.Value or not connection.Connected  
        end
    end
})

local Toggle = Tabs.Weapon:AddToggle("AutoSkill", {
    Title = "Auto Use Skill",
    Default = false,
    Callback = function(value)
        if value then 
            repeat task.wait()
                local virtualInput = game:GetService("VirtualInputManager")                    
                for _,r in pairs(LocalPlayer.Character:GetChildren()) do
                    if r:IsA("Tool") and r.Name ~= "Defence" then
                        for i,v in pairs({"Z", "X", "C", "V", "B"}) do
                            if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                virtualInput:SendKeyEvent(true, v, false, nil)
                                virtualInput:SendKeyEvent(false, v, false, nil)
                                task.wait(.1)
                            end
                        end
                    end
                end  
            until not Options.AutoSkill.Value or not connection.Connected  
        end
    end
})

local Toggle = Tabs.Misc:AddToggle("ServerHop", {
    Title = "Auto Chest [ Server - Hop ]",
    Default = false,
    Callback = function(value)
    end
})
spawn(function()
    while wait() do
        local SavedPosition
        
        if Options.AutoChest.Value then
            local shouldServerHop = true

            for i, v in pairs(game:GetService("Workspace"):GetChildren()) do
                if v:FindFirstChild("ChestInteract") or v.Name == "GiftModel" then
                    local character = Player.Character
                    if character then
                        SavedPosition = character:WaitForChild("HumanoidRootPart").CFrame
                        ChestTeleporting = true

                        character:WaitForChild("HumanoidRootPart").CFrame = v.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
                        wait(5)
                        fireproximityprompt(v.ChestInteract)
                        wait(0.5)
                        character:WaitForChild("HumanoidRootPart").CFrame = SavedPosition
                        wait(1)
                        shouldServerHop = false -- Don't server hop if we found a chest or gift model
                    end
                end
            end

            if shouldServerHop and Options.ServerHop.Value then
                forceServerHop()
            end
        end
        
        if SavedPosition then
            Player.Character:WaitForChild("HumanoidRootPart").CFrame = SavedPosition
        end
        
        ChestTeleporting = false
    end
end)


local Toggle = Tabs.Misc:AddToggle("AutoChest", {
    Title = "Auto Chest",
    Default = false,
    Callback = function(value)
    end
})

local Dropdown = Tabs.Misc:AddDropdown("Dropdown", {
    Title = "Teleport to Interaction",
    Values = Interactions,
    Multi = false,
    Default = "",
	Callback = function(Option)
        moveToPosition(game:GetService("Workspace")["__GAME"]["__Interactions"]:FindFirstChild(Option).PrimaryPart.CFrame, .1)
    end
})
local Dropdown = Tabs.Misc:AddDropdown("Dropdown", {
    Title = "Teleport to Island",
    Values = Islands,
    Multi = false,
    Default = "",
    Callback = function(Option)
        moveToPosition(game:GetService("Workspace")["__GAME"]["__SpawnLocations"]:FindFirstChild(Option).CFrame, .1)
    end  
})

local function setWalkSpeed(walkSpeed)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
    end
end
 
local Toggle = Tabs.Player:AddToggle("WalkSpeed", {
    Title = "Walkspeed",
    Default = false,
    Callback = function(value)
        if value then 
            repeat task.wait()  
                setWalkSpeed(Options.Walk.Value)  
            until not Options.WalkSpeed.Value or not connection.Connected
            setWalkSpeed(35)
        end
    end
})

local Slider = Tabs.Player:AddSlider("Walk", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
    end
})

local function setJumpPower(jumpPower)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = jumpPower
    end
end
 
local Toggle = Tabs.Player:AddToggle("JumpPower", {
   Title = "Jump Power",
   Default = false,
   Callback = function(value)
    if value then 
        repeat task.wait()  
            setJumpPower(Options.Jump.Value)  
        until not Options.JumpPower.Value or not connection.Connected
        setJumpPower(50)
    end
   end
})

local Slider = Tabs.Player:AddSlider("Jump", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
    end
})
local infJumpConnection

local Toggle = Tabs.Player:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(value)
        if value then 
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                localPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)  
            end)
            repeat task.wait() until not Options.InfiniteJump.Value or not connection.Connected
            infJumpConnection:Disconnect()
        end
    end 
})

local Toggle = Tabs.Server:AddToggle("AutoRejoin", {
	Title = "Auto Rejoin",
	Default = false,
	Callback = function(value)
        if value then 
            Fluent:Notify({Title = 'Auto Rejoin', Content = 'You will rejoin if you are kicked or disconnected from the game', Duration = 5 })
            repeat task.wait() 
                local lp,po,ts = game:GetService('Players').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('TeleportService')
                po.ChildAdded:connect(function(a)
                    if a.Name == 'ErrorPrompt' then
                        ts:Teleport(game.PlaceId)
                        task.wait(2)
                    end
                end)
            until Options.AutoRejoin.Value or not connection.Connected
        end
    end
})  
 
local Toggle = Tabs.Server:AddToggle("ReExecute", {
	Title = "Auto ReExecute",
	Default = false,
	Callback = function(value)
		if value then 
			repeat task.wait()
		local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
		if queueteleport then
			queueteleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/13B8B/nexus/main/loadstring"))()')
		end  
	until not Options.ReExecute.Value or not connection.Connected
end
	end 
})
Tabs.Server:AddButton({
	Title = "Rejoin-Server",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
	end
})  
Tabs.Server:AddButton({
	Title = "Server-Hop", 
	Callback = function()
	   local Http = game:GetService("HttpService")
		local TPS = game:GetService("TeleportService")
		local Api = "https://games.roblox.com/v1/games/"
		local _place,_id = game.PlaceId, game.JobId
		local _servers = Api.._place.."/servers/Public?sortOrder=Desc&limit=100"
		local function ListServers(cursor)
			local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
			return Http:JSONDecode(Raw)
		end
		local Next; repeat
			local Servers = ListServers(Next)
			for i,v in next, Servers.data do
				if v.playing < v.maxPlayers and v.id ~= _id then
					local s,r = pcall(TPS.TeleportToPlaceInstance,TPS,_place,v.id,Player)
					if s then break end
				end
			end
			Next = Servers.nextPageCursor
		until not Next
	end
})

-- Set libraries and folders
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetIgnoreIndexes({})
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FLORENCE")
SaveManager:SetFolder("FLORENCE")

-- Build interface section and load the game
InterfaceManager:BuildInterfaceSection(Tabs.Settings, Tabs.Premium)
SaveManager:Load(game.PlaceId)

-- Select the first tab in the window
Window:SelectTab(1)
