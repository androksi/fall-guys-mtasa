function syncCountdown(player, status)
    triggerClientEvent(player, "countdown:sync", resourceRoot, status)
end