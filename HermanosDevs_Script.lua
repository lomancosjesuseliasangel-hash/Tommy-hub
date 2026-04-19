-- ╔════════════════════════════════════════════════════════════════════════════════╗
-- ║                      HERMANOS DEVS - TOMMY HUB SCRIPT                          ║
-- ║                     Professional Grade Script Framework                        ║
-- ║                          Made by lomancosjesuseliasangel                       ║
-- ╚════════════════════════════════════════════════════════════════════════════════╝

local HermanosDevs = {}
HermanosDevs.Version = "1.0.0"
HermanosDevs.Author = "lomancosjesuseliasangel"

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURACIÓN GLOBAL
-- ════════════════════════════════════════════════════════════════════════════════
local Config = {
    Script = {
        Name = "Hermanos Devs - Tommy Hub",
        Version = "1.0.0",
        Debug = true
    },
    Combat = {
        FastAttackEnabled = false,
        AttackRange = 50,
        AttackDelay = 0.01,
        MaxTargets = 10
    },
    UI = {
        Enabled = true,
        Theme = "Dark"
    }
}

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVICIOS Y VARIABLES
-- ════════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerHRP = PlayerCharacter:WaitForChild("HumanoidRootPart")

-- ════════════════════════════════════════════════════════════════════════════════
-- UTILIDADES
-- ════════════════════════════════════════════════════════════════════════════════
local Utils = {}

function Utils:Print(message, type)
    type = type or "INFO"
    local prefix = string.format("[%s] [%s]", Config.Script.Name, type)
    print(prefix .. " " .. message)
end

function Utils:Notify(title, message, duration)
    duration = duration or 3
    Utils:Print(message, "NOTIFY")
end

function Utils:IsAlive(character)
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

function Utils:GetDistance(position1, position2)
    return (position1 - position2).Magnitude
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE COMBAT
-- ════════════════════════════════════════════════════════════════════════════════
local Combat = {}

function Combat:GetTargetsInRange()
    local targets = {}
    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myHRP then return targets end
    
    -- Buscar jugadores
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Utils:IsAlive(player.Character) then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = Utils:GetDistance(myHRP.Position, targetHRP.Position)
                if distance <= Config.Combat.AttackRange then
                    table.insert(targets, player.Character)
                end
            end
        end
    end
    
    -- Buscar NPCs
    local enemiesFolder = workspace:FindFirstChild("Enemigos")
    if enemiesFolder then
        for _, npc in pairs(enemiesFolder:GetChildren()) do
            if Utils:IsAlive(npc) then
                local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                if npcHRP then
                    local distance = Utils:GetDistance(myHRP.Position, npcHRP.Position)
                    if distance <= Config.Combat.AttackRange then
                        table.insert(targets, npc)
                    end
                end
            end
        end
    end
    
    return targets
end

function Combat:Attack(targets)
    if #targets == 0 then return end
    
    pcall(function()
        local firstTarget = targets[1]
        local head = firstTarget:FindFirstChild("Head")
        
        if head then
            -- Aquí va la lógica específica del juego
            local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
            Net["RE/RegisterAttack"]:FireServer(0)
            Net["RE/RegisterHit"]:FireServer(head, targets)
            
            Utils:Print("Atacando a " .. #targets .. " objetivo(s)", "ATTACK")
        end
    end)
end

function Combat:StartFastAttack()
    task.spawn(function()
        while Config.Combat.FastAttackEnabled do
            task.wait(Config.Combat.AttackDelay)
            
            local targets = Combat:GetTargetsInRange()
            if #targets > 0 then
                Combat:Attack(targets)
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- INTERFAZ RAYFIELD
-- ════════════════════════════════════════════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = Config.Script.Name,
    LoadingTitle = "Iniciando...",
    LoadingSubtitle = "Hermanos Devs",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HermanosDevs",
        FileName = "config"
    },
    KeySystem = false
})

-- Tab Principal
local MainTab = Window:CreateTab("Principal", 4483362458)

MainTab:CreateLabel("Versión: " .. Config.Script.Version)
MainTab:CreateLabel("Autor: " .. Config.Script.Author)
MainTab:CreateDivider()

-- Toggle Fast Attack
local FastAttackToggle = MainTab:CreateToggle({
    Name = "Fast Attack",
    CurrentValue = false,
    Flag = "FastAttack",
    Callback = function(Value)
        Config.Combat.FastAttackEnabled = Value
        if Value then
            Utils:Notify("Fast Attack", "Activado ✓")
            Combat:StartFastAttack()
        else
            Utils:Notify("Fast Attack", "Desactivado ✗")
        end
    end
})

-- Slider Rango de Ataque
local RangeSlider = MainTab:CreateSlider({
    Name = "Rango de Ataque",
    Range = {5, 150},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 50,
    Flag = "AttackRange",
    Callback = function(Value)
        Config.Combat.AttackRange = Value
        Utils:Print("Rango actualizado a: " .. Value, "CONFIG")
    end
})

-- Slider Attack Delay
local DelaySlider = MainTab:CreateSlider({
    Name = "Velocidad de Ataque",
    Range = {0.001, 0.5},
    Increment = 0.001,
    Suffix = "s",
    CurrentValue = 0.01,
    Flag = "AttackDelay",
    Callback = function(Value)
        Config.Combat.AttackDelay = Value
        Utils:Print("Delay de ataque: " .. Value, "CONFIG")
    end
})

MainTab:CreateDivider()

-- Botones de Utilidad
MainTab:CreateButton({
    Name = "Información del Script",
    Callback = function()
        Utils:Print("═══════════════════════════════════════", "INFO")
        Utils:Print("Script: " .. Config.Script.Name, "INFO")
        Utils:Print("Versión: " .. Config.Script.Version, "INFO")
        Utils:Print("Autor: " .. Config.Script.Author, "INFO")
        Utils:Print("Estado Attack: " .. (Config.Combat.FastAttackEnabled and "ACTIVO" or "INACTIVO"), "INFO")
        Utils:Print("Rango: " .. Config.Combat.AttackRange, "INFO")
        Utils:Print("═══════════════════════════════════════", "INFO")
    end
})

MainTab:CreateButton({
    Name = "Cerrar Script",
    Callback = function()
        Window:Close()
        Utils:Notify("Script", "Cerrado")
    end
})

-- Tab Avanzado
local AdvancedTab = Window:CreateTab("Avanzado", 4483362458)

AdvancedTab:CreateLabel("Configuración Avanzada")

AdvancedTab:CreateToggle({
    Name = "Debug Mode",
    CurrentValue = Config.Script.Debug,
    Flag = "DebugMode",
    Callback = function(Value)
        Config.Script.Debug = Value
        Utils:Print("Debug: " .. (Value and "ON" or "OFF"), "CONFIG")
    end
})

AdvancedTab:CreateButton({
    Name = "Recargar Script",
    Callback = function()
        Utils:Print("Recargando...", "RELOAD")
        wait(1)
        Utils:Print("Script recargado", "RELOAD")
    end
})

-- ════════════════════════════════════════════════════════════════════════════════
-- NOTIFICACIÓN DE INICIO
-- ════════════════════════════════════════════════════════════════════════════════
Rayfield:Notify({
    Title = "Hermanos Devs",
    Content = "Script cargado exitosamente v" .. Config.Script.Version,
    Duration = 3,
    Image = 4483362458
})

Utils:Print("Script iniciado correctamente", "SUCCESS")
Utils:Print("Autor: " .. Config.Script.Author, "INFO")

return HermanosDevs
