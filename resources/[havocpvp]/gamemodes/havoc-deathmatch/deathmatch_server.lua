-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Mode Deathmatch côté serveur

-- Statistiques des joueurs
local playerStats = {}

-- Configuration du Deathmatch
local dmConfig = {
    respawnTime = 3000, -- 3 secondes
    maxKills = 25, -- Score pour gagner
    roundTime = 600 -- 10 minutes par round
}

-- Variables du match
local matchActive = false
local matchStartTime = 0
local leaderboard = {}

-- Gestion des joueurs connectés
AddEventHandler('playerConnecting', function()
    local source = source
    playerStats[source] = {
        kills = 0,
        deaths = 0,
        ratio = 0.0,
        currentStreak = 0,
        bestStreak = 0
    }
end)

-- Gestion des joueurs déconnectés
AddEventHandler('playerDropped', function()
    local source = source
    playerStats[source] = nil
    updateLeaderboard()
end)

-- Événement de mort d'un joueur
RegisterNetEvent('havocpvp:deathmatch:playerDied')
AddEventHandler('havocpvp:deathmatch:playerDied', function(killerType)
    local source = source
    if playerStats[source] then
        playerStats[source].deaths = playerStats[source].deaths + 1
        playerStats[source].currentStreak = 0
        
        -- Calculer le nouveau ratio
        local kills = playerStats[source].kills
        local deaths = playerStats[source].deaths
        playerStats[source].ratio = deaths > 0 and (kills / deaths) or kills
        
        -- Respawn avec délai
        SetTimeout(dmConfig.respawnTime, function()
            TriggerClientEvent('havocpvp:deathmatch:forceRespawn', source)
        end)
        
        updateLeaderboard()
    end
end)

-- Événement d'élimination
RegisterNetEvent('havocpvp:deathmatch:playerKill')
AddEventHandler('havocpvp:deathmatch:playerKill', function()
    local source = source
    if playerStats[source] then
        playerStats[source].kills = playerStats[source].kills + 1
        playerStats[source].currentStreak = playerStats[source].currentStreak + 1
        
        -- Nouveau meilleur streak?
        if playerStats[source].currentStreak > playerStats[source].bestStreak then
            playerStats[source].bestStreak = playerStats[source].currentStreak
        end
        
        -- Calculer le nouveau ratio
        local kills = playerStats[source].kills
        local deaths = playerStats[source].deaths
        playerStats[source].ratio = deaths > 0 and (kills / deaths) or kills
        
        -- Notifications de streak
        local streak = playerStats[source].currentStreak
        if streak >= 5 and streak % 5 == 0 then
            TriggerClientEvent('chatMessage', -1, 'HavocPvP Deathmatch', {255, 0, 0}, 
                GetPlayerName(source) .. ' est en série de ' .. streak .. ' éliminations!')
        end
        
        -- Vérifier la victoire
        if playerStats[source].kills >= dmConfig.maxKills then
            endMatch(source)
        end
        
        updateLeaderboard()
    end
end)

-- Événement pour obtenir les stats
RegisterNetEvent('havocpvp:deathmatch:getStats')
AddEventHandler('havocpvp:deathmatch:getStats', function()
    local source = source
    if playerStats[source] then
        local stats = playerStats[source]
        TriggerClientEvent('havocpvp:deathmatch:receiveStats', source, 
            stats.kills, stats.deaths, stats.ratio)
    end
end)

-- Fonction pour mettre à jour le classement
function updateLeaderboard()
    leaderboard = {}
    for playerId, stats in pairs(playerStats) do
        table.insert(leaderboard, {
            id = playerId,
            name = GetPlayerName(playerId),
            kills = stats.kills,
            deaths = stats.deaths,
            ratio = stats.ratio,
            streak = stats.currentStreak
        })
    end
    
    -- Trier par nombre d'éliminations puis par ratio
    table.sort(leaderboard, function(a, b)
        if a.kills == b.kills then
            return a.ratio > b.ratio
        end
        return a.kills > b.kills
    end)
end

-- Fonction pour terminer un match
function endMatch(winnerId)
    if not matchActive then return end
    
    matchActive = false
    local winnerName = GetPlayerName(winnerId)
    
    -- Annonce du gagnant
    TriggerClientEvent('chatMessage', -1, 'HavocPvP Deathmatch', {255, 215, 0}, 
        '🏆 ' .. winnerName .. ' remporte le match avec ' .. dmConfig.maxKills .. ' éliminations!')
    
    -- Afficher le classement final
    showFinalLeaderboard()
    
    -- Redémarrer le match après 30 secondes
    SetTimeout(30000, function()
        startNewMatch()
    end)
end

-- Fonction pour afficher le classement final
function showFinalLeaderboard()
    updateLeaderboard()
    
    TriggerClientEvent('chatMessage', -1, 'Classement Final', {255, 107, 53}, '=== TOP 5 ===')
    
    for i = 1, math.min(5, #leaderboard) do
        local player = leaderboard[i]
        local medal = i == 1 and '🥇' or (i == 2 and '🥈' or (i == 3 and '🥉' or ''))
        
        TriggerClientEvent('chatMessage', -1, 'Classement', {255, 255, 255}, 
            string.format('%s %d. %s - %d éliminations (Ratio: %.2f)', 
                medal, i, player.name, player.kills, player.ratio))
    end
end

-- Fonction pour démarrer un nouveau match
function startNewMatch()
    -- Réinitialiser les stats
    for playerId, _ in pairs(playerStats) do
        playerStats[playerId] = {
            kills = 0,
            deaths = 0,
            ratio = 0.0,
            currentStreak = 0,
            bestStreak = 0
        }
    end
    
    matchActive = true
    matchStartTime = GetGameTimer()
    
    TriggerClientEvent('chatMessage', -1, 'HavocPvP Deathmatch', {255, 107, 53}, 
        'Nouveau match démarré! Premier à ' .. dmConfig.maxKills .. ' éliminations!')
    
    updateLeaderboard()
end

-- Commande admin pour démarrer un match
RegisterCommand('start_dm', function(source, args, rawCommand)
    if source == 0 then -- Console seulement
        startNewMatch()
        print('Match Deathmatch démarré par un administrateur')
    end
end, true)

-- Commande pour voir le classement
RegisterCommand('leaderboard', function(source, args, rawCommand)
    updateLeaderboard()
    
    TriggerClientEvent('chatMessage', source, 'Classement Actuel', {255, 107, 53}, '=== TOP 5 ===')
    
    for i = 1, math.min(5, #leaderboard) do
        local player = leaderboard[i]
        TriggerClientEvent('chatMessage', source, 'Classement', {255, 255, 255}, 
            string.format('%d. %s - %d éliminations (Ratio: %.2f)', 
                i, player.name, player.kills, player.ratio))
    end
end, false)

-- Démarrer un match automatiquement quand le gamemode se lance
CreateThread(function()
    Wait(5000) -- Attendre 5 secondes après le démarrage
    startNewMatch()
end)