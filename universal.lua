local HttpService = game:GetService("HttpService")

local Fluent = loadstring(game:HttpGet("https://github.com/s-o-a-b/nexus/releases/download/nexus/nexus.txt"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/SaveManager"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/assets/InterfaceManager"))()

local Options = Fluent.Options
SaveManager:SetLibrary(Fluent)

--[[
   premium = true
]]

local Window = Fluent:CreateWindow({
    Title = "iksm - universal ", "",
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
    Settings = Window:AddTab({
        Title = "Settings",
        Icon = "settings"
    }),
        Premium = premium == "premium" and Window:AddTab({
        Title = "Premium",
        Icon = "rbxassetid://10709819149"
    }),

}

Tabs.Main:AddParagraph({
    Title = "iksm Universal",
    Content = "Welcome to Nexus Universal!\n\nWe're excited to introduce the upcoming Universal script to enhance your experience. Currently in development, this script is designed to bring you a host of new features and improvements.\n\nOur dedicated team is working diligently to make this script a reality. While it's not ready just yet, we're making great progress.\n\nStay tuned for updates, and thank you for your patience and support! https://discord.gg/KHKu84ZyhD"
})

local Toggle = Tabs.Settings:AddToggle("Toggle", {
    Title = "Auto Save Settings",
    Default = getgenv().settings.AutoSave,
    Callback = function(value)
        getgenv().settings.AutoSave = value
        writefile(fileName, HttpService:JSONEncode(getgenv().settings))
    end
})

local Toggle = Tabs.Settings:AddToggle("Toggle", {
    Title = "Auto ReExecute",
    Default = getgenv().settings.AutoExecute,
    Callback = function(value)
    getgenv().settings.AutoExecute = value
     if getgenv().settings.AutoExecute then
            local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
            if queueteleport then
                queueteleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/13B8B/nexus/main/loadstring"))()')
            end
        end
    end
})

local Toggle = Tabs.Settings:AddToggle("Toggle", {
   Title = "Auto Rejoin",
   Default = getgenv().settings.AutoRejoin,
   Callback = function(value)
      getgenv().settings.AutoRejoin = value
      if getgenv().settings.AutoRejoin then
          Fluent:Notify({Title = 'Auto Rejoin', Content = 'You will rejoin if you are kicked or disconnected from the game', Duration = 5 })
          repeat task.wait() until game.CoreGui:FindFirstChild('RobloxPromptGui')
          local lp,po,ts = game:GetService('Players').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('TeleportService')
          po.ChildAdded:connect(function(a)
              if a.Name == 'ErrorPrompt' then
                  while true do
                      ts:Teleport(game.PlaceId)
                      task.wait(2)
                  end
              end
          end)
      end
  end
})

Tabs.Settings:AddButton({
    Title = "Rejoin-Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

Tabs.Settings:AddButton({
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
