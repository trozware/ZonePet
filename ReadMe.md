# ZonePet

## Add-on for World of Warcraft

---

Available from [CurseForge](https://wow.curseforge.com/projects/zonepet)

**ZonePet** keeps a companion pet active, preferably with a pet from the zone you are in.

You may have collected hundreds of pets, but you never remember to summon them so you are missing out on some fun content. And when you do summon, you always summon from among the same few, or maybe that pet just doesn't fit in.

**ZonePet** checks all your pets and tries to summon a pet that is native to your current zone.
If you have no pets or only a few pets from the zone, you may see a random pet instead.

If **ZonePet** summons a pet you want to keep around for a while, you can lock it in so that it stays your pet until you choose another. And you can go back to the previous pet if you missed it.

If you want to summon a particular pet, **ZonePet** will search your pets for a pet matching the name you enter.

### Usage

Install the add-on and when you log in, you will summon a pet automatically. After 5 minutes with the same pet, or when you lose your pet or change zone, a different pet will be summoned.

Read the pet's name and description in the Chat or by mousing over the MiniMap button. These descriptions can be very funny - yet another way we are missing out on some good content. And if your pet has an interactive command, see what to type.

Bonus for sneaky types: no pet will be summoned while you are in Stealth mode and if you enter Stealth mode and are flagged for PvP, your pet will be dismissed so as not to attract unwanted attention.

Mouse over the MiniMap button to see some options for controlling **ZonePet**. Other settings are available through Game Menu > Options > AddOns > ZonePet.  
Type '/zp' in the Chat window or click "Show Slash Commands" in the AddOns panel to see a list of commands.

NEW: To ignore specific pets, go to Game Menu > Interface > AddOns > ZonePet. Type a name or partial name into the ignore field and press Return/Enter to add it to the list. If the entry is already in the list, it will be removed, or you can click the button to clear the entire list. This will block any pets with names containing the entered text, case does not matter. E.g. entering "rat" will block all pet names that include the text "rat" which covers "Fjord Rat", "Rat Snake" and "Creepy Crate" as well as many others.

### MiniMap button

Mouse over the MiniMap button to see details about your currently summoned pet (if any) and to operate the ZonePet add-on.

- Left-click - change to a different pet.
- Shift + Left-click - switch back to the previous pet and lock it in.
- Alt + Left-click - lock in the current pet until you left-click or use '/zp new' to get another.
- Right-click - dismiss your pet (you will not get a new one until you left-click or use '/zp new').
- Alt + Right-click - hide the MiniMap button (use the /zp commands to operate **ZonePet** or to bring back the button).

### Slash Commands

- /zp new - change to a different pet.
- /zp about - show info about your current pet.
- /zp back - summon & lock in the previous pet.
- /zp lock - lock in the current pet until you left-click or use '/zp new' to get another.
- /zp <name> - search for and summon a pet by name (searching is case-insensitive and will find partial matches).
- /zp dismiss - dismiss your pet.
- /zp fav - summon favorite pets only (if you have enough).
- /zp all - choose from all your pets.
- /zp mini - show or hide the MiniMap button.
- /zp dupe - list any duplicate pets.
- /zp - shows help

---

**Zone Pet** is a companion add-on to **Zone Mount** which you can also get from [CurseForge](https://wow.curseforge.com/projects/ZoneMount). While the two add-ons are similar, they are completely independent so you do not have to install both (although I hope you will).

---

### Version History

- v 2.6.10: Updated for 11.1.5.
- v 2.6.9: Updated for 11.0.1.
- v 2.6.8: Updated for 11.0.7.
- v 2.6.7: Updated for 11.0.5 and fixed minimap tooltip display.
- v 2.6.6: Updated to fix startup crash on 11.0.2.
- v 2.6.5: Updated for 11.0.
- v 2.6.4: Updated for 10.2.7.
- v 2.6.3: Updated for 10.2.6.
- v 2.6.2: Updated for 10.2.5.
- v 2.6.1: Updated for 10.2.0.
- v 2.6.0: Added more interactions and special ability notifications.
- v 2.5.9: Fix for missing library.
- v 2.5.8: Updated for 10.1.7.
- v 2.5.7: Updated for 10.1.5.
- v 2.5.6: Updated for 10.1.0.
- v 2.5.5: Updated for 10.0.7. Fixed hang when there's only one suitable pet.
- v 2.5.4: Stop repeated attempts to summon. Added an option to show info in chat log less often.
- v 2.5.3: Updated for 10.0.5.
- v 2.5.2: Updated for 10.0.2. Better handling of faction pets.
- v 2.5.1: Updated for 10.0. Fixed pet lock in. Won't summon purchased pets so often.
- v 2.5.0: Added ability to ignore certain pets.
- v 2.4.5: Updated for Patch 9.2.0 - hopefully this one will be published
- v 2.4.4: Updated for Patch 9.2.0.
- v 2.4.3: Fixed freeze if only one available pet. Better re-summon of locked pet.
- v 2.4.2: Improved minimap button to work better with minimap addons.
- v 2.4.1: Updated for Patch 9.1.5.
- v 2.4.0: Special pets from the in-game store, trading card game and promotions will be called more often. Disgusting Ooozeling will never be summoned automatically.
- v 2.3.0: Option to hide pet info in chat using Game Menu > Interface > AddOns > ZonePet.
- v 2.2.2: Added info about interacting with Daisy the sloth.
- v 2.2.1: Fix for summoning too frequently.
- v 2.2.0: New options in Game Menu > Interface > AddOns for PvP and groups.
- v 2.1.2: Updated while trying to fix CurseForge link.
- v 2.1.1: Updated for Patch 9.0.5.
- v 2.1.0: Settings panel now in Game Menu > Interface > AddOns.
- v 2.0.6: Fix for intermittent bug when re-summoning locked pet.
- v 2.0.5: Updated for Shadowlands pre-patch.
- v 2.0.4: If you lock in a pet, it will get re-summoned whenever possible. Modified slash commands to match ZoneMount.
- v 2.0.3: Really won't summon when you are stealthed (yes, I rolled a rogue...).
- v 2.0.2: Better checking for good time to summon pet.
- v 2.0.1: A locked pet will now always be re-summoned when you dismount.
- v 2.0.0:
  - New features: summon previous pet, lock in the current pet or search by name.
  - To go back your previous pet, type '/zp back' or Shift + Left-click the MiniMap button.
  - To lock in your current pet, type '/zp lock' or Alt + Left-click the MiniMap button.
  - To search for a pet by name, type '/zp search name' e.g. '/zp search egbert'.
    - Searching is case-insensitive and will find partial matches.
- v 1.5.3: Better checking for in combat and not able to get pet info, fixed tooltip.
- v 1.5.2: Fixed error in interaction info.
- v 1.5.1: Removed icon from tooltip to try to avoid display problem.
- v 1.5.0:
  - If your pet has a command that can be used to interact with it, this will be shown in the tooltip.
  - Type '/zp about' to see information about your current pet in the chat.
- v 1.4.8: Updated for Patch 8.2.
- v 1.4.7:
  - Type '/zp dupe' in chat to list your duplicate pets.
  - If you are doing Children's Week activities with your orphan, or any similar questing with a special companion, temporarily disable ZonePet by right-clicking in the minimap button. Summoning a pet either with ZonePet or manually, will automatically dismiss companions like the orphan.
- v 1.4.6: Stops icon appearing in over-sized tooltip.
- v 1.4.5:
  - Better text formatting in tooltip when using ElvUI.
  - Still working on the intermittent error on login.
- v 1.4.4:
  - Really fixed intermittent Lua error when logging in?
- v 1.4.3:
  - Stopped duplicate messages appearing.
  - Reduced frequency of pet change after dismounting.
  - Fixed intermittent Lua error when logging in.
- v 1.4.2: Better time management for summoning a new pet.
- v 1.4.1: **ZonePet** will not try to summon a pet if you are in a vehicle or on a flight.
- v 1.4.0:
  - Better selection if you only have a few pets from the zone.
  - Improved handling of slash commands.
- v 1.3.2:
  - If you dismiss your pet using **ZonePet**, you will not get a new one until you left-click in the minimap button or use '/zp new'.
  - Tooltip should not appear anywhere except from the **ZonePet** minimap button.
  - More likely to summon a random pet when you only have a few pets from the current zone.
- v 1.3.1: More options in minimap button and chat window. Type /zp for help.
- v 1.3.0: Now with a minimap button. Mouse over the button for help.
- v 1.2.0: Will not summon a pet if you are stealthed. In PvP mode, will dismiss a pet when you stealth.
- v 1.0.0: Initial release.
