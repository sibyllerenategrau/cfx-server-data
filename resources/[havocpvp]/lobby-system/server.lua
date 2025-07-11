-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Système de lobby côté serveur

-- Stockage des gamemodes disponibles
local availableGamemodes = {}

-- Fonction pour rafraîchir les gamemodes disponibles
local function refreshGamemodes()
    availableGamemodes = {}
    local numResources = GetNumResources()

    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        local resourceType = GetResourceMetadata(resource, 'resource_type', 0)
        
        if resourceType == 'gametype' then
            local extraData = GetResourceMetadata(resource, 'resource_type_extra', 0)
            local gameTypeData = {}
            
            if extraData then
                gameTypeData = json.decode(extraData)
            end
            
            table.insert(availableGamemodes, {
                id = resource,
                name = gameTypeData.name or resource,
                description = gameTypeData.description or 'Mode de jeu HavocPvP'
            })
        end
    end
end

-- Événement pour demander la liste des gamemodes
RegisterNetEvent('havocpvp:requestGamemodes')
AddEventHandler('havocpvp:requestGamemodes', function()
    local source = source
    refreshGamemodes()
    TriggerClientEvent('havocpvp:receiveGamemodes', source, availableGamemodes)
end)

-- Rafraîchir au démarrage et lors du refresh des ressources
AddEventHandler('onResourceListRefresh', function()
    refreshGamemodes()
end)

refreshGamemodes()

-- Log des gamemodes détectés
CreateThread(function()
    Wait(1000) -- Attendre que tout soit chargé
    refreshGamemodes()
    print('HavocPvP Lobby - Gamemodes détectés:')
    for _, gamemode in ipairs(availableGamemodes) do
        print('  - ' .. gamemode.name .. ' (' .. gamemode.id .. ')')
    end
end)