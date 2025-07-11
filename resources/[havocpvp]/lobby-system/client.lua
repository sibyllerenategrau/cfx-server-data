-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Système de lobby côté client

local isLobbyOpen = false
local availableGamemodes = {}

-- Événement pour ouvrir le menu lobby
RegisterNetEvent('havocpvp:openLobbyMenu')
AddEventHandler('havocpvp:openLobbyMenu', function()
    if not isLobbyOpen then
        isLobbyOpen = true
        
        -- Demander la liste des gamemodes disponibles
        TriggerServerEvent('havocpvp:requestGamemodes')
        
        -- Ouvrir l'interface NUI
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openLobby",
            gamemodes = availableGamemodes
        })
    end
end)

-- Événement pour fermer le menu lobby
RegisterNetEvent('havocpvp:closeLobbyMenu')
AddEventHandler('havocpvp:closeLobbyMenu', function()
    if isLobbyOpen then
        isLobbyOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeLobby"
        })
    end
end)

-- Recevoir la liste des gamemodes
RegisterNetEvent('havocpvp:receiveGamemodes')
AddEventHandler('havocpvp:receiveGamemodes', function(gamemodes)
    availableGamemodes = gamemodes
    
    if isLobbyOpen then
        SendNUIMessage({
            type = "updateGamemodes",
            gamemodes = gamemodes
        })
    end
end)

-- Callbacks NUI
RegisterNUICallback('selectGamemode', function(data, cb)
    if data.gamemode then
        -- Fermer le lobby
        TriggerEvent('havocpvp:closeLobbyMenu')
        
        -- Envoyer la sélection au serveur
        TriggerServerEvent('havocpvp:selectGamemode', data.gamemode)
    end
    cb('ok')
end)

RegisterNUICallback('closeLobby', function(data, cb)
    TriggerEvent('havocpvp:closeLobbyMenu')
    cb('ok')
end)

-- Commande pour ouvrir le lobby manuellement
RegisterCommand('havoc_lobby', function()
    TriggerEvent('havocpvp:openLobbyMenu')
end, false)

-- Gestion de l'ESC pour fermer le lobby
CreateThread(function()
    while true do
        Wait(0)
        
        if isLobbyOpen then
            if IsControlJustPressed(0, 322) then -- ESC
                TriggerEvent('havocpvp:closeLobbyMenu')
            end
        end
    end
end)