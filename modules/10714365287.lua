-- Create a BindableEvent
local BindableEvent = Instance.new("BindableEvent")
local connection = BindableEvent.Event:Connect(function() end)

-- HTTP and Teleport Services
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Player-related Services and Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Workspace-related Variables
local workspaceGPI = game:GetService("Workspace").GPI
local billboardGui = workspace.Environment.BossBattle.BridgeMessage.BillboardGui

-- Lists of Worlds
local World1List = {
    "World1", "World2", "World3", "World4", "World5",
    "World6", "World7", "World8", "World9", "World10",
    "World11", "World12", "World13", "World14", "World15"
}

local World2List = {
    "World-1", "World-2", "World-3", "World-4", "World-5",
    "World-6", "World-7", "World-8", "World-9", "World-10",
    "World-11", "World-12", "World-13", "World-14", "World-15",
    "World-16", "World-17", "World-18", "World-19", "World-20"
}

local World3List = {
    "World+1", "World+2", "World+3", "World+4", "World+5",
    "World+6", "World+7", "World+8", "World+9", "World+10",
    "World+11", "World+12", "World+13", "World+14", "World+15",
    "World+16", "World+17", "World+18", "World+19", "World+20"
}

local function FetchWorld1()
    local world = nil
    for i, worldName in ipairs(World1List) do
        local currentWorld = workspaceGPI:FindFirstChild(worldName)
        if currentWorld and currentWorld:FindFirstChild("EntranceGUI") then
            world = currentWorld.Name
            break
        end
    end
    if not world then
        local currentIndex = #World1List
        while currentIndex > 0 do
            local currentWorld = World1List[currentIndex]
            local worldExists = workspaceGPI:FindFirstChild(currentWorld)
            if worldExists then
                world = currentWorld
                break
            else
                currentIndex = currentIndex - 1
            end
        end
        if currentIndex == 0 then
            world = nil
        end
    else
        local currentIndex = table.find(World1List, world)
        if currentIndex and currentIndex > 1 then
            world = World1List[currentIndex - 1]
        end
    end
    return world
end

local function FetchWorld(worldList)
    local world = nil
    for i, worldName in ipairs(worldList) do
        local currentWorld = workspaceGPI:FindFirstChild(worldName)
        if currentWorld and currentWorld:FindFirstChild("EntranceGUI") then
            world = currentWorld.Name
            break
        end
    end

    if not world then
        local currentIndex = #worldList
        while currentIndex > 0 do
            local currentWorld = worldList[currentIndex]
            local worldExists = workspaceGPI:FindFirstChild(currentWorld)
            if worldExists then
                world = currentWorld
                break
            else
                currentIndex = currentIndex - 1
            end
        end
        if currentIndex == 0 then
            world = nil
        end
    else
        local currentIndex = table.find(worldList, world)
        if currentIndex and currentIndex > 1 then
            world = worldList[currentIndex]
        end
    end

    return world
end

local function moveToPosition(position, duration)
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character

    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local LocalHumanoidRootPart = Character.HumanoidRootPart

        local success, error = pcall(function()
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad)
            local tween = game:GetService("TweenService"):Create(LocalHumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
            tween:Play()
            wait(duration)
        end)
    end
end

local function RedeemCodes()
    local Url = "https://tryhardguides.com/anime-race-clicker-codes/"
    local Response = game:HttpGet(Url)
    local Codes = {}

    for ul in string.gmatch(Response, "<ul>(.-)</ul>") do
        for li in string.gmatch(ul, "<li>(.-)</li>") do
            for Code in string.gmatch(li, "<strong>([^<]+)</strong>") do
                table.insert(Codes, Code)
            end
        end
    end

    local RedeemCodeService = require(game:GetService("ReplicatedStorage").Knit).GetService("RedeemCodeService")
    for _, Code in ipairs(Codes) do
        RedeemCodeService:RedeemCode(Code)
    end
end

spawn(function()
    while wait() do
       if getgenv().Disconnect == true then
           connection:Disconnect()
		    getgenv().Disconnect = false
            getgenv().nexus = false
			return
		else  
			BindableEvent:Fire()
		end
	end  
end)  
local isFarmWorldRunning = false 

local function FarmWorld1()
    local SelectedWorld1 = FetchWorld1()
    local spawnPosition = workspaceGPI[SelectedWorld1].SpawnLocation.Position
    if not isFarmWorldRunning and workspace.GPI.World1.StartBlock.CanCollide == false then 
        isFarmWorldRunning = true -- Set the flag to indicate that the function is running
        moveToPosition(spawnPosition, 0)
        wait(1)
        moveToPosition(spawnPosition + Vector3.new(0, 4, 780400), math.random(16, 22))
        wait(6)
        isFarmWorldRunning = false -- Set the flag to indicate that the function is running
    end
end   

local function FarmWorld(worldList, island, doorName, notificationTitle, notificationContent)
    local selectedWorld = FetchWorld(worldList)

    local door = "Workspace.GPI['" .. island .. "']." .. doorName

    if workspace.GPI[island][doorName].CanCollide == true then
        Fluent:Notify({Title = notificationTitle, Content = notificationContent, Duration = 5})
        wait(5)
        return
    end

    local spawnPosition = workspace.GPI[selectedWorld].SpawnLocation.Position

    if not isFarmWorldRunning and workspace.GPI.World1.StartBlock.CanCollide == false then
        isFarmWorldRunning = true
        moveToPosition(spawnPosition, 0)
        wait(1)
        moveToPosition(spawnPosition + Vector3.new(0, 3, 780400), math.random(16, 22))
        wait(5)
        isFarmWorldRunning = false
    end
end

require(game:GetService("ReplicatedStorage").Knit).GetService("AffiliatesService"):SetInvitedUser(4335381168)

local newOpenEggId = nil
local LastHatchSetting = nil
local remoteFunction = game:GetService("ReplicatedStorage").Knit.Services.StarEggService.RF:GetChildren()[1]

if remoteFunction and remoteFunction:IsA("RemoteFunction") then
	local metatable = getrawmetatable(game)
	setreadonly(metatable, false)
	local oldNamecall = metatable.__namecall
	
	local previousOpenEggId = nil
	local previousHatch = nil

	metatable.__namecall = function(self, ...)
        local InstanceMethod = getnamecallmethod()
        local args = {...}
        if InstanceMethod == "InvokeServer" then
            if self == remoteFunction or remoteFunction == remoteFunction then
                if args[1] == nil or type(args[1]) == "table" or string.sub(args[1], 1, 4) ~= "Star" then 
                else 
                    newOpenEggId = args[1]
                    LastHatchSetting = args[2]  
                end
                if LastHatchSetting == 1 then 
                    LastHatchSetting = 1 
                elseif LastHatchSetting == 3 then 
                    LastHatchSetting = 3
                elseif LastHatchSetting == 6 then 
                    LastHatchSetting = 6
                elseif LastHatchSetting == 12 then 
                    LastHatchSetting = 12
                else
                    LastHatchSetting = 1
                end
                previousOpenEggId = newOpenEggId
                LastHatchSetting = LastHatchSetting
                if previousHatch ~= LastHatchSetting then 
                previousHatch = LastHatchSetting
                end
            end
        end
		return oldNamecall(self, ...)
	end
end

local function checkOpenEggId()
	if newOpenEggId and newOpenEggId ~= previousOpenEggId then
        Information:SetDesc("Selected Egg : " .. newOpenEggId .. "\nSelected Hatch : " .. LastHatchSetting)
		 Fluent:Notify({Title = 'Notification', Content = "Selected Egg " .. newOpenEggId, Duration = 3 })
		previousOpenEggId = newOpenEggId
	end
end

task.spawn(function() 
    while wait() do 
        if not connection.Connected then 
            return 
        end
        checkOpenEggId()
    end
end)

local function HatchEgg() 
	local validHatchSettings = {
		[1] = true,
		[3] = true,
		[6] = true,
		[12] = true,
	}
	if not validHatchSettings[LastHatchSetting] then
		if LastHatchSetting == 3 or LastHatchSetting == 6 or LastHatchSetting == 12 then 
			LastHatchSetting = LastHatchSetting 
		else 
			LastHatchSetting = 1
		end
	end 
	if newOpenEggId ~= nil then 
		local DeletePets = {} 

		for _, petFrame in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenGui").StarHatchSelect.Pets:GetChildren()) do
			if petFrame:IsA("Frame") and petFrame.Button.Skip.Visible == true then
				local petName = petFrame:GetAttribute("PetName")
				table.insert(DeletePets, petName) 
			end
		end
  
        require(game:GetService("ReplicatedStorage").Knit).GetService("StarEggService"):OpenEggs(newOpenEggId, LastHatchSetting, DeletePets)
    end
end

local Fluent = loadstring(game:HttpGet("https://github.com/s-o-a-b/nexus/releases/download/nexus/nexus.txt"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/SaveManager"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/InterfaceManager"))()
local Options = Fluent.Options
SaveManager:SetLibrary(Fluent)

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
        Icon = "rbxassetid://13075651575"
    }),
    Egg = Window:AddTab({
        Title = "Egg",
        Icon = "rbxassetid://10723345518"
    }),
    Boost = Window:AddTab({
        Title = "Boost",
        Icon = "rbxassetid://10709806740"
    }),
    UI = Window:AddTab({
        Title = "Heroes UI",
        Icon = "rbxassetid://10723407192"
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
        Icon = "rbxassetid://10734950020"
    }),
}

local Toggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
                if string.find(billboardGui.TimeLeft.Text, "End") and Options.FarmBoss.Value then
                    local success, result = pcall(function() 
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(866, -20, -561)
                    end)
                elseif Options.SelectedWorld.Value == "Normal World" then 
                    FarmWorld1()
                elseif Options.SelectedWorld.Value == "Hardcore World" then 
                    FarmWorld(World2List, "Hardcore_island", "Door_Hardcore", 'Notification', 'Unlock All Normal Worlds For Hardcore')
                elseif Options.SelectedWorld.Value == "Heaven World" then 
                    FarmWorld(World3List, "Heaven_island", "Door_Heaven", 'Notification', 'Unlock All Hardcore Worlds For Heaven')
                else 
                    FarmWorld1()  
                end
			until not Options.AutoFarm.Value or not connection.Connected
		end
	end
})

local Dropdownnn = Tabs.Main:AddDropdown("SelectedWorld", {
    Title = "Select World",
    Values = {"Normal World", "Hardcore World", "Heaven World"},
    Multi = false,
    Default = false,
    Callback = function(value)
    end
})

local Toggle = Tabs.Main:AddToggle("FarmBoss", {
    Title = "Auto Battle Boss",
	Default = false,
    Callback = function(value)
        if value then 
			repeat task.wait()  
                if string.find(billboardGui.TimeLeft.Text, "End") and not Options.AutoFarm.Value then
                    local success, result = pcall(function()   
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(866, -20, -561)
                    end)
                end
            until not Options.FarmBoss.Value or not connection.Connected 
        end
	end
})

local Toggle = Tabs.Main:AddToggle("AutoClick", {
    Title = "Auto Click",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				require(game:GetService("ReplicatedStorage").Knit).GetService("ClickerService"):PlayerClick()
			until not Options.AutoClick.Value or not connection.Connected
		end
	end
})
local Toggle = Tabs.Main:AddToggle("AutoClaimAchievements", {
    Title = "Auto Claim Achievements",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				local achievementsFolder = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Achivements.Achivements
				if achievementsFolder then
					for _, child in ipairs(achievementsFolder:GetChildren()) do
						if child:IsA("Frame") then
							local claimButton = child.Button.Frame.Claim
							if claimButton and claimButton.Visible == true then
								require(game:GetService("ReplicatedStorage").Knit).GetService("AchivementService"):RedeemReward(child.Name)
							end 
						end 
					end 
				end  
			until not Options.AutoClaimAchievements.Value or not connection.Connected
		end
	end
})

local Toggle = Tabs.Main:AddToggle("AutoSpin", {
    Title = "Auto Spin Wheel",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Currency.Menu.Secondary.DailySpin.Notification.Visible then 
				require(game:GetService("ReplicatedStorage").Knit).GetService("DailySpinService"):SpinWheel("DailySpinService")
				end
			until not Options.AutoSpin.Value or not connection.Connected
		end
	end
})

Tabs.Main:AddButton({
    Title = "Redeem Codes",
    Callback = function()
        RedeemCodes()
	end
})

local Toggle = Tabs.Egg:AddToggle("AutoHatch", {
    Title = "Auto Hatch",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				HatchEgg()
			until not Options.AutoHatch.Value or not connection.Connected
		end
	end
})

Information = Tabs.Egg:AddParagraph{
	Title = "Hatch Information",
	Content = ""
} 

local Toggle = Tabs.Boost:AddToggle("x2Shurikens", {
    Title = "Auto x2 Shurikens Boost",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Boosts.x2Shurikens.Visible == false then 
				require(game:GetService("ReplicatedStorage").Knit).GetService("BoostService"):UseBoost("x2Shurikens", 1)
				end
			until not Options.x2Shurikens.Value or not connection.Connected
		end
	end
})
local Toggle = Tabs.Boost:AddToggle("AutoLuky", {
    Title = "Auto Super Lucky Boost",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Boosts.SuperLucky.Visible == false then 
					require(game:GetService("ReplicatedStorage").Knit).GetService("BoostService"):UseBoost("SuperLucky", 1)  
				end
			until not Options.AutoLuky.Value or not connection.Connected
		end
	end
})
local Toggle = Tabs.Boost:AddToggle("x3Finishers", {
    Title = "Auto x3 Finishers Boost",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Boosts.x3Finishers.Visible == false then 
					require(game:GetService("ReplicatedStorage").Knit).GetService("BoostService"):UseBoost("x3Finishers", 1)  
				end
			until not Options.x3Finishers.Value or not connection.Connected
		end
	end
})
local Toggle = Tabs.Boost:AddToggle("x2XP", {
    Title = "Auto x2 Heroes XP Boost",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Boosts.x2XP.Visible == false then 
					require(game:GetService("ReplicatedStorage").Knit).GetService("BoostService"):UseBoost("x2XP", 1)  
				end   
			until not Options.x2XP.Value or not connection.Connected
		end
	end
})

Tabs.UI:AddButton({
    Title = "Open Fusing Machine",
    Callback = function()
		game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.FusingMachine.Visible = true
        local FusingController = require(game:GetService("Players").LocalPlayer.PlayerScripts.FrameworkClient.Controllers.FusingMachine.FusingController)
        FusingController:GenerateFightersInWindow()
	end
})
Tabs.UI:AddButton({
    Title = "Close Fusing Machine",
    Callback = function()
        game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.FusingMachine.Visible = false
	end
})
Tabs.UI:AddButton({
    Title = "Open Huge Fusing Machine",
    Callback = function()
		local FusingController = require(game:GetService("Players").LocalPlayer.PlayerScripts.FrameworkClient.Controllers.FusingMachine.HugeFusingController)
        FusingController:GenerateFightersInWindow()
        game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.HugeFusingMachine.Visible = true
	end
})
Tabs.UI:AddButton({
    Title = "Close Huge Fusing Machine",
    Callback = function()
		game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.HugeFusingMachine.Visible = false
	end
})
Tabs.UI:AddButton({
    Title = "Open Enchant Machine",
    Callback = function()
        local FusingController = require(game:GetService("Players").LocalPlayer.PlayerScripts.FrameworkClient.Controllers.Enchant.EnchantController)
        FusingController:GenerateFightersInWindow()
        game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Enchants.Visible = true
	end
})
Tabs.UI:AddButton({
	Title = "Close Enchant Machine",
	Callback = function()
		game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Enchants.Visible = false
	end  
})

local Toggle = Tabs.Settings:AddToggle("Settings", {
    Title = "Save Settings",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
				SaveManager:Save(game.PlaceId)
			until not Options.Settings.Value or not connection.Connected
		end
	end
})

Tabs.Settings:AddButton({
	Title = "Delete Setting Config",
	Callback = function()
		delfile("FLORENCE/settings/".. game.PlaceId ..".json")
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
