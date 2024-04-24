local StrToNumber = tonumber; local Byte = string.byte; local Char = string.char; local Sub = string.sub; local Subg = string.gsub; local Rep = string.rep; local Concat = table.concat; local Insert = table.insert; local LDExp = math.ldexp; local GetFEnv = getfenv or function() return _ENV; end; local Setmetatable = setmetatable; local PCall = pcall; local Select = select; local Unpack = unpack or table.unpack; local ToNumber = tonumber; local function VMCall(ByteString, vmenv, ...) local DIP = 1; local repeatNext; ByteString = Subg(Sub(ByteString, 5), "..", function(byte) if (Byte(byte, 2) == 79) then repeatNext = StrToNumber(Sub(byte, 1, 1)); return ""; else local a = Char(StrToNumber(byte, 16)); if repeatNext then local b = Rep(a, repeatNext); repeatNext = nil; return b; else return a; end end end); local function gBit(Bit, Start, End) if End then local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1)); return Res - (Res % 1); else local Plc = 2 ^ (Start - 1); return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0; end end local function gBits8() local a = Byte(ByteString, DIP, DIP); DIP = DIP + 1; return a; end local function gBits16() local a, b = Byte(ByteString, DIP, DIP + 2); DIP = DIP + 2; return (b * 256) + a; end local function gBits32() local a, b, c, d = Byte(ByteString, DIP, DIP + 3); DIP = DIP + 4; return (d * 16777216) + (c * 65536) + (b * 256) + a; end local function gFloat() local Left = gBits32(); local Right = gBits32(); local IsNormal = 1; local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left; local Exponent = gBit(Right, 21, 31); local Sign = ((gBit(Right, 32) == 1) and -1) or 1; if (Exponent == 0) then if (Mantissa == 0) then return Sign * 0; else Exponent = 1; IsNormal = 0; end elseif (Exponent == 2047) then return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN); end return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52))); end local function gString(Len) local Str; if not Len then Len = gBits32(); if (Len == 0) then return ""; end end Str = Sub(ByteString, DIP, (DIP + Len) - 1); DIP = DIP + Len; local FStr = {}; for Idx = 1, #Str do FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx))); end return Concat(FStr); end local gInt = gBits32; local function _R(...) return {...}, Select("#", ...); end local function Deserialize() local Instrs = {}; local Functions = {}; local Lines = {}; local Chunk = {Instrs,Functions,nil,Lines}; local ConstCount = gBits32(); local Consts = {}; for Idx = 1, ConstCount do local Type = gBits8(); local Cons; if (Type == 1) then Cons = gBits8() ~= 0; elseif (Type == 2) then Cons = gFloat(); elseif (Type == 3) then Cons = gString(); end Consts[Idx] = Cons; end Chunk[3] = gBits8(); for Idx = 1, gBits32() do local Descriptor = gBits8(); if (gBit(Descriptor, 1, 1) == 0) then local Type = gBit(Descriptor, 2, 3); local Mask = gBit(Descriptor, 4, 6); local Inst = {gBits16(),gBits16(),nil,nil}; if (Type == 0) then Inst[3] = gBits16(); Inst[4] = gBits16(); elseif (Type == 1) then Inst[3] = gBits32(); elseif (Type == 2) then Inst[3] = gBits32() - (2 ^ 16); elseif (Type == 3) then Inst[3] = gBits32() - (2 ^ 16); Inst[4] = gBits16(); end if (gBit(Mask, 1, 1) == 1) then Inst[2] = Consts[Inst[2]]; end if (gBit(Mask, 2, 2) == 1) then Inst[3] = Consts[Inst[3]]; end if (gBit(Mask, 3, 3) == 1) then Inst[4] = Consts[Inst[4]]; end Instrs[Idx] = Inst; end end for Idx = 1, gBits32() do Functions[Idx - 1] = Deserialize(); end return Chunk; end local function Wrap(Chunk, Upvalues, Env) local Instr = Chunk[1]; local Proto = Chunk[2]; local Params = Chunk[3]; return function(...) local Instr = Instr; local Proto = Proto; local Params = Params; local _R = _R; local VIP = 1; local Top = -1; local Vararg = {}; local Args = {...}; local PCount = Select("#", ...) - 1; local Lupvals = {}; local Stk = {}; for Idx = 0, PCount do if (Idx >= Params) then Vararg[Idx - Params] = Args[Idx + 1]; else Stk[Idx] = Args[Idx + 1]; end end local Varargsz = (PCount - Params) + 1; local Inst; local Enum; while true do Inst = Instr[VIP]; Enum = Inst[1]; if (Enum <= 14) then if (Enum <= 6) then if (Enum <= 2) then if (Enum <= 0) then Stk[Inst[2]] = Env[Inst[3]]; elseif (Enum > 1) then Stk[Inst[2]](); else Stk[Inst[2]][Inst[3]] = Inst[4]; end elseif (Enum <= 4) then if (Enum == 3) then local A = Inst[2]; local Results, Limit = _R(Stk[A](Stk[A + 1])); Top = (Limit + A) - 1; local Edx = 0; for Idx = A, Top do Edx = Edx + 1; Stk[Idx] = Results[Edx]; end else Stk[Inst[2]] = Inst[3]; end elseif (Enum > 5) then Stk[Inst[2]][Inst[3]] = Inst[4]; else do return; end end elseif (Enum <= 10) then if (Enum <= 8) then if (Enum > 7) then local A = Inst[2]; Stk[A](Stk[A + 1]); else local A = Inst[2]; local T = Stk[A]; for Idx = A + 1, Top do Insert(T, Stk[Idx]); end end elseif (Enum > 9) then local A = Inst[2]; Stk[A] = Stk[A](Unpack(Stk, A + 1, Top)); else local A = Inst[2]; local T = Stk[A]; for Idx = A + 1, Top do Insert(T, Stk[Idx]); end end elseif (Enum <= 12) then if (Enum == 11) then local A = Inst[2]; Stk[A](Stk[A + 1]); else local A = Inst[2]; Stk[A](Unpack(Stk, A + 1, Inst[3])); end elseif (Enum > 13) then Stk[Inst[2]](); else do return; end end elseif (Enum <= 21) then if (Enum <= 17) then if (Enum <= 15) then local A = Inst[2]; Stk[A](Unpack(Stk, A + 1, Inst[3])); elseif (Enum > 16) then Stk[Inst[2]] = Inst[3]; else local A = Inst[2]; Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3])); end elseif (Enum <= 19) then if (Enum > 18) then Stk[Inst[2]] = Stk[Inst[3]][Inst[4]]; else local A = Inst[2]; Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3])); end elseif (Enum == 20) then Stk[Inst[2]] = Stk[Inst[3]][Inst[4]]; else Stk[Inst[2]] = {}; end elseif (Enum <= 25) then if (Enum <= 23) then if (Enum == 22) then local A = Inst[2]; local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3]))); Top = (Limit + A) - 1; local Edx = 0; for Idx = A, Top do Edx = Edx + 1; Stk[Idx] = Results[Edx]; end else local A = Inst[2]; Stk[A] = Stk[A](Unpack(Stk, A + 1, Top)); end elseif (Enum > 24) then local A = Inst[2]; local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3]))); Top = (Limit + A) - 1; local Edx = 0; for Idx = A, Top do Edx = Edx + 1; Stk[Idx] = Results[Edx]; end else Stk[Inst[2]] = Env[Inst[3]]; end elseif (Enum <= 27) then if (Enum > 26) then local A = Inst[2]; local B = Stk[Inst[3]]; Stk[A + 1] = B; Stk[A] = B[Inst[4]]; else local A = Inst[2]; local B = Stk[Inst[3]]; Stk[A + 1] = B; Stk[A] = B[Inst[4]]; end elseif (Enum == 28) then Stk[Inst[2]] = {}; else local A = Inst[2]; local Results, Limit = _R(Stk[A](Stk[A + 1])); Top = (Limit + A) - 1; local Edx = 0; for Idx = A, Top do Edx = Edx + 1; Stk[Idx] = Results[Edx]; end end VIP = VIP + 1; end end; end return Wrap(Deserialize(), {}, vmenv)(...); end local b=Instance.new("\x42\x69\x6E\x64\x61\x62\x6C\x65\x45\x76\x65\x6E\x74") local l=b.Event:Connect(function()end) local _=game:GetService("\x48\x74\x74\x70\x53\x65\x72\x76\x69\x63\x65") local _=game:GetService("\x54\x65\x6C\x65\x70\x6F\x72\x74\x53\x65\x72\x76\x69\x63\x65") local _=game:GetService("\x55\x73\x65\x72\x49\x6E\x70\x75\x74\x53\x65\x72\x76\x69\x63\x65") local a=game:GetService("\x52\x65\x70\x6C\x69\x63\x61\x74\x65\x64\x53\x74\x6F\x72\x61\x67\x65") local _=game:GetService("\x57\x6F\x72\x6B\x73\x70\x61\x63\x65").Balls local d=game:GetService("\x50\x6C\x61\x79\x65\x72\x73") local j=d.LocalPlayer local _=game.Stats local _ local _=j.Character:FindFirstChild("\x48\x75\x6D\x61\x6E\x6F\x69\x64\x52\x6F\x6F\x74\x50\x61\x72\x74") local function _(b,c)local _=d.LocalPlayer local _=_.Character if _ and _:FindFirstChild("\x48\x75\x6D\x61\x6E\x6F\x69\x64\x52\x6F\x6F\x74\x50\x61\x72\x74")then local a=_.HumanoidRootPart local _,_=pcall(function()local _=TweenInfo.new(c,Enum.EasingStyle.Quad) local _=game:GetService("\x54\x77\x65\x65\x6E\x53\x65\x72\x76\x69\x63\x65"):Create(a,_,{CFrame=CFrame.new(b)}) _:Play() wait(c)end)end end local function c()local _="\x68\x74\x74\x70\x73\x3A\x2F\x2F\x74\x72\x79\x68\x61\x72\x64\x67\x75\x69\x64\x65\x73\x2E\x63\x6F\x6D\x2F\x62\x6C\x61\x64\x65\x2D\x62\x61\x6C\x6C\x2D\x63\x6F\x64\x65\x73\x2F" local _=game:HttpGet(_) local a={} for _ in string.gmatch(_,"\x3C\x75\x6C\x3E\x28\x2E\x2D\x29\x3C\x2F\x75\x6C\x3E")do for _ in string.gmatch(_,"\x3C\x6C\x69\x3E\x28\x2E\x2D\x29\x3C\x2F\x6C\x69\x3E")do for _ in string.gmatch(_,"\x3C\x73\x74\x72\x6F\x6E\x67\x3E\x28\x5B\x5E\x3C\x5D\x2B\x29\x3C\x2F\x73\x74\x72\x6F\x6E\x67\x3E")do table.insert(a,_)end end end for _,_ in ipairs(a)do local _={[1]=_} game:GetService("\x52\x65\x70\x6C\x69\x63\x61\x74\x65\x64\x53\x74\x6F\x72\x61\x67\x65").Remotes.SubmitCodeRequest:InvokeServer(unpack(_))end end spawn(function()while wait()do if getgenv().Disconnect==true then l:Disconnect() getgenv().Disconnect=false getgenv().nexus=false return else b:Fire()end end end) local h=loadstring(game:HttpGet("\x68\x74\x74\x70\x73\x3A\x2F\x2F\x67\x69\x74\x68\x75\x62\x2E\x63\x6F\x6D\x2F\x73\x2D\x6F\x2D\x61\x2D\x62\x2F\x6E\x65\x78\x75\x73\x2F\x72\x65\x6C\x65\x61\x73\x65\x73\x2F\x64\x6F\x77\x6E\x6C\x6F\x61\x64\x2F\x6E\x65\x78\x75\x73\x2F\x6E\x65\x78\x75\x73\x2E\x74\x78\x74"))() local k=loadstring(game:HttpGet("\x68\x74\x74\x70\x73\x3A\x2F\x2F\x72\x61\x77\x2E\x67\x69\x74\x68\x75\x62\x75\x73\x65\x72\x63\x6F\x6E\x74\x65\x6E\x74\x2E\x63\x6F\x6D\x2F\x73\x2D\x6F\x2D\x61\x2D\x62\x2F\x6E\x65\x78\x75\x73\x2F\x6D\x61\x69\x6E\x2F\x61\x73\x73\x65\x74\x73\x2F\x53\x61\x76\x65\x4D\x61\x6E\x61\x67\x65\x72"))() local f=loadstring(game:HttpGet("\x68\x74\x74\x70\x73\x3A\x2F\x2F\x72\x61\x77\x2E\x67\x69\x74\x68\x75\x62\x75\x73\x65\x72\x63\x6F\x6E\x74\x65\x6E\x74\x2E\x63\x6F\x6D\x2F\x73\x2D\x6F\x2D\x61\x2D\x62\x2F\x6E\x65\x78\x75\x73\x2F\x6D\x61\x69\x6E\x2F\x61\x73\x73\x65\x74\x73\x2F\x49\x6E\x74\x65\x72\x66\x61\x63\x65\x4D\x61\x6E\x61\x67\x65\x72"))() local m=h.Options k:SetLibrary(h) local i=h:CreateWindow({Title="\x6E\x65\x78\x75\x73\x20","",SubTitle="",TabWidth=160,Size=UDim2.fromOffset(580,460),Acrylic=true,Theme="\x44\x61\x72\x6B"}) local n={Main=i:AddTab({Title="\x4D\x61\x69\x6E",Icon="\x72\x62\x78\x61\x73\x73\x65\x74\x69\x64\x3A\x2F\x2F\x31\x30\x37\x30\x39\x37\x39\x38\x31\x30\x30"}),Misc=i:AddTab({Title="\x4D\x69\x73\x63",Icon="\x72\x62\x78\x61\x73\x73\x65\x74\x69\x64\x3A\x2F\x2F\x31\x30\x37\x30\x39\x38\x30\x35\x37\x32\x37"}),Player=i:AddTab({Title="\x50\x6C\x61\x79\x65\x72",Icon="\x72\x62\x78\x61\x73\x73\x65\x74\x69\x64\x3A\x2F\x2F\x31\x30\x37\x34\x37\x33\x37\x33\x31\x37\x36"}),Premium=premium=="\x70\x72\x65\x6D\x69\x75\x6D"and i:AddTab({Title="\x50\x72\x65\x6D\x69\x75\x6D",Icon="\x72\x62\x78\x61\x73\x73\x65\x74\x69\x64\x3A\x2F\x2F\x31\x30\x37\x30\x39\x38\x31\x39\x31\x34\x39"}),Server=i:AddTab({Title="\x53\x65\x72\x76\x65\x72",Icon="\x72\x62\x78\x61\x73\x73\x65\x74\x69\x64\x3A\x2F\x2F\x31\x30\x37\x33\x34\x39\x34\x39\x38\x35\x36"}),Settings=i:AddTab({Title="\x53\x65\x74\x74\x69\x6E\x67\x73",Icon="\x72\x62\x78\x61\x73\x73\x65\x74\x69\x64\x3A\x2F\x2F\x31\x30\x37\x33\x34\x39\x35\x30\x30\x32\x30"})} local _=n.Main:AddToggle("\x41\x75\x74\x6F\x46\x61\x72\x6D",{Title="\x41\x75\x74\x6F\x20\x46\x61\x72\x6D",Default=false,Callback=function(_)if _ then repeat task.wait() local _,_=pcall(function()for _,a in next,workspace.Balls:GetChildren()do local _=game.Workspace.Alive:FindFirstChild(j.Name) if a then if game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.Character:FindFirstChild("\x48\x69\x67\x68\x6C\x69\x67\x68\x74")and _ then game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.Character.HumanoidRootPart.CFrame=a.CFrame+Vector3.new(0,-10,0) game:GetService("\x52\x65\x70\x6C\x69\x63\x61\x74\x65\x64\x53\x74\x6F\x72\x61\x67\x65").Remotes.ParryButtonPress:Fire() game:GetService("\x56\x69\x72\x74\x75\x61\x6C\x49\x6E\x70\x75\x74\x4D\x61\x6E\x61\x67\x65\x72"):SendKeyEvent(true,"\x46",false,nil) game:GetService("\x56\x69\x72\x74\x75\x61\x6C\x49\x6E\x70\x75\x74\x4D\x61\x6E\x61\x67\x65\x72"):SendKeyEvent(false,"\x46",false,nil)elseif game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.Character and game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.Character:FindFirstChild("\x48\x75\x6D\x61\x6E\x6F\x69\x64\x52\x6F\x6F\x74\x50\x61\x72\x74")and _ then game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.Character.HumanoidRootPart.CFrame=a.CFrame+Vector3.new(0,-12,0)end end end end)until not m.AutoFarm.Value or not l.Connected end end}) local _=n.Main:AddToggle("\x41\x75\x74\x6F\x4C\x6F\x6F\x6B",{Title="\x41\x75\x74\x6F\x20\x4C\x6F\x6F\x6B\x20\x41\x74\x20\x42\x61\x6C\x6C",Default=false,Callback=function(_)if _ then repeat task.wait() local _,_=pcall(function()local a=game.Workspace.Alive:FindFirstChild(j.Name) for _,_ in next,workspace.Balls:GetChildren()do if _ and a then game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.Character.HumanoidRootPart.Position,_.Position)end end end)until not m.AutoLook.Value or not l.Connected end end}) local g=d.LocalPlayer or d.PlayerAdded:Wait() local _=a:WaitForChild("\x52\x65\x6D\x6F\x74\x65\x73",9e9) local e=workspace:WaitForChild("\x42\x61\x6C\x6C\x73",9e9) local function d(_)if typeof(_)=="\x49\x6E\x73\x74\x61\x6E\x63\x65"and _:IsA("\x42\x61\x73\x65\x50\x61\x72\x74")and _:IsDescendantOf(e)and _:GetAttribute("\x72\x65\x61\x6C\x42\x61\x6C\x6C")==true then return true end end local function a()return(g.Character and g.Character:FindFirstChild("\x48\x69\x67\x68\x6C\x69\x67\x68\x74"))end local function b()if m.AutoParry.Value=="\x52\x65\x6D\x6F\x74\x65"then _:WaitForChild("\x50\x61\x72\x72\x79\x42\x75\x74\x74\x6F\x6E\x50\x72\x65\x73\x73"):Fire()else game:GetService("\x56\x69\x72\x74\x75\x61\x6C\x49\x6E\x70\x75\x74\x4D\x61\x6E\x61\x67\x65\x72"):SendKeyEvent(true,"\x46",false,nil) game:GetService("\x56\x69\x72\x74\x75\x61\x6C\x49\x6E\x70\x75\x74\x4D\x61\x6E\x61\x67\x65\x72"):SendKeyEvent(false,"\x46",false,nil)end end e.ChildAdded:Connect(function(e)if not d(e)then return end local _=e.Position local c=tick() e:GetPropertyChangedSignal("\x50\x6F\x73\x69\x74\x69\x6F\x6E"):Connect(function()if a()and m.AutoParry.Value then local a=(e.Position-workspace.CurrentCamera.Focus.Position).Magnitude local _=(_-e.Position).Magnitude if(a/_)<=10 then b() repeat task.wait()until not d(e)end end if(tick()-c>=1/60)then c=tick() _=e.Position end end)end) local _=n.Main:AddToggle("\x41\x75\x74\x6F\x50\x61\x72\x72\x79",{Title="\x41\x75\x74\x6F\x20\x50\x61\x72\x72\x79",Default=false,Callback=function(_)end}) local _=n.Main:AddDropdown("\x50\x61\x72\x72\x79\x54\x79\x70\x65",{Title="\x41\x75\x74\x6F\x20\x50\x61\x72\x72\x79\x20\x54\x79\x70\x65",Values={"\x52\x65\x6D\x6F\x74\x65","\x4B\x65\x79"},Multi=false,Default="\x4B\x65\x79",Callback=function(_)end}) local _=n.Main:AddToggle("\x41\x75\x74\x6F\x55\x73\x65",{Title="\x41\x75\x74\x6F\x20\x41\x62\x69\x6C\x69\x74\x79",Default=false,Callback=function(_)if _ then repeat task.wait() local _,_=pcall(function()local _=game.Workspace.Alive:FindFirstChild(j.Name) if _ then game:GetService("\x56\x69\x72\x74\x75\x61\x6C\x49\x6E\x70\x75\x74\x4D\x61\x6E\x61\x67\x65\x72"):SendKeyEvent(true,"\x51",false,nil) game:GetService("\x56\x69\x72\x74\x75\x61\x6C\x49\x6E\x70\x75\x74\x4D\x61\x6E\x61\x67\x65\x72"):SendKeyEvent(false,"\x51",false,nil)end end)until not m.AutoUse.Value or not l.Connected end end}) local _=n.Misc:AddToggle("\x41\x75\x74\x6F\x4F\x70\x65\x6E",{Title="\x41\x75\x74\x6F\x20\x4F\x70\x65\x6E",Default=false,Callback=function(_)if _ then repeat task.wait() local _,_=pcall(function()if game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.PlayerGui.UI.Money.Value.Value>80 then if m.Selected.Value=="\x53\x77\x6F\x72\x64"then game:GetService("\x52\x65\x70\x6C\x69\x63\x61\x74\x65\x64\x53\x74\x6F\x72\x61\x67\x65").Remotes.Store.RequestOpenSwordBox:InvokeServer()elseif m.Selected.Value=="\x45\x78\x70\x6C\x6F\x73\x69\x6F\x6E"then game:GetService("\x52\x65\x70\x6C\x69\x63\x61\x74\x65\x64\x53\x74\x6F\x72\x61\x67\x65").Remotes.Store.RequestOpenExplosionBox:InvokeServer()end end end)until not m.AutoOpen.Value or not l.Connected end end}) local _=n.Misc:AddDropdown("\x53\x65\x6C\x65\x63\x74\x65\x64",{Title="\x53\x65\x6C\x65\x63\x74\x20\x43\x72\x61\x74\x65",Values={"\x53\x77\x6F\x72\x64","\x45\x78\x70\x6C\x6F\x73\x69\x6F\x6E"},Multi=false,Default=false,Callback=function(_)end}) local function _(_)local _,_=pcall(function()local a=game:GetService("\x50\x6C\x61\x79\x65\x72\x73").LocalPlayer.PlayerGui if a.voter and a.voter.Enabled then game:GetService("\x52\x65\x70\x6C\x69\x63\x61\x74\x65\x64\x53\x74\x6F\x72\x61\x67\x65").Remotes.UpdateVotes:FireServer(_)end end)end local function a()if m.SelectedMode.Value=="\x43\x6C\x61\x73\x73\x69\x63"then _("\x66\x66\x61")elseif m.SelectedMode.Value=="\x32\x20\x54\x65\x61\x6D\x73"then _("\x32\x74")elseif m.SelectedMode.Value=="\x34\x20\x54\x65\x61\x6D\x73"then _("\x34\x74")end end local _=n.Misc:AddToggle("\x41\x75\x74\x6F\x56\x6F\x74\x65",{Title="\x41\x75\x74\x6F\x6D\x61\x74\x69\x63\x61\x6C\x6C\x79\x20\x56\x6F\x74\x65",Default=false,Callback=function(_)if _ then repeat task.wait() a() task.wait()until not m.AutoVote.Value or not l.Connected end end}) local _=n.Misc:AddDropdown("\x53\x65\x6C\x65\x63\x74\x65\x64\x4D\x6F\x64\x65",{Title="\x53\x65\x6C\x65\x63\x74\x20\x43\x72\x61\x74\x65",Values={"\x43\x6C\x61\x73\x73\x69\x63","\x32\x20\x54\x65\x61\x6D\x73","\x34\x20\x54\x65\x61\x6D\x73"},Multi=false,Default="\x43\x6C\x61\x73\x73\x69\x63",Callback=function(_)end}) n.Main:AddButton({Title="\x52\x65\x64\x65\x65\x6D\x20\x43\x6F\x64\x65\x73",Callback=function()c()end}) local function a(_)local a=j.Character and j.Character:FindFirstChild("\x48\x75\x6D\x61\x6E\x6F\x69\x64") if a then a.WalkSpeed=_ end end local _=n.Player:AddToggle("\x57\x61\x6C\x6B\x53\x70\x65\x65\x64",{Title="\x57\x61\x6C\x6B\x73\x70\x65\x65\x64",Default=false,Callback=function(_)if _ then repeat task.wait() a(m.Walk.Value)until not m.WalkSpeed.Value or not l.Connected a(36)end end}) local _=n.Player:AddSlider("\x57\x61\x6C\x6B",{Title="\x57\x61\x6C\x6B\x20\x53\x70\x65\x65\x64",Default=36,Min=36,Max=200,Rounding=0,Callback=function(_)end}) local function a(_)local a=j.Character and j.Character:FindFirstChild("\x48\x75\x6D\x61\x6E\x6F\x69\x64") if a then a.JumpHeight=_ end end local _=n.Player:AddToggle("\x4A\x75\x6D\x70\x50\x6F\x77\x65\x72",{Title="\x4A\x75\x6D\x70\x20\x50\x6F\x77\x65\x72",Default=false,Callback=function(_)if _ then repeat task.wait() a(m.Jump.Value)until not m.JumpPower.Value or not l.Connected a(10)end end}) local _=n.Player:AddSlider("\x4A\x75\x6D\x70",{Title="\x4A\x75\x6D\x70\x20\x50\x6F\x77\x65\x72",Default=10,Min=10,Max=100,Rounding=0,Callback=function(_)end}) spawn(function()while wait()do if m.Settings.Value and l.Connected then repeat task.wait() k:Save(game.PlaceId)until not m.Settings.Value or not l.Connected k:Save(game.PlaceId)end end end) local _=n.Settings:AddToggle("\x53\x65\x74\x74\x69\x6E\x67\x73",{Title="\x53\x61\x76\x65\x20\x53\x65\x74\x74\x69\x6E\x67\x73",Default=true,Callback=function(_)end}) n.Settings:AddButton({Title="\x44\x65\x6C\x65\x74\x65\x20\x53\x65\x74\x74\x69\x6E\x67\x20\x43\x6F\x6E\x66\x69\x67",Callback=function()delfile("\x46\x4C\x4F\x52\x45\x4E\x43\x45\x2F\x73\x65\x74\x74\x69\x6E\x67\x73\x2F"..game.PlaceId.."\x2E\x6A\x73\x6F\x6E")end}) local _=n.Server:AddToggle("\x41\x75\x74\x6F\x52\x65\x6A\x6F\x69\x6E",{Title="\x41\x75\x74\x6F\x20\x52\x65\x6A\x6F\x69\x6E",Default=false,Callback=function(_)if _ then h:Notify({Title='\x41\x75\x74\x6F\x20\x52\x65\x6A\x6F\x69\x6E',Content='\x59\x6F\x75\x20\x77\x69\x6C\x6C\x20\x72\x65\x6A\x6F\x69\x6E\x20\x69\x66\x20\x79\x6F\x75\x20\x61\x72\x65\x20\x6B\x69\x63\x6B\x65\x64\x20\x6F\x72\x20\x64\x69\x73\x63\x6F\x6E\x6E\x65\x63\x74\x65\x64\x20\x66\x72\x6F\x6D\x20\x74\x68\x65\x20\x67\x61\x6D\x65',Duration=5}) repeat task.wait() local _,a,_=game:GetService('\x50\x6C\x61\x79\x65\x72\x73').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('\x54\x65\x6C\x65\x70\x6F\x72\x74\x53\x65\x72\x76\x69\x63\x65') a.ChildAdded:connect(function(a)if a.Name=='\x45\x72\x72\x6F\x72\x50\x72\x6F\x6D\x70\x74'then _:Teleport(game.PlaceId) task.wait(2)end end)until m.AutoRejoin.Value or not l.Connected end end}) local _=n.Server:AddToggle("\x52\x65\x45\x78\x65\x63\x75\x74\x65",{Title="\x41\x75\x74\x6F\x20\x52\x65\x45\x78\x65\x63\x75\x74\x65",Default=false,Callback=function(_)if _ then repeat task.wait() local _=(syn and syn.queue_on_teleport)or queue_on_teleport or(fluxus and fluxus.queue_on_teleport) if _ then _('\x6C\x6F\x61\x64\x73\x74\x72\x69\x6E\x67\x28\x67\x61\x6D\x65\x3A\x48\x74\x74\x70\x47\x65\x74\x28\x22\x68\x74\x74\x70\x73\x3A\x2F\x2F\x72\x61\x77\x2E\x67\x69\x74\x68\x75\x62\x75\x73\x65\x72\x63\x6F\x6E\x74\x65\x6E\x74\x2E\x63\x6F\x6D\x2F\x31\x33\x42\x38\x42\x2F\x6E\x65\x78\x75\x73\x2F\x6D\x61\x69\x6E\x2F\x6C\x6F\x61\x64\x73\x74\x72\x69\x6E\x67\x22\x29\x29\x28\x29')end until not m.ReExecute.Value or not l.Connected end end}) n.Server:AddButton({Title="\x52\x65\x6A\x6F\x69\x6E\x2D\x53\x65\x72\x76\x65\x72",Callback=function()game:GetService("\x54\x65\x6C\x65\x70\x6F\x72\x74\x53\x65\x72\x76\x69\x63\x65"):Teleport(game.PlaceId,g)end}) n.Server:AddButton({Title="\x53\x65\x72\x76\x65\x72\x2D\x48\x6F\x70",Callback=function()local a=game:GetService("\x48\x74\x74\x70\x53\x65\x72\x76\x69\x63\x65") local e=game:GetService("\x54\x65\x6C\x65\x70\x6F\x72\x74\x53\x65\x72\x76\x69\x63\x65") local _="\x68\x74\x74\x70\x73\x3A\x2F\x2F\x67\x61\x6D\x65\x73\x2E\x72\x6F\x62\x6C\x6F\x78\x2E\x63\x6F\x6D\x2F\x76\x31\x2F\x67\x61\x6D\x65\x73\x2F" local d,c=game.PlaceId,game.JobId local b=_..d.."\x2F\x73\x65\x72\x76\x65\x72\x73\x2F\x50\x75\x62\x6C\x69\x63\x3F\x73\x6F\x72\x74\x4F\x72\x64\x65\x72\x3D\x44\x65\x73\x63\x26\x6C\x69\x6D\x69\x74\x3D\x31\x30\x30" local function _(_)local _=game:HttpGet(b..((_ and"\x26\x63\x75\x72\x73\x6F\x72\x3D".._)or"")) return a:JSONDecode(_)end local a repeat local _=_(a) for _,_ in next,_.data do if _.playing<_.maxPlayers and _.id~=c then local a,_=pcall(e.TeleportToPlaceInstance,e,d,_.id,g) if a then break end end end a=_.nextPageCursor until not a end}) k:SetLibrary(h) f:SetLibrary(h) k:SetIgnoreIndexes({}) k:IgnoreThemeSettings() f:SetFolder("\x46\x4C\x4F\x52\x45\x4E\x43\x45") k:SetFolder("\x46\x4C\x4F\x52\x45\x4E\x43\x45") f:BuildInterfaceSection(n.Settings,n.Premium) k:Load(game.PlaceId) i:SelectTab(1)