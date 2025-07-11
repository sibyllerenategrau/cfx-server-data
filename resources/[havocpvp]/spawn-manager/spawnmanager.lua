-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Gestionnaire de points de spawn en mémoire pour cette instance de script

-- Tableau des points de spawn en mémoire pour cette exécution
local spawnPoints = {}

-- Indicateur de spawn automatique activé
local autoSpawnEnabled = false
local autoSpawnCallback

-- Support pour les cartes mapmanager
AddEventHandler('getMapDirectives', function(add)
    -- Appeler le callback distant
    add('spawnpoint', function(state, model)
        -- Retourner un autre callback pour passer les coordonnées et ainsi de suite
        return function(opts)
            local x, y, z, heading

            local s, e = pcall(function()
                -- Est-ce une map ou un tableau?
                if opts.x then
                    x = opts.x
                    y = opts.y
                    z = opts.z
                else
                    x = opts[1]
                    y = opts[2]
                    z = opts[3]
                end

                x = x + 0.0001
                y = y + 0.0001
                z = z + 0.0001

                -- Obtenir une direction et la forcer en float, ou par défaut null
                heading = opts.heading and (opts.heading + 0.01) or 0

                -- Ajouter le point de spawn
                addSpawnPoint({
                    x = x, y = y, z = z,
                    heading = heading,
                    model = model
                })

                -- Recalculer le modèle pour le stockage
                if not tonumber(model) then
                    model = GetHashKey(model, _r)
                end

                -- Stocker les données de spawn dans l'état pour pouvoir les effacer plus tard
                state.add('xyz', { x, y, z })
                state.add('model', model)
            end)

            if not s then
                Citizen.Trace(e .. "\n")
            end
        end
        -- Le callback de suppression suit sur la ligne suivante
    end, function(state, arg)
        -- Parcourir tous les points de spawn pour en trouver un avec notre état
        for i, sp in ipairs(spawnPoints) do
            -- S'il correspond...
            if sp.x == state.xyz[1] and sp.y == state.xyz[2] and sp.z == state.xyz[3] and sp.model == state.model then
                -- Le supprimer.
                table.remove(spawnPoints, i)
                return
            end
        end
    end)
end)

-- Charge un ensemble de points de spawn à partir d'une chaîne JSON
function loadSpawns(spawnString)
    -- Décoder la chaîne JSON
    local data = json.decode(spawnString)

    -- Avons-nous un champ 'spawns'?
    if not data.spawns then
        error("pas de 'spawns' dans les données JSON")
    end

    -- Parcourir les spawns
    for i, spawn in ipairs(data.spawns) do
        -- Et l'ajouter à la liste (en validant au passage)
        addSpawnPoint(spawn)
    end
end

local spawnNum = 1

function addSpawnPoint(spawn)
    -- Valider le spawn (position)
    if not tonumber(spawn.x) or not tonumber(spawn.y) or not tonumber(spawn.z) then
        error("position de spawn invalide")
    end

    -- Direction
    if not tonumber(spawn.heading) then
        error("direction de spawn invalide")
    end

    -- Modèle (essayer entier d'abord, sinon, le hasher)
    local model = spawn.model

    if not tonumber(spawn.model) then
        model = GetHashKey(spawn.model)
    end

    -- Le modèle est-il vraiment un modèle?
    if not IsModelInCdimage(model) then
        error("modèle de spawn invalide")
    end

    -- Réécrire le modèle au cas où nous l'aurions hashé
    spawn.model = model

    -- Ajouter un index
    spawn.idx = spawnNum
    spawnNum = spawnNum + 1

    -- Tout est OK, ajouter l'entrée de spawn à la liste
    table.insert(spawnPoints, spawn)

    return spawn.idx
end

-- Supprime un point de spawn
function removeSpawnPoint(spawn)
    for i = 1, #spawnPoints do
        if spawnPoints[i].idx == spawn then
            table.remove(spawnPoints, i)
            return
        end
    end
end

-- Change l'indicateur de spawn automatique
function setAutoSpawn(enabled)
    autoSpawnEnabled = enabled
end

-- Définit un callback à exécuter au lieu du spawn 'natif' lors de la tentative de spawn automatique
function setAutoSpawnCallback(cb)
    autoSpawnCallback = cb
    autoSpawnEnabled = true
end

-- Fonction comme existant dans les scripts R* originaux
local function freezePlayer(id, freeze)
    local player = id
    SetPlayerControl(player, not freeze, false)

    local ped = GetPlayerPed(player)

    if not freeze then
        if not IsEntityVisible(ped) then
            SetEntityVisible(ped, true)
        end

        if not IsPedInAnyVehicle(ped) then
            SetEntityCollision(ped, true)
        end

        FreezeEntityPosition(ped, false)
        SetPlayerInvincible(player, false)
    else
        if IsEntityVisible(ped) then
            SetEntityVisible(ped, false)
        end

        SetEntityCollision(ped, false)
        FreezeEntityPosition(ped, true)
        SetPlayerInvincible(player, true)

        if not IsPedFatallyInjured(ped) then
            ClearPedTasksImmediately(ped)
        end
    end
end

function loadScene(x, y, z)
    if not NewLoadSceneStart then
        return
    end

    NewLoadSceneStart(x, y, z, 0.0, 0.0, 0.0, 20.0, 0)

    while IsNewLoadSceneActive() do
        networkTimer = GetNetworkTimer()
        NetworkUpdateLoadScene()
    end
end

-- Pour éviter d'essayer de spawn plusieurs fois
local spawnLock = false

-- Spawne le joueur actuel à un certain index de point de spawn (ou un aléatoire)
function spawnPlayer(spawnIdx, cb)
    if spawnLock then
        return
    end

    spawnLock = true

    CreateThread(function()
        -- Si le spawn n'est pas défini, en sélectionner un aléatoire
        if not spawnIdx then
            spawnIdx = GetRandomIntInRange(1, #spawnPoints + 1)
        end

        -- Obtenir le spawn du tableau
        local spawn

        if type(spawnIdx) == 'table' then
            spawn = spawnIdx

            -- Prévenir les erreurs lors du passage du tableau de spawn
            spawn.x = spawn.x + 0.00
            spawn.y = spawn.y + 0.00
            spawn.z = spawn.z + 0.00

            spawn.heading = spawn.heading and (spawn.heading + 0.00) or 0
        else
            spawn = spawnPoints[spawnIdx]
        end

        if not spawn.skipFade then
            DoScreenFadeOut(500)

            while not IsScreenFadedOut() do
                Wait(0)
            end
        end

        -- Valider l'index
        if not spawn then
            Citizen.Trace("tentative de spawn à un index de spawn invalide\n")
            spawnLock = false
            return
        end

        -- Geler le joueur local
        freezePlayer(PlayerId(), true)

        -- Si le spawn a un modèle défini
        if spawn.model then
            RequestModel(spawn.model)

            -- Charger le modèle pour ce spawn
            while not HasModelLoaded(spawn.model) do
                RequestModel(spawn.model)
                Wait(0)
            end

            -- Changer le modèle du joueur
            SetPlayerModel(PlayerId(), spawn.model)

            -- Libérer le modèle du joueur
            SetModelAsNoLongerNeeded(spawn.model)
            
            -- Bits de modèle de joueur RDR3
            if N_0x283978a15512b2fe then
                N_0x283978a15512b2fe(PlayerPedId(), true)
            end
        end

        -- Précharger les collisions pour le point de spawn
        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)

        -- Spawner le joueur
        local ped = PlayerPedId()

        -- V nécessite de définir les coordonnées aussi
        SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
        NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.heading, true, true, false)

        -- Nettoyage de style gamelogic
        ClearPedTasksImmediately(ped)
        RemoveAllPedWeapons(ped)
        ClearPlayerWantedLevel(PlayerId())

        local time = GetGameTimer()

        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 5000) do
            Wait(0)
        end

        ShutdownLoadingScreen()

        if IsScreenFadedOut() then
            DoScreenFadeIn(500)

            while not IsScreenFadedIn() do
                Wait(0)
            end
        end

        -- Et dégeler le joueur
        freezePlayer(PlayerId(), false)

        TriggerEvent('playerSpawned', spawn)

        if cb then
            cb(spawn)
        end

        spawnLock = false
    end)
end

-- Thread de surveillance du spawn automatique aussi
local respawnForced
local diedAt

CreateThread(function()
    -- Boucle principale
    while true do
        Wait(50)

        local playerPed = PlayerPedId()

        if playerPed and playerPed ~= -1 then
            -- Vérifier si nous voulons l'autospawn
            if autoSpawnEnabled then
                if NetworkIsPlayerActive(PlayerId()) then
                    if (diedAt and (math.abs(GetTimeDifference(GetGameTimer(), diedAt)) > 2000)) or respawnForced then
                        if autoSpawnCallback then
                            autoSpawnCallback()
                        else
                            spawnPlayer()
                        end

                        respawnForced = false
                    end
                end
            end

            if IsEntityDead(playerPed) then
                if not diedAt then
                    diedAt = GetGameTimer()
                end
            else
                diedAt = nil
            end
        end
    end
end)

function forceRespawn()
    spawnLock = false
    respawnForced = true
end

-- Exports pour l'utilisation par d'autres ressources
exports('spawnPlayer', spawnPlayer)
exports('addSpawnPoint', addSpawnPoint)
exports('removeSpawnPoint', removeSpawnPoint)
exports('loadSpawns', loadSpawns)
exports('setAutoSpawn', setAutoSpawn)
exports('setAutoSpawnCallback', setAutoSpawnCallback)
exports('forceRespawn', forceRespawn)