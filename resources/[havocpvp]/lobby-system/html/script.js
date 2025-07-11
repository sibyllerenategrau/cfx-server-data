// Script JavaScript pour le lobby HavocPvP

let currentGamemodes = [];

// Fonction pour afficher/masquer le lobby
function toggleLobby(show) {
    const container = document.getElementById('lobbyContainer');
    if (show) {
        container.classList.remove('hidden');
    } else {
        container.classList.add('hidden');
    }
}

// Fonction pour mettre à jour la liste des gamemodes
function updateGamemodeList(gamemodes) {
    currentGamemodes = gamemodes;
    const list = document.getElementById('gamemodeList');
    list.innerHTML = '';
    
    if (!gamemodes || gamemodes.length === 0) {
        list.innerHTML = '<div class="no-gamemodes">Aucun mode de jeu disponible</div>';
        return;
    }
    
    gamemodes.forEach(gamemode => {
        const item = document.createElement('div');
        item.className = 'gamemode-item';
        item.innerHTML = `
            <h3>${gamemode.name || gamemode.id}</h3>
            <p>${gamemode.description || 'Mode de jeu HavocPvP'}</p>
        `;
        
        item.addEventListener('click', () => {
            selectGamemode(gamemode.id);
        });
        
        list.appendChild(item);
    });
}

// Fonction pour sélectionner un gamemode
function selectGamemode(gamemodeId) {
    // Envoyer au client FiveM
    fetch(`https://${GetParentResourceName()}/selectGamemode`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            gamemode: gamemodeId
        })
    });
}

// Fonction pour fermer le lobby
function closeLobby() {
    fetch(`https://${GetParentResourceName()}/closeLobby`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

// Gestionnaire d'événements pour les messages NUI
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openLobby':
            toggleLobby(true);
            if (data.gamemodes) {
                updateGamemodeList(data.gamemodes);
            }
            break;
            
        case 'closeLobby':
            toggleLobby(false);
            break;
            
        case 'updateGamemodes':
            updateGamemodeList(data.gamemodes);
            break;
    }
});

// Gestionnaire pour le bouton fermer
document.addEventListener('DOMContentLoaded', function() {
    const closeBtn = document.getElementById('closeBtn');
    if (closeBtn) {
        closeBtn.addEventListener('click', closeLobby);
    }
    
    // Fermer avec Escape
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeLobby();
        }
    });
});

// Fonction pour obtenir le nom de la ressource parent
function GetParentResourceName() {
    return 'lobby-system';
}