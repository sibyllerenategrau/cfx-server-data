-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Client du gamemode basique

AddEventHandler('onClientMapStart', function()
  -- Activer le spawn automatique quand une carte démarre
  exports.spawnmanager:setAutoSpawn(true)
  exports.spawnmanager:forceRespawn()
end)
