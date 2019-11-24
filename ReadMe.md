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

Most of **ZonePet**'s features are available from the MiniMap button - mouse over it to see them.  
Some are only accessible though the `/zp` slash commnnds. Type '/zp' in the Chat window to see a lit of these commands.

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
- /zp search - search for and summon a pet by name (searching is case-insensitive and will find partial matches).
- /zp dismiss - dismiss your pet.
- /zp fav - summon favorite pets only (if you have enough).
- /zp all - choose from all your pets.
- /zp mini - show or hide the MiniMap button.
- /zp dupe - list any duplicate pets.

If /zp conflicts with any other commands, use /zonepet instead.

---

Check out my iPhone app [WoW Stats](https://itunes.apple.com/app/wow-stats/id1364247768) for quick access to suggested talent builds and stat priorities.

---

### Version History

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
  - If you are doing Children's Week activiies with your orphan, or any similar questing with a special companion, temporarily disable ZonePet by right-clicking in the minimap button. Summoning a pet either with ZonePet or manually, will automatically dimiss companions like the orphan.
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
