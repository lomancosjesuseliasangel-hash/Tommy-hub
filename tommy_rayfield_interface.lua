-- Rayfield UI Interface combined with Fast Attack Script

-- Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

Rayfield:CreateWindow({
    Name = "Tommy Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by lomancosjesuseliasangel-hash",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TommyHub",
        FileName = "config"
    }
})

-- Fast Attack Functionality
local function fastAttack()
    while true do
        -- Add your attack logic here
        wait(0.5) -- Adjust attack speed here
    end
end

-- UI Button to start fast attack
Rayfield:CreateButton({
    Name = "Start Fast Attack",
    Callback = function()
        fastAttack()
    end
})

-- Add any additional UI elements below