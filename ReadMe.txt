ZonePet add-on for World of Warcraft
====================================

Keeps a pet active at all times, using a pet native to the current zone if possible.
Will not change more than once every 5 minutes, unless you lose your pet.
If you do not have any pets from a zone or only a few, you will get a random pet instead.

v 2.5.7: Updated for 10.1.5.
v 2.5.6: Updated for 10.1.0.
v 2.5.5: Updated for 10.0.7. Fixed hang when there's only one suitable pet.
v 2.5.4: Stop repeated attempts to summon. Added an option to show info in chat log less often.
v 2.5.3: Updated for 10.0.5.
v 2.5.2: Updated for 10.0.2. Better handling of faction pets.
v 2.5.1: Updated for 10.0. Fixed pet lock in. Won't summon purchased pets so often.
v 2.5.0: Added ability to ignore certain pets.
v 2.4.5: Updated for Patch 9.2.0 - hopefully this one will be published
v 2.4.4: Updated for Patch 9.2.0.
v 2.4.3: Fixed freeze if only one available pet. Better re-summon of locked pet.
v 2.4.2: Improved minimap button to work better with minimap addons.
v 2.4.1: Updated for Patch 9.1.5.
v 2.4.0: Special pets from the in-game store, trading card game and promotions will be called more often. Disgusting Ooozeling will never be summoned automatically.
v 2.3.0: Option to hide pet info in chat using Game Menu > Interface > AddOns > ZonePet.
v 2.2.2: Added info about interacting with Daisy the sloth.
v 2.2.1: Fix for summoning too frequently.
v 2.2.0: New options in Game Menu > Interface > AddOns for PvP and groups.
v 2.1.2: Updated while trying to fix CurseForge link.
v 2.1.1: Updated for Patch 9.0.5.
v 2.1.0: Settings panel now in Game Menu > Interface > AddOns.
v 2.0.6: Fix for intermittent bug when re-summoning locked pet.
v 2.0.5: Updated for Shadowlands pre-patch.
v 2.0.4: If you lock in a pet, it will get re-summoned whenever possible.
v 2.0.3: Really won't summon when you are stealthed (yes, I rolled a rogue...).
v 2.0.2: Better checking for good time to summon pet.
v 2.0.1: A locked pet will now always be re-summoned when you dismount.
v 2.0.0:
  New features: summon previous pet, lock in the current pet or search by name.
  To go back your previous pet, type '/zp back' or Shift + Left-click the MiniMap button.
  To lock in your current pet, type '/zp lock' or Alt + Left-click the MiniMap button.
  To search for a pet by name, type '/zp search name' e.g. '/zp search egbert'.
    Searching is case-insensitive and will find partial matches.
v 1.5.3: Better checking for in combat and not able to get pet info, fixed tooltip.
v 1.5.2: Fixed error in interaction info.
v 1.5.1: Removed icon from tooltip to try to avoid display problem.
v 1.5.0:
  If your pet has a command that can be used to interact with it, this will be shown in the tooltip.
  Type '/zp about' to see information about your current pet in the chat.
v 1.4.8: Updated for Patch 8.2.
v 1.4.7: 
  Type '/zp dupe' in chat to list your duplicate pets.
  If you are doing Children's Week activities with your orphan, or any similar questing with a special companion, temporarily disable ZonePet by right-clicking in the minimap button. Summoning a pet either with ZonePet or manually, will automatically dismiss companions like the orphan.
v 1.4.6: Stops icon appearing in over-sized tooltip.
v 1.4.5:
  - Better text formatting in tooltip when using ElvUI.
  - Still working on the intermittent error on login.
v 1.4.4:
  - Really fixed intermittent Lua error when logging in?
v 1.4.3:
  - Stopped duplicate messages appearing.
  - Reduced frequency of pet change after dismounting.
  - Fixed intermittent Lua error when logging in.
v 1.4.2: Better time management for summoning a new pet.
v 1.4.1: ZonePet will not try to summon a pet if you are in a vehicle or on a flight.
v 1.4.0:
  - Better selection if you only have a few pets from the zone.
  - Improved handling of slash commands.
v 1.3.2:
  - If you dismiss your pet using ZonePet, you will not get a new one until you left-click in the minimap button or use '/zp new'.
  - Tooltip should not appear anywhere except from the ZonePet minimap button.
  - More likely to summon a random pet when you only have a few pets from the current zone.
v 1.3.1: More options in minimap button and chat window. Type /zp for help.
v 1.3.0: Now with a minimap button. Mouse over the button for help.
v 1.2.0: Will not summon a pet if you are stealthed. In PvP mode, will dismiss a pet when you stealth.
v 1.0.0: Initial release.