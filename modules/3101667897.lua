-- Services
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local leaderstats = player:FindFirstChild("leaderstats")

-- Create a BindableEvent
local BindableEvent = Instance.new("BindableEvent")
local connection = BindableEvent.Event:Connect(function() end)

-- Renaming race maps in the workspace
local success, result = pcall(function() 
    Workspace.raceMaps.Magma.Name = "Magma Race"
    Workspace.raceMaps.Desert.Name = "Desert Race"
    Workspace.raceMaps.Grassland.Name = "Grass Race"
end)

-- Define teleport targets
local targets = {
    {position = Vector3.new(-9684.84, 55.6854, 3093.3), name = "City"},
    {position = Vector3.new(-13097, 213.621, 5913.35), name = "Legends Highway"},
    {position = Vector3.new(-11053.1, 213.621, 4904.36), name = "Magma City"},
}

-- Check for areaCirclesFolder and update names
local areaCirclesFolder = Workspace:FindFirstChild("areaCircles")
if areaCirclesFolder then
    for _, areaCircle in ipairs(areaCirclesFolder:GetDescendants()) do
        if areaCircle.Name == "areaCircle" then
            local TeleportPart = areaCircle:FindFirstChild("circleOuter")
            if TeleportPart then
                for _, target in ipairs(targets) do
                    local distance = (TeleportPart.Position - target.position).Magnitude
                    if distance <= 50 then
                        TeleportPart.Parent.Name = target.name
                    end
                end
            end
        end
    end
end

-- Function to format large numbers
local function formatNumber(number)
    if number >= 1e12 then
        return math.floor(number / 1e11) / 10 .. "T"
    elseif number >= 1e9 then
        return math.floor(number / 1e8) / 10 .. "B"
    elseif number >= 1e6 then
        return math.floor(number / 1e5) / 10 .. "M"
    elseif number >= 1e3 then
        return math.floor(number / 1e2) / 10 .. "K"
    else
        return tostring(number)
    end
end

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

local Fluent = loadstring(game:HttpGet("https://github.com/s-o-a-b/nexus/releases/download/nexus/nexus.txt"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/SaveManager"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/InterfaceManager"))()

--[[
	premium = true
]]

local Options = Fluent.Options
SaveManager:SetLibrary(Fluent)

local Window = Fluent:CreateWindow({
    Title = "iksm ", "",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
})

local Tabs = {
    Main = Window:AddTab({
        Title = "Main",
        Icon = "rbxassetid://10734975692"
    }),
    Egg = Window:AddTab({
        Title = "Egg",
        Icon = "rbxassetid://10723345518"
    }),
    Webhook = Window:AddTab({
        Title = "Webhook",
        Icon = "rbxassetid://10734943902"
    }),
    Server = Window:AddTab({
        Title = "Server",
        Icon = "rbxassetid://10734949856"
    }),
    Settings = Window:AddTab({
        Title = "Settings",
        Icon = "rbxassetid://10734950020"
    }),
    Premium = premium == "premium" and Window:AddTab({
        Title = "Premium",
        Icon = "rbxassetid://10709819149"
    }),
}
local function createAutoFarmToggle(name, area, levelReq)
	Tabs.Main:AddToggle(area, {
		Title = name,
		CurrentValue = false,
		Callback = function(Value)
			if Value then 
				repeat
					task.wait()
					if Options[area].Value then
						local player = game:GetService("Players").LocalPlayer
						if player.leaderstats.Rebirths.Value < levelReq then
							Fluent:Notify({ Title = 'Notification', Content = "You need at least " .. levelReq .. " rebirths to auto farm " .. name, Duration = 5 })
							repeat task.wait() until not Options[area].Value or player.leaderstats.Rebirths.Value > levelReq
						else
							if game:GetService("Players").LocalPlayer.currentMap.Value ~= area then
								local currentMap = game:GetService("Players").LocalPlayer.currentMap.Value
								if currentMap ~= "Magma Race" and currentMap ~= "Grass Race" and currentMap ~= "Desert Race" then
									game:GetService("ReplicatedStorage").rEvents.areaTravelRemote:InvokeServer("travelToArea", workspace.areaCircles[area])
								end								
							end
							if Options.AutoGems.Value then
								spawn(function()
									for i = 1,3 do task.wait()
										game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Gem", area)
										game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Red Orb", area)
										game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Red Orb", area)
									end 
								end)
							end  
							if not Options.AutoGems.Value then 
								spawn(function()
									for i = 1,3 do task.wait()
										game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Red Orb", area)
										game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Red Orb", area)
									end
								end)               
							end  
						end
					end
				until not Options[area].Value or not connection.Connected
			end
		end,
	})
end

createAutoFarmToggle("Auto Farm City", "City", 0)
createAutoFarmToggle("Auto Farm Magma City", "Magma City", 1)
createAutoFarmToggle("Auto Farm Legends Highway", "Legends Highway", 10)

local Toggle = Tabs.Main:AddToggle("AutoGems", {
    Title = "Auto Farm Gems",
	Default = false,
    Callback = function(value)
	end
})

local Toggle = Tabs.Main:AddToggle("AutoRebirth", {
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(value)
        if value then
            repeat task.wait()
                local playerGui = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if playerGui and playerGui:FindFirstChild("gameGui") and playerGui.gameGui.statsFrame.levelLabel.maxLabel.Visible then
                    game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest")
                end
            until not Options.AutoRebirth.Value or not connection.Connected
        end
    end
})

local Toggle = Tabs.Main:AddToggle("AutoHoop", {
    Title = "Auto Hoops",
	Default = false,
    Callback = function(value)
		if value then 
			repeat wait(1)  
				for i,v in pairs(game.Workspace.Hoops:GetChildren()) do
					if v.Name == 'Hoop' then
						firetouchinterest(game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"), v, 0)
						firetouchinterest(game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"), v, 1)
					end
				end
			until not Options.AutoHoop.Value or not connection.Connected
		end  
	end
})

local Toggle = Tabs.Main:AddToggle("AutoRace", {
    Title = "Auto Race",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait(1)  
				local success, errorInfo = pcall(function()
				if game:GetService("Players").LocalPlayer.PlayerGui.gameGui.raceJoinLabel.Visible == true then 
					game:GetService("ReplicatedStorage").rEvents.raceEvent:FireServer("joinRace") wait(2)  
					local Players = game:GetService("Players")
					local player = Players.LocalPlayer
					local currentMap = player.currentMap.Value
					repeat task.wait(.1) print("POOP") until workspace.raceMaps[currentMap].boundaryParts.boundaryPart.CanCollide == false
					for _,v in pairs(game:GetService("Workspace").raceMaps:GetDescendants()) do
						if v:IsA("TouchTransmitter") and v.Parent.Name == "finishPart" then wait(0.5)
							player.Character.HumanoidRootPart.CFrame = CFrame.new(v.Parent.Position)  * CFrame.new(-40, -20, 0) 
							break;
						end 
					end
				end  
			end)
			until not Options.AutoRace.Value or not connection.Connected
		end  
	end
})

local Toggle = Tabs.Egg:AddToggle("AutoHatch", {
    Title = "Auto Hatch",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait()  
		        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", Options.SelectCrystal.Value)
			until not Options.AutoHatch.Value or not connection.Connected
		end  
	end
})

local Dropdownnn = Tabs.Egg:AddDropdown("SelectCrystal", {
    Title = "Select Crystal",
    Values = {"Red Crystal","Blue Crystal","Purple Crystal","Yellow Crystal","Lightning Crystal","Snow Crystal","Inferno Crystal","Lava Crystal","Electro Legends Crystal"},
    Multi = false,
    Default = false,
    Callback = function(value)
    end
})

local selectedValues = {} 

local MultiDropdown = Tabs.Egg:AddDropdown("MultiDropdown", {
    Title = "Delete Rarity",
    Values = {"Basic", "Advanced", "Rare", "Epic", "Unique", "Omega"},
    Multi = true,
    Default = {},
    Callback = function(value)
        selectedValues = {}  -- Clear the selected values table
        for val, State in next, value do
            if State then
                table.insert(selectedValues, val)
            end
        end
    end
})

local Toggle = Tabs.Egg:AddToggle("AutoDelete", {
    Title = "Auto Delete Pets",
    Default = false,
    Callback = function(value)
        if value then 
            repeat
                wait(1)  
                for _, selectedValue in ipairs(selectedValues) do
                    for _, pet in ipairs(game:GetService("Players").LocalPlayer.petsFolder[selectedValue]:GetChildren()) do
                        if pet.Name ~= "Ultimate Overdrive Bunny" then 
                            game:GetService("ReplicatedStorage").rEvents.sellPetEvent:FireServer("sellPet", pet)
                        end
                    end  
                end
            until not Options.AutoDelete.Value or not connection.Connected
        end  
    end
})


local Toggle = Tabs.Egg:AddToggle("AutoDeleteTrails", {
    Title = "Auto Delete Bad Trails",
    Default = false,
    Callback = function(value)
        if value then 
            repeat
                wait(1)  
                for _, selectedValue in ipairs(selectedValues) do
                    if selectedValue == "Omega" then 
                        continue -- Skip "Omega" and proceed to the next selectedValue
                    end
                    for _, pet in ipairs(game:GetService("Players").LocalPlayer.trailsFolder[selectedValue]:GetChildren()) do
                        game:GetService("ReplicatedStorage").rEvents.sellTrailEvent:FireServer("sellTrail", pet)
                    end  
                end
            until not Options.AutoDeleteTrails.Value or not connection.Connected
        end  
    end
})



local Toggle = Tabs.Egg:AddToggle("AutoEvolve", {
    Title = "Auto Evolve Pets",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait(3)  
				for _, child in ipairs(game:GetService("ReplicatedStorage").cPetShopFolder:GetChildren()) do
					game:GetService("ReplicatedStorage").rEvents.petEvolveEvent:FireServer("evolvePet", child.Name)
				end   
			until not Options.AutoEvolve.Value or not connection.Connected
		end  
	end
})


local Input = Tabs.Webhook:AddInput("Webhook", {
	Title = "Webhook",
	Default = "",
	Placeholder = "Webhook Url",
	Numeric = false, -- Only allows numbers
	Finished = false, -- Only calls callback when you press enter
	Callback = function(Value)
		print("Input changed:", Value)
	end
})

local function send(description)
    local data = {
        ["embeds"] = {
            {
                ["title"] = "Legends Of Speed",
                ["description"] = description,
            }
        }
    }
    local newdata = HttpService:JSONEncode(data)

    local headers = {
        ["content-type"] = "application/json"
    }

    local request = http_request or request or HttpPost or syn.request
    local abcdef = { Url = Options.Webhook.Value, Body = newdata, Method = "POST", Headers = headers }

    local success, result = pcall(function()
        request(abcdef)
    end)

    if success then
        print("Request successful!")
        getgenv().lastExecutionTime = tick()
    else
        warn("An error occurred:", result)
    end
end

local Slider = Tabs.Webhook:AddSlider("WebhookCooldown", {
	Title = "Webhook Cooldown",
	Default = 60,
	Min = 10,
	Max = 60,
	Rounding = 1,
	Callback = function(Value)
	end
})

local Toggle = Tabs.Webhook:AddToggle("StepsWebhook", {
    Title = "Steps Webhook",
    Default = false,
    Callback = function(value)
        if value then
			repeat task.wait()  
				local success, errorInfo = pcall(function()
					if leaderstats and leaderstats:FindFirstChild("Steps") then
						local time = tonumber(Options.WebhookCooldown.Value)

						if time >= 0 then
							time = math.floor(time + 0.5) 
							Options.WebhookCooldown.Value = math.ceil(time - 0.5) 
						else
							time = math.ceil(time - 0.5) 
							Options.WebhookCooldown.Value = math.ceil(time - 0.5) 
						end  

						local stepsStart = leaderstats.Steps.Value
						wait(time)
						local stepsEnd = leaderstats.Steps.Value 
						
						local stepsEarned = stepsEnd - stepsStart 
						local formattedSteps = formatNumber(stepsEarned)
						if Options.StepsWebhook.Value then 
							send("Steps Made : `" .. formattedSteps .. "`\nMade in : `" .. time ..  " seconds`")
							wait(1)
						end
    
					end
				end)
			until not Options.StepsWebhook.Value or not connection.Connected
		end
	end
})

local Toggle = Tabs.Webhook:AddToggle("GemsWebhook", {
    Title = "Gems Webhook",
    Default = false,
    Callback = function(value)
        if value then
			repeat task.wait()  
				local success, errorInfo = pcall(function()
					if leaderstats and leaderstats:FindFirstChild("Steps") then
						local time = tonumber(Options.WebhookCooldown.Value)

						if time >= 0 then
							time = math.floor(time + 0.5) 
							Options.WebhookCooldown.Value = math.ceil(time - 0.5) 
						else
							time = math.ceil(time - 0.5) 
							Options.WebhookCooldown.Value = math.ceil(time - 0.5) 
						end  

						local GemStart = game:GetService("Players").LocalPlayer.Gems.Value
						wait(time)
						local GemsEnd = game:GetService("Players").LocalPlayer.Gems.Value
						
						local GemsEarned = GemsEnd - GemStart 
						local formattedGems = formatNumber(GemsEarned)
						if Options.GemsWebhook.Value then 
							send("Gems Made : `" .. formattedGems .. "`\nMade in : `" .. time ..  " seconds`")
							wait(1)
						end
    
					end
				end)
			until not Options.GemsWebhook.Value or not connection.Connected
		end
	end
})


local Toggle = Tabs.Webhook:AddToggle("RebirthWebhook", {
    Title = "Rebirth Webhook",
    Default = false,
    Callback = function(value)
        if value then
            repeat
                task.wait()  
                local success, errorInfo = pcall(function()
                    local leaderstats = game.Players.LocalPlayer:FindFirstChild("leaderstats")
                    
                    if leaderstats then
                        local Rebirths = leaderstats:FindFirstChild("Rebirths")
                        
                        if Rebirths then
                            local lastValue = Rebirths.Value
                            repeat task.wait() until Rebirths.Value ~= lastValue or not Options.RebirthWebhook.Value or not connection.Connected
                            if Options.RebirthWebhook.Value and Rebirths.Value ~= lastValue then
                                lastValue = Rebirths.Value
								send("Rebirth Value Updated : `" .. lastValue .. "`")  -- Missing closing backtick
							end
						else
							warn("Rebirths not found in leaderstats")
						end
                    else
                        warn("leaderstats not found for the player")
                    end
                end)
            until not Options.RebirthWebhook.Value or not connection.Connected
        end
    end
})


local Toggle = Tabs.Settings:AddToggle("Settings", {
    Title = "Save Settings",
	Default = false,
    Callback = function(value)
		if value then 
			repeat task.wait(.5)  
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
