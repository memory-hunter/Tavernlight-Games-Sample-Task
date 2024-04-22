# Tavernlight Games Sample Task - Daviti Petriashvili

## Notes before you start

The whole `README.md` is made in Obsidian, so I made it comfortable for you to read the whole task comments, codes, photos and videos in one place. Separate code implementations and videos themselves are in the folder accordingly named through `Q5` through `Q7`. You can also see the `.lua` file for `Q1-3` and `.cpp` for the `Q4`.

### Q1

- I don't see a good reason to define the additional function for calling a setter.
- Per TFS documentation, the `addEvent` function calls a function after some time, with passed arguments after the 3rd position. I don't see a reason why should I delay the call for 1 second.
- `onLogout` seems to be a callback-like function, so it returning anything doesn't make any sense. If the setter returned something (which it doesn't, per documentation) as like a status whether the setting failed or not, then it would make sense this function return something accordingly.
- For safety, I'll check for `nil` so we don't get any undefined behaviour.

Final piece of code:

``` lua
function onLogout(player)
    local value = player:getStorageValue(1000)
    if value ~= nil and value == 1 then
        player:setStorageValue(1000, -1)
    end
end
```

### Q2

- To get familiar with how database functions worked, I looked at some files in `TFS` files, which used a `storeQuery` function, and implemented the functions in that fashion.
- I'd rather save the formatted string for cleaner code (in my honest opinion).
- There was no error handling or empty result handling.
- If the result somehow existed, the function call to get the string is missing the `resultId` as the argument to get the string from somewhere.
- It would only get one name as there is no repetition or a loop statement to print many.
- The query isn't freed if it returns not `false`.

Final piece of code:

``` lua
function printSmallGuildNames(memberCount)
    local selectGuildQuery = string.format("SELECT name FROM guilds WHERE max_members < %d;", memberCount)
    
    local resultId = db.storeQuery(selectGuildQuery)
    if resultId ~= false then
        repeat
            local guildName = result.getString(resultId, "name")
            print(guildName)
        until not result.next(resultId)
        result.free(resultId)
    end
end
```

### Q3

- Camel case in the previous naming conventions, here as well.
- The function is not named accordingly to what it does. Let's name it `removePlayerFromParty` as it does just that.
- Algorithm runs in O(n), and we are using a table as it seems, hence the `k, v`. We are completely missing the point of using a table. Let's use its power as intended and simply retrieve the item in O(1).
- I was quite confused by the fact that the `player` wasn't even being used. So, then there is this different use of using the `memebername`. I assumed best implementation as I would do it:
  - There would be a player class of some sort, which has its `name` getter function `getName()` (TFS documentation has mentions of `getName()` for players)
  - The member table is implemented in a fashion where the `name` is the key and a player object is the value.
    So, therefore, the `Player` would retrieve the player, and from that, I would get the name, store party for removal function call, and simply store the value which I may or may not find in the table.

Final piece of code:

``` lua
function removePlayerFromParty(playerId)
    local party = player:getParty()
    local playerName = Player(playerId):getName()
    local member = party:getMembers()[playerName]

    if member ~= nil then
    party:removeMember(playerName)
    end
end
```

### Q4

- I took a look at the source code of TFS, and since it had uses of smart pointers, I allowed myself to use them as well to make it easy so we don't have to chase pointers around. `unique_ptr` makes sure that when the function scope is left, the pointers gets destroyed because the owner amount will go to 0.

Final piece of code:

``` cpp
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
```
<hr>

I had some trouble setting up but forums came in handy and I got setup fully.

Game runs and I can login with 10.98 client. Here is a test screenshot:

![Pasted image 20240420194405.png](Tavernlight%20Games%20Sample%20Task-media/0ad4b74ea1803d3f15bd9e08aa31a61f69afe152.png "wikilink")

### Q5

First, I checked the fandom wiki for Tibia, searched for a spell which had `frigo` in it, and found [Eternal Winter](tibia.fandom.com/wiki/Eternal_Winter), which is the attack alike the one I should implement and base on.
I looked the Lua scripts in the server files, and first, find where attack spells are saved. I searched for `frigo` and found and XML file and then the spell Lua files themselves, saw how the spells and areas were defined and started implementing.

I wanted to test out the same pattern that was shown in the video, and understood how the area matrix in the `/data/spells/lib/spells.lua` worked. Checked the forums to understand what the numbers represented:
- 1 - damage block.
- 2 - player position.
- 3 - player position + self damage.

Wrote down the matrix but the rendering didn't work as expected. Then, I searched for that problem and a [forum entry](https://otland.net/threads/issue-on-the-animation-of-eternal-winter.281595/) explained the rendering problem as I had. They said to switch to a [newer fork](https://github.com/mehah/otclient) of the OTClient, which was based on the one you linked in the email. After building that client, the rendering worked as expected. I am getting the matrix I defined the way I wanted it.

![Pasted image 20240421153757.png](Tavernlight%20Games%20Sample%20Task-media/a898aa8adfb604f767e2ab2871c1b0c282d32468.png "wikilink")

Now, I will try to animate and swap out areas of attack to fit the given question pattern.

A [handy](https://otland.net/threads/tfs-1-x-animated-spells-dynamic-vs-static.268186/) forum post explained nicely how to "animate" spells. Looks like `addEvent` is the trick. We can't have spell animations go "frame by frame", but rather, we delay the calls to each area attack matrix.

I conveniently used a tool called [SpellCreator](https://otland.net/threads/spellcreator-a-graphical-spell-creation-enviroment.160371/) linked in the [documentation](https://docs.opentibiabr.com/opentibiabr/downloads/tools/editors) of OpenTibia to manually draw patterns instead of painstakingly correcting the matrix. I got the matrices from there and finally, the animation is created. I observed the video given frame by frame and approximated the animations. Looks like it looks approximately 3 times.

Here is the animation:

https://github.com/memory-hunter/Tavernlight-Games-Sample-Task/assets/59766692/2b8f0918-b9b5-4207-a74a-35209de900a2


### Q6
###### TODO

### Q7

Since this is some GUI related thing, I now direct my attention to the Client files, rather than the Server files.

Unfortunately, not a lot of documentation in the Wiki of the client repository. But luckily, there is the code itself and the forums. Funnily enough, [a post](https://otland.net/threads/otclient-documentation.272997/) on the forum complains exactly about that. No documentation on the `cpp` or `lua` modules.

I am planning to put some button which will open a window to have that "Jump" button moving around. Top menu looks like a good place to start. I look in the files and find that there is a module for top menu and others may add their buttons into that. I will copy that kind of implementation.

I then check the client repository to find a wiki entry about module making. I am going to follow that. At least there is that...

I successfully made base module and checked through terminal with `about_modules` and it was loaded.

![Pasted image 20240422132801.png](Tavernlight%20Games%20Sample%20Task-media/791166bcba6b1410aa5516f980600b3541e057fe.png "wikilink")

I looked at the Options module to know how to properly populate the top menu with my toggle `Jumpie` module. Followed the same principle, and quickly made a custom icon to distinguish. And here it is!


![Pasted image 20240422132840.png](Tavernlight%20Games%20Sample%20Task-media/1dbf23251bc9e45570b02e1d82ef2515463c4ca1.png "wikilink")

Now, I have to get a window going on with the button inside. I look no further than the wiki and see that those things are defined in a child-parent relation (neat!) in the `.otui` file. I define a button and we get the button. And the button appears!

![Pasted image 20240422141512.png](Tavernlight%20Games%20Sample%20Task-media/a86fbce1f59e81decf82cda554125f2a594b7c94.png "wikilink")

I moved the window around, and looks like there are certain margins the button floats around within the window. I wanted to know how big those margins were.

To get things animated and all that, first, I want to define the `@onClick` action to place the button on some random height within the window.

I have no idea of the functions the window may provide, but because Lua has a simplistic implementation of things, I used this piece of code to print all available methods to use, so then I can choose what to use and how to move.

``` lua
for key,value in pairs(getmetatable(jumpieWindow)) do
        elseif key == 'methods' then
            for key2,value2 in pairs(value) do
                pcolored("found method " .. key2)
            end
        end
    end
```

*NOTE:* `pcolored()` is a function from `commands.lua` which enables logging in the client terminal.

I wrote down all of the functions I planned on using. By printing current position on the button, I found out that from the top, 36 pixels is margined and on the sides and the bottom, 16 pixels.

By using basic maths, I determined the values I may want the button to animate within.

``` lua
loacl minClampX = windowX + 16
local maxClampX = windowX + windowWidth - buttonWidth - 16
local minClampY = windowY + 36
local maxClampY = windowY + windowHeight - buttonHeight - 16
```

And the `@onClick` function which I defined updates the button position within the window! Jumping works!

https://github.com/memory-hunter/Tavernlight-Games-Sample-Task/assets/59766692/5ef42cc8-4c87-45cf-8d26-b022ef6ddfc3

Now, for the last part of the animation, I have to keep the button moving to the left every few milliseconds. I will probably use a timing based thing just like in the spells (some sort of a scheduling function) to move the button horizontally.

After searching a bit, `scheduleEvent()` seems to be the function I'll use. In the spells, I used `addEvent`, which depended on the array index to "extend" the call timing, here, I'll poll the function to be called after some time. If the window is visible, move the button to the left with some speed i.e. 10 pixels in i.e. every 200 milliseconds. Clamp around if the button gets past the window boundary I defined earlier.

Et, volia! We have finally finished the question task, and it's working as intended.

https://github.com/memory-hunter/Tavernlight-Games-Sample-Task/assets/59766692/a8c3fe6e-8f74-4127-baa9-c361094db884
