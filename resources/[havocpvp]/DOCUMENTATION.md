# HavocPvP - Documentation du Système de Gamemode

Cette documentation explique comment utiliser le nouveau système de gamemode HavocPvP qui sépare les cartes des modes de jeu et inclut un système de lobby.

## Structure du Système

### Resources principales:
- `[havocpvp]/gamemode-manager/` - Gestionnaire principal des modes de jeu
- `[havocpvp]/lobby-system/` - Interface de sélection des gamemodes
- `[havocpvp]/spawn-manager/` - Gestionnaire de spawn amélioré
- `[havocpvp]/gamemodes/` - Dossier contenant les modes de jeu
- `[havocpvp]/maps/` - Dossier contenant les cartes

## Fonctionnement

### 1. Connexion des Joueurs
Quand un joueur se connecte:
1. Il spawn automatiquement dans le lobby
2. Le menu de sélection des gamemodes s'affiche
3. Il peut choisir un mode de jeu disponible
4. Une fois sélectionné, il est téléporté selon les règles du gamemode

### 2. Système de Lobby
- Interface NUI moderne avec design HavocPvP
- Affichage de tous les gamemodes disponibles
- Sélection par clic
- Fermeture avec ESC ou bouton
- Commande `/havoc_lobby` pour rouvrir

### 3. Gestion des Gamemodes
- Détection automatique des ressources de type 'gametype'
- Support des cartes séparées
- Gestion des spawns par gamemode
- Statistiques des joueurs

## Configuration

### Position du Lobby
Modifiez dans `gamemode-manager/shared.lua`:
```lua
Config = {
    LobbyPosition = {
        x = -1042.0,  -- Coordonnée X
        y = -2745.0,  -- Coordonnée Y
        z = 21.36,    -- Coordonnée Z
        heading = 0.0 -- Direction
    }
}
```

### Création d'un nouveau Gamemode
1. Créer un dossier dans `[havocpvp]/gamemodes/`
2. Ajouter un `fxmanifest.lua` avec:
```lua
resource_type 'gametype' { 
    name = 'Nom du Mode',
    description = 'Description du mode'
}
```
3. Implémenter la logique client/serveur

### Création d'une nouvelle Carte
1. Créer un dossier dans `[havocpvp]/maps/`
2. Ajouter un `fxmanifest.lua` avec:
```lua
resource_type 'map' { 
    gameTypes = { 
        ['nom-gamemode'] = true 
    },
    name = 'Nom de la Carte'
}
```
3. Créer un fichier `map.lua` avec les spawnpoints

## Commandes Disponibles

### Joueurs:
- `/lobby` - Ouvrir le menu de sélection des gamemodes
- `/kill` - Se suicider (respawn)
- `/armes` - Obtenir des armes (en FreeRoam)
- `/stats` - Voir les statistiques du serveur

### Administrateurs (RCON):
- `havoc_map [nom_carte]` - Changer de carte
- `havoc_gamemode [nom_mode]` - Changer de gamemode
- `armor [joueur] [quantité]` - Donner de l'armure

## Exemples Inclus

### Gamemode: havoc-freeroam
- Mode de jeu libre
- Spawn automatique
- Armes basiques disponibles
- Gestion de la santé et armure

### Carte: havoc-map-city
- Points de spawn dans Los Santos
- Compatible avec havoc-freeroam
- Véhicules de test inclus

## Intégration avec l'Existant

Le système est compatible avec:
- Les cartes existantes (fivem-map-*)
- Le basic-gamemode (modifié)
- Les spawnpoints traditionnels

## Démarrage du Système

Ajoutez ces ressources à votre server.cfg:
```
start gamemode-manager
start lobby-system  
start spawn-manager
start havoc-freeroam
start havoc-map-city
```

L'ordre de démarrage est important pour assurer le bon fonctionnement.

## Support

Ce système a été développé pour HavocPvP. Pour toute question ou problème, consultez la documentation technique dans chaque ressource.

---
*Système développé par HavocPvP - Basé sur les ressources originales de Cfx.re*