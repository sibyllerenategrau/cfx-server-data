-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Mode FreeRoam côté serveur

-- Gestion des joueurs connectés
local players = {}

-- Événement de connexion d'un joueur
AddEventHandler('playerConnecting', function()
    local source = source
    players[source] = {
        gamemode = 'havoc-freeroam',
        health = 200,
        armor = 0,
        spawnCount = 0
    }
end)

-- Événement de déconnexion d'un joueur
AddEventHandler('playerDropped', function()
    local source = source
    players[source] = nil
end)

-- Événement de spawn d'un joueur
AddEventHandler('playerSpawned', function(spawnInfo)
    local source = source
    if players[source] then
        players[source].spawnCount = players[source].spawnCount + 1
        
        -- Log du spawn
        print(string.format('Joueur %d spawné en FreeRoam (spawn #%d)', 
            source, players[source].spawnCount))
    end
end)

-- Commande admin pour donner de l'armure
RegisterCommand('armor', function(source, args, rawCommand)
    if source == 0 then -- Console seulement
        local targetPlayer = tonumber(args[1])
        local armorAmount = tonumber(args[2]) or 100
        
        if targetPlayer and players[targetPlayer] then
            TriggerClientEvent('havocpvp:setArmor', targetPlayer, armorAmount)
            print(string.format('Armure (%d) donnée au joueur %d', armorAmount, targetPlayer))
        end
    end
end, true)

-- Événement pour définir l'armure d'un joueur
RegisterNetEvent('havocpvp:setArmor')
AddEventHandler('havocpvp:setArmor', function(amount)
    local source = source
    TriggerClientEvent('havocpvp:setArmor', source, amount)
end)

-- Commande pour obtenir les statistiques du serveur
RegisterCommand('stats', function(source, args, rawCommand)
    local playerCount = 0
    for _ in pairs(players) do
        playerCount = playerCount + 1
    end
    
    TriggerClientEvent('chatMessage', source, 'HavocPvP Stats', {255, 107, 53}, 
        string.format('Joueurs connectés: %d | Mode: FreeRoam', playerCount))
end, false)