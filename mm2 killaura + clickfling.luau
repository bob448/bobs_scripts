local players=game:GetService("Players")
local player=players.LocalPlayer
local uis=game:GetService("UserInputService")
local startergui=game:GetService("StarterGui")
local mouse=player:GetMouse()

--[[

made by bob448

]]

getgenv().SETTINGS={
    Enabled=true,
    KeyCode=Enum.KeyCode.X,
    Distance=30,
    ClickKill=true,
    Disconnect=false
}

local char=nil
local root=nil
local hum=nil

local function getChar(player:Player)
    player=player or players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

local function getHum(char:Model)
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function getRoot(char:Model)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getKnife(char:Model,player:Player)
    char=char or getChar(player)
    local function isKnife(v)
        if v:FindFirstChild("KnifeScriptR15") or v:FindFirstChild("KnifeScriptR6") then
            return true
        end
        return false
    end
    for i,v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then
            if isKnife(v) then
                return v
            end
        end
    end
    for i,v in ipairs(player.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if isKnife(v) then
                return v
            end
        end
    end
    return
end

local toggled=false

local function CharacterAdded(character:Model)
    char=character
    hum=getHum(char) or char:WaitForChild("Humanoid")
    root=getRoot(char) or char:WaitForChild("HumanoidRootPart")
    local knife
    repeat task.wait(); knife=getKnife(char, player) until knife
    local handle=knife:WaitForChild("Handle")
    getgenv().SETTINGS.Distance=getgenv().SETTINGS.Distance or 30
    while task.wait() and hum.Health>0 and char and char.Parent do
        for i,v in ipairs(players:GetPlayers()) do
            local tchar=getChar(v)
            local troot=getRoot(tchar)
            local thum=getHum(tchar)
            if v~=player and troot and thum and thum.Health>0 and toggled and v:DistanceFromCharacter(root.Position)<=getgenv().SETTINGS.Distance then
                knife.Parent=char
                knife:Activate()
                firetouchinterest(handle, getRoot(getChar(v)),0)
                firetouchinterest(handle, getRoot(getChar(v)),1)
            end
        end
    end
end

local function createChatMsg(text:string,color)
    color=color and typeof(color)=="Color3" or Color3.fromRGB(255,200,0)
    startergui:SetCore( "ChatMakeSystemMessage",  { Text = text, Color = color, Font = Enum.Font.Arial, FontSize = Enum.FontSize.Size24 } )
end

local inputbegan;inputbegan=uis.InputBegan:Connect(function(input,proc)
    if not proc and getgenv().SETTINGS.Enabled and getgenv().SETTINGS.KeyCode and input.KeyCode==getgenv().SETTINGS.KeyCode then
        toggled = not toggled
        createChatMsg("Toggled killaura to "..tostring(toggled))
    elseif not proc and getgenv().SETTINGS.Enabled and getgenv().SETTINGS.ClickKill and input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        if mouse.Target and char and hum then
            local tchar=mouse.Target.Parent
            local troot=getRoot(tchar)
            local plr=tchar and players:GetPlayerFromCharacter(tchar)
            local knife=char and getKnife(char, player)
            local handle=knife:WaitForChild("Handle")
            if troot and plr and plr~=player and knife then
                knife.Parent=char
                knife:Activate()
                firetouchinterest(handle,troot,0)
                task.wait()
                firetouchinterest(handle,troot,1)
            end
        end
    end
end)

local charadd;charadd=player.CharacterAdded:Connect(CharacterAdded)

if getChar(player) then
    CharacterAdded(getChar(player))
end

task.spawn(function()
    repeat task.wait() until getgenv().SETTINGS.Disconnect
    if charadd then
        charadd:Disconnect()
    end
    if inputbegan then
        inputbegan:Disconnect()
    end
end)