-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Gestionnaire de gamemode côté serveur

-- Tables pour stocker les cartes et types de jeu
local maps = {}
local gametypes = {}
local players = {} -- État des joueurs

-- Variables d'état actuelles
local currentGameType = nil
local currentMap = nil

-- Fonction pour rafraîchir les ressources
local function refreshResources()
    local numResources = GetNumResources()

    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)

        if GetNumResourceMetadata(resource, 'resource_type') > 0 then
            local type = GetResourceMetadata(resource, 'resource_type', 0)
            local params = json.decode(GetResourceMetadata(resource, 'resource_type_extra', 0))
            
            local valid = false
            
            local games = GetNumResourceMetadata(resource, 'game')
            if games > 0 then
                for j = 0, games - 1 do
                    local game = GetResourceMetadata(resource, 'game', j)
                
                    if game == GetConvar('gamename', 'gta5') or game == 'common' then
                        valid = true
                    end
                end
            end

            if valid then
                if type == 'map' then
                    maps[resource] = params
                elseif type == 'gametype' then
                    gametypes[resource] = params
                end
            end
        end
    end
end

-- Gestionnaire de connexion des joueurs
AddEventHandler('playerConnecting', function()
    local source = source
    players[source] = {
        status = PlayerStatus.LOBBY,
        selectedGamemode = nil
    }
end)

-- Gestionnaire de déconnexion des joueurs
AddEventHandler('playerDropped', function()
    local source = source
    players[source] = nil
end)

-- Événement pour changer le statut d'un joueur
RegisterNetEvent('havocpvp:setPlayerStatus')
AddEventHandler('havocpvp:setPlayerStatus', function(status)
    local source = source
    if players[source] then
        players[source].status = status
        
        -- Notifier le client du changement
        TriggerClientEvent('havocpvp:statusChanged', source, status)
    end
end)

-- Événement pour sélectionner un gamemode
RegisterNetEvent('havocpvp:selectGamemode')
AddEventHandler('havocpvp:selectGamemode', function(gamemode)
    local source = source
    if players[source] and gametypes[gamemode] then
        players[source].selectedGamemode = gamemode
        players[source].status = PlayerStatus.IN_GAME
        
        -- Démarrer le gamemode pour ce joueur
        TriggerClientEvent('havocpvp:startGamemode', source, gamemode)
        
        -- Changer le gamemode actuel si nécessaire
        if currentGameType ~= gamemode then
            changeGameType(gamemode)
        end
    end
end)

-- Événement pour demander la liste des gamemodes (relayé au lobby-system)
RegisterNetEvent('havocpvp:requestGamemodes')
AddEventHandler('havocpvp:requestGamemodes', function()
    local source = source
    local gamemodeList = {}
    
    for resource, data in pairs(gametypes) do
        table.insert(gamemodeList, {
            id = resource,
            name = data.name or resource,
            description = data.description or 'Mode de jeu HavocPvP'
        })
    end
    
    TriggerClientEvent('havocpvp:receiveGamemodes', source, gamemodeList)
end)

-- Rafraîchir les ressources au démarrage
AddEventHandler('onResourceListRefresh', function()
    refreshResources()
end)

refreshResources()

-- Gestion du démarrage des ressources
AddEventHandler('onResourceStarting', function(resource)
    local num = GetNumResourceMetadata(resource, 'map')

    if num then
        for i = 0, num-1 do
            local file = GetResourceMetadata(resource, 'map', i)
            if file then
                addMap(file, resource)
            end
        end
    end

    if maps[resource] then
        print("Carte détectée: " .. resource)
    elseif gametypes[resource] then
        print("Mode de jeu détecté: " .. resource)
    end
end)

-- Fonctions exportées
function getCurrentGameType()
    return currentGameType
end

function getCurrentMap()
    return currentMap
end

function getMaps()
    return maps
end

function getGameTypes()
    return gametypes
end

function changeGameType(gameType)
    if currentMap and not doesMapSupportGameType(gameType, currentMap) then
        StopResource(currentMap)
    end

    if currentGameType then
        StopResource(currentGameType)
    end

    currentGameType = gameType
    StartResource(gameType)
    
    print("Mode de jeu changé pour: " .. gameType)
end

function changeMap(map)
    if currentMap then
        StopResource(currentMap)
    end

    currentMap = map
    StartResource(map)
    
    print("Carte changée pour: " .. map)
end

function doesMapSupportGameType(gameType, map)
    if not gametypes[gameType] then
        return false
    end

    if not maps[map] then
        return false
    end

    if not maps[map].gameTypes then
        return true
    end

    return maps[map].gameTypes[gameType]
end

function roundEnded()
    -- Logique de fin de round
    TriggerEvent('havocpvp:roundEnded')
end

-- Commandes RCON pour la gestion
AddEventHandler('rconCommand', function(commandName, args)
    if commandName == 'havoc_map' then
        if #args ~= 1 then
            RconPrint("usage: havoc_map [nom_carte]\n")
            return
        end

        if not maps[args[1]] then
            RconPrint('Carte inexistante: ' .. args[1] .. "\n")
            CancelEvent()
            return
        end

        changeMap(args[1])
        RconPrint('Carte changée pour: ' .. args[1] .. "\n")
        CancelEvent()
    elseif commandName == 'havoc_gamemode' then
        if #args ~= 1 then
            RconPrint("usage: havoc_gamemode [nom_mode]\n")
            return
        end

        if not gametypes[args[1]] then
            RconPrint('Mode de jeu inexistant: ' .. args[1] .. "\n")
            CancelEvent()
            return
        end

        changeGameType(args[1])
        RconPrint('Mode de jeu changé pour: ' .. args[1] .. "\n")
        CancelEvent()
    end
end)