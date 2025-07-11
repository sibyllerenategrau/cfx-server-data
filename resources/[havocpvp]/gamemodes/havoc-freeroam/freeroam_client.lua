-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Mode FreeRoam côté client

AddEventHandler('onClientMapStart', function()
    -- Activer le spawn automatique quand une carte démarre
    exports['spawn-manager']:setAutoSpawn(true)
    exports['spawn-manager']:forceRespawn()
end)

-- Gestion des propriétés du joueur en FreeRoam
AddEventHandler('playerSpawned', function(spawnInfo)
    local ped = PlayerPedId()
    
    -- Configurer la santé du joueur
    SetEntityHealth(ped, 200) -- Santé par défaut
    SetPedArmour(ped, 0) -- Pas d'armure par défaut
    
    -- Supprimer toutes les armes
    RemoveAllPedWeapons(ped, true)
    
    -- Notification de spawn
    TriggerEvent('chatMessage', 'HavocPvP', {255, 107, 53}, 'Vous êtes spawné en mode FreeRoam!')
end)

-- Commande pour se suicider (respawn)
RegisterCommand('kill', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 0)
end, false)

-- Commande pour obtenir des armes basiques
RegisterCommand('armes', function()
    local ped = PlayerPedId()
    
    -- Armes basiques pour FreeRoam
    GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 150, false, true)
    GiveWeaponToPed(ped, GetHashKey('WEAPON_SMG'), 300, false, false)
    
    TriggerEvent('chatMessage', 'HavocPvP', {255, 107, 53}, 'Armes ajoutées!')
end, false)