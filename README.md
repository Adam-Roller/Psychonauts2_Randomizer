# Psychonauts2_Randomizer

## Setup Instructions

### UE4SS setup
Install UE4SS (experimental release) as described [here](https://docs.ue4ss.com/dev/installation-guide.html)

Once extracted into your game folder, clone this repo into the Mods folder. Add this line to the `mods.txt` file after the last mod name but before the Keybinds line:
```
Psychonauts2_Randomizer: 1
```
If you named your folder containing this repo something different you can change the above line to match the folder name you chose.

Grab the file `ue4ss\CustomGameConfigs\Psychonauts 2\VtableLayout.ini` and move it to the `ue4ss` folder.

Open `ue4ss\UE4SS-settings.ini`, look for the `[EngineVersionOverride]` section and set `MajorVersion = 4` and `MinorVersion = 26`

### UnrealPak setup
Download `UnrealPak` from [this direct github file link](https://github.com/Dmgvol/UE_Modding/raw/main/Tools/UnrealPak.zip) and extract the zip into the top level folder for this mod (You want `UnrealPak.exe` in the same folder as the `P2InstaPostGame_P` folder).

In windows explorer drag the `P2InstaPostGame_P` folder onto the `UnrealPak-With-Compression.bat` file. Hit any key to close the command prompt that opened and copy the newly created `P2InstaPostGame_P.pak` file into `{your-steam-location}\steamapps\common\Psychonauts 2\Psychonauts2\Content\Paks\` (it will sit next to the existing `Psychonauts2-WindowsNoEditor.pak`)

## Other Tools

### UAssetGUI
If you want to mess with the `.uasset` files such as the quests, I recommend using [UAssetGUI](https://github.com/atenfyr/UAssetGUI/releases)

### FModel
If you want to explore and/or export files from the base game `.pak` you should use [FModel](https://fmodel.app/)

## Knowledge

Check the Wiki pages for info dumps

Check [the discord](https://discord.com/channels/731205301247803413/1026541677353107568)
