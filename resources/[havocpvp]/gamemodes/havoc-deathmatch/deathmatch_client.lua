-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Mode Deathmatch côté client

AddEventHandler('onClientMapStart', function()
    -- Activer le spawn automatique avec respawn rapide
    exports['spawn-manager']:setAutoSpawn(true)
    exports['spawn-manager']:forceRespawn()
end)

-- Configuration spécifique au Deathmatch
AddEventHandler('playerSpawned', function(spawnInfo)
    local ped = PlayerPedId()
    
    -- Configurer la santé et l'armure pour le combat
    SetEntityHealth(ped, 200) -- Santé maximale
    SetPedArmour(ped, 100) -- Armure complète
    
    -- Équipement de combat complet
    GiveWeaponToPed(ped, GetHashKey('WEAPON_CARBINERIFLE'), 300, false, true) -- Arme principale
    GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 150, false, false) -- Arme secondaire
    GiveWeaponToPed(ped, GetHashKey('WEAPON_GRENADE'), 5, false, false) -- Grenades
    GiveWeaponToPed(ped, GetHashKey('WEAPON_KNIFE'), 1, false, false) -- Couteau
    
    -- Notification de spawn
    TriggerEvent('chatMessage', 'HavocPvP Deathmatch', {255, 0, 0}, 'Prêt au combat! Éliminez vos adversaires!')
    
    -- Afficher les stats
    TriggerServerEvent('havocpvp:deathmatch:getStats')
end)

-- Gérer la mort en Deathmatch
AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
    -- Notifier le serveur de la mort
    TriggerServerEvent('havocpvp:deathmatch:playerDied', killerType)
end)

-- Gérer l'élimination d'un adversaire
AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
    if killerId == PlayerId() then
        -- Le joueur a fait une élimination
        TriggerServerEvent('havocpvp:deathmatch:playerKill')
        TriggerEvent('chatMessage', 'HavocPvP', {255, 107, 53}, '+1 Élimination!')
    end
end)

-- Recevoir les statistiques
RegisterNetEvent('havocpvp:deathmatch:receiveStats')
AddEventHandler('havocpvp:deathmatch:receiveStats', function(kills, deaths, ratio)
    local ratioText = deaths > 0 and string.format("%.2f", ratio) or "Perfect"
    TriggerEvent('chatMessage', 'Stats Deathmatch', {255, 107, 53}, 
        string.format('Éliminations: %d | Morts: %d | Ratio: %s', kills, deaths, ratioText))
end)

-- Commande pour voir ses stats
RegisterCommand('stats_dm', function()
    TriggerServerEvent('havocpvp:deathmatch:getStats')
end, false)

-- Commande pour le suicide tactical
RegisterCommand('suicide', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 0)
    TriggerEvent('chatMessage', 'HavocPvP', {255, 107, 53}, 'Suicide tactical - respawn incoming!')
end, false)

-- Interface HUD simplifiée pour le combat
CreateThread(function()
    while true do
        Wait(0)
        
        -- Cacher certains éléments HUD pour une expérience plus clean
        HideHudComponentThisFrame(6)  -- Vehicle name
        HideHudComponentThisFrame(7)  -- Area name
        HideHudComponentThisFrame(8)  -- Vehicle class
        HideHudComponentThisFrame(9)  -- Street name
    end
end)