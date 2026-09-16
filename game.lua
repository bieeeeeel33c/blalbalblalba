local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1549575922217132082/HDp3OhJXsO7h48PhLvxYKPCUK-Ehml8L0SybGxC_X1WPWRV__bYavG_Kvms7wNRaLuAF"
local HUB_PLACE_ID = 15327728308
local PING_ROLE_ID = "1535102256519577660"
local ITENS_ALVO = {"barret50", "renellim4", "m79", "backpacktier4"}

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function sendToDiscord(msg, ping)
    local req = syn and syn.request or http_request or request
    if not req then return end
    local content = ping and ("<@&" .. PING_ROLE_ID .. "> " .. msg) or msg
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({content = content})
        })
    end)
end

task.wait(2)

local found = {}

for _, player in ipairs(Players:GetPlayers()) do
    if player == Players.LocalPlayer then continue end

    local inv = player:WaitForChild("GunInventory", 3)
    if inv then
        for _, obj in ipairs(inv:GetChildren()) do
            if obj:IsA("ObjectValue") and obj.Value then
                local nome = obj.Value.Name
                for _, alvo in ipairs(ITENS_ALVO) do
                    if nome and nome:lower():find(alvo:lower()) then
                        local mag = obj:FindFirstChild("BulletsInMagazine") and obj.BulletsInMagazine.Value or 0
                        table.insert(found, string.format("%s | %s | %d balas", player.Name, nome, mag))
                        sendToDiscord("Found: " .. player.Name .. " | " .. nome, true)
                    end
                end
            end
        end
    end

    local bp = player:GetAttribute("EquipmentBackpack")
    if bp and tostring(bp):lower():find("backpacktier4") then
        table.insert(found, string.format("%s | BackpackTier4 | N/A", player.Name))
        sendToDiscord("Tier4: " .. player.Name, true)
    end
end

pcall(function()
    local EmberClient = require(game:GetService("ReplicatedFirst")
        :WaitForChild("EmberClientLibrary")
        :WaitForChild("EmberClient")
        :WaitForChild("EmberClient"))
    local NPCSimulatorService = EmberClient:GetService("NPCSimulatorService")
    for _, Zombie in NPCSimulatorService.NPCs do
        for _, Item in Zombie.Equipment do
            local ItemClass = Item.ClassName
            local Skin = Item.SkinOverride
            if ItemClass:find("Altyn") then
                sendToDiscord("Chinese zombie: " .. ItemClass:gsub(".item", ""), true)
            elseif Skin and Skin:find("Beret") then
                sendToDiscord("Tactical zombie: " .. Skin, true)
            end
        end
    end
end)

if #found > 0 then
    sendToDiscord("Total: " .. #found, false)
end

task.wait(3)

local qt = queue_on_teleport or queueteleport or (syn and syn.queue_on_teleport)
if qt then
    qt([[loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/SEU_REPO/main/hub.lua"))()]])
end

TeleportService:Teleport(HUB_PLACE_ID)
