ESX = nil
local ui = false

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(1)
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
    end
end)

RegisterNetEvent("esx_status:onTick") 
AddEventHandler("esx_status:onTick", function(status)
    hunger, thirst = status[1].percent, status[2].percent
end)

RegisterNetEvent('dlrms_hud:ui')
AddEventHandler('dlrms_hud:ui', function(bool)
    ui = bool   
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = 'ui',
        ui = bool
    })
end)

RegisterNUICallback('dlrms_hud:close', function()
    TriggerEvent('dlrms_hud:ui', false)
end)

RegisterCommand('hud', function()
    ui = not ui
    if ui then 
        TriggerEvent('dlrms_hud:ui', true)
    else
        TriggerEvent('dlrms_hud:ui', false)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 100
        local pauseMenuOn = IsPauseMenuActive()
        
        if not pauseMenuOn then 
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped) - 100
            local armor = GetPedArmour(ped)
            local swim = IsPedSwimming(ped)
            local breath = IsPedSwimmingUnderWater(ped)
            local vehicle = GetVehiclePedIsIn(ped, false)
            local hungerAlert = Config.HungerAlert
            local thirstAlert = Config.ThirstAlert
            local healthAlert = Config.HealthAlert
            local armorAlert = Config.ArmorAlert

            if IsPedInVehicle(ped, vehicle, false) then
                DisplayRadar(true)
            else
                DisplayRadar(false)
                if breath then
                    stamina = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
                else
                    stamina = GetPlayerSprintTimeRemaining(PlayerId()) * 10
                end
            end
                
            SendNUIMessage({
                action = 'hud',
                pauseMenuOn = false,
                health = health,
                healthAlert = healthAlert,
                armor = armor,
                armorAlert = armorAlert,

                hunger = hunger,
                hungerAlert = hungerAlert,
                thirst = thirst,
                thirstAlert = thirstAlert,

                stamina = stamina,
                swim = swim,
                breath = breath,

                vehicle = vehicle
            })
        else
            sleep = 500
            SendNUIMessage({
                pauseMenuOn = true
            })
        end
        Citizen.Wait(sleep)
    end
end)
