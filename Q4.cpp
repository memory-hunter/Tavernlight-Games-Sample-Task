// Q4

void Game::addItemToPlayer(const std::string &recipient, uint16_t itemId) {
    std::unique_ptr<Player> player;
    if (!g_game.getPlayerByName(recipient)) {
        player = std::make_unique<Player>(nullptr);
        if (!IOLoginData::loadPlayerByName(player.get(), recipient)) {
            return;
        }
    } else {
        player = std::make_unique<Player>(g_game.getPlayerByName(recipient));
    }
    
    Item *item = Item::CreateItem(itemId);
    if (!item) {
        return;
    }
    
    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
    
    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }
}