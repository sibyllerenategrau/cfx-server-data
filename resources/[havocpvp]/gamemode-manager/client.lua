-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Gestionnaire de gamemode côté client

local playerStatus = PlayerStatus.LOBBY
local currentGamemode = nil

-- Désactiver le spawn automatique au démarrage
CreateThread(function()
    exports['spawn-manager']:setAutoSpawn(false)
end)

-- Gestion des événements de changement de statut
RegisterNetEvent('havocpvp:statusChanged')
AddEventHandler('havocpvp:statusChanged', function(status)
    playerStatus = status
    
    if status == PlayerStatus.LOBBY then
        -- Retourner au lobby
        TriggerEvent('havocpvp:returnToLobby')
    elseif status == PlayerStatus.IN_GAME then
        -- Le joueur est maintenant en jeu
        print("Statut changé: En jeu")
    end
end)

-- Événement pour démarrer un gamemode
RegisterNetEvent('havocpvp:startGamemode')
AddEventHandler('havocpvp:startGamemode', function(gamemode)
    currentGamemode = gamemode
    
    -- Désactiver le lobby NUI
    TriggerEvent('havocpvp:closeLobbyMenu')
    
    -- Activer le spawn manager pour ce gamemode
    exports['spawn-manager']:setAutoSpawn(true)
    exports['spawn-manager']:forceRespawn()
    
    print("Gamemode démarré: " .. gamemode)
end)

-- Événement pour retourner au lobby
RegisterNetEvent('havocpvp:returnToLobby')
AddEventHandler('havocpvp:returnToLobby', function()
    currentGamemode = nil
    
    -- Désactiver le spawn automatique
    exports['spawn-manager']:setAutoSpawn(false)
    
    -- Spawner le joueur dans le lobby
    exports['spawn-manager']:spawnPlayer({
        x = Config.LobbyPosition.x,
        y = Config.LobbyPosition.y,
        z = Config.LobbyPosition.z,
        heading = Config.LobbyPosition.heading,
        model = `mp_m_freemode_01`,
        skipFade = false
    })
    
    -- Ouvrir le menu lobby
    TriggerEvent('havocpvp:openLobbyMenu')
end)

-- Gestionnaire de spawn initial
AddEventHandler('playerSpawned', function()
    if playerStatus == PlayerStatus.LOBBY then
        -- Forcer le retour au lobby
        Wait(Config.SpawnDelay)
        TriggerEvent('havocpvp:returnToLobby')
    end
end)

-- Gestion des cartes côté client
local maps = {}
local gametypes = {}

AddEventHandler('onClientResourceStart', function(res)
    -- Analyser les métadonnées pour cette ressource
    local num = GetNumResourceMetadata(res, 'map')

    if num > 0 then
        for i = 0, num-1 do
            local file = GetResourceMetadata(res, 'map', i)
            if file then
                addMap(file, res)
            end
        end
    end

    -- Données de type de ressource
    local type = GetResourceMetadata(res, 'resource_type', 0)

    if type then
        local extraData = GetResourceMetadata(res, 'resource_type_extra', 0)

        if extraData then
            extraData = json.decode(extraData)
        else
            extraData = {}
        end

        if type == 'map' then
            maps[res] = extraData
        elseif type == 'gametype' then
            gametypes[res] = extraData
        end
    end

    -- Gérer le démarrage
    loadMap(res)

    -- Différer à la prochaine frame pour éviter les problèmes de dépendances
    CreateThread(function()
        Wait(15)

        if maps[res] then
            TriggerEvent('onClientMapStart', res)
        elseif gametypes[res] then
            TriggerEvent('onClientGameTypeStart', res)
        end
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if maps[res] then
        TriggerEvent('onClientMapStop', res)
    elseif gametypes[res] then
        TriggerEvent('onClientGameTypeStop', res)
    end

    unloadMap(res)
end)

-- Commande pour ouvrir le menu lobby
RegisterCommand('lobby', function()
    if playerStatus == PlayerStatus.LOBBY then
        TriggerEvent('havocpvp:openLobbyMenu')
    end
end, false)