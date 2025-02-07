# Covergen

covergen.sh is the main meat and potatoes of the 765 Pro Cover Bot, as it generates the actual covers. It doesn't post them by itself though, the main 765cover.sh script does that.

## Overview

The only function that 765cover.sh calls is generateCover, and it will do the following:

1. It calculates idolNumber, which is obtained by picking a random number between 1 and however many lines are in the file data/idols.txt.
2. It also fetches idol, containing the name of the idol or unit that idolNumber points to, which involves calling getIdolName with the idol number.
3. Before we can pick the song we first run checkAllSongs with idolNumber to get a list of all the songs the idol or unit can cover. checkAllSongs runs through data/songs.txt and returns the ones that have the idol's name or a group they're part of in them.
4. Lastly we pick the song by calling the aptly named pickSong with a number that is obtained by getting the total count of songs that checkAllSongs calculated. This result is then formatted as Song - Idol and saved to generatedCover.
5. The function then returns.

The bot will then post the contents of generatedCover to Bluesky, although it usually refreshes the accessToken beforehand.

## Format

The format of data/idols.txt is

```
idolOrUnit, groupX
```

where idolOrUnit is the idol or unit, and groupX consists of any number of groups separated by commas that the bot will iterate through to find all songs the idol may cover. For the purposes of iteration, the idol's name is considered a group. This is normally not a problem as idol names aren't specified in other idols.

The format of data/songs.txt is similar,

```
song, groupX
```

where song is the song to be covered and groupX consists of any number of groups (including idols) separated by commas that will be iterated through.

Note that the bot will only ever pick a single idol. You can specify a unit as an idol, and this will cause the unit's name to be printed in the final cover (Snow halation - Project Fairy). If the unit name matches a group, all members of that group will be able to cover that song in addition to the unit.

## Functions

Sample data is computed with the current song list as of 11/11/24. Future changes may cause the sample data here to become inaccurate.

### iterateGroupsWithoutIdol

This iterates through all groups the idol is in, specified in data/idols.txt, but excluding the idol themselves. Expects input via the num variable in idolNumber format.

Sample output, with num=1, corresponding to `Haruka Amami, 765PRO ALLSTARS, HYR, all`:

```
765PRO ALLSTARS
HYR
all
```

### displayIdolGroupDataWithoutIdol

This just sets the variable num to the first parameter, runs iterateGroupsWithoutIdol, and prints the result. Expects input via first parameter.

Ideally this function should be merged into iterateGroupsWithoutIdol as the former function is not called by anything but this function.

Sample output, with the first parameter being 1, which corresponds to `Haruka Amami, 765PRO ALLSTARS, HYR, all`, is the same as the output for iterateGroupsWithoutIdol.

### iterateGroups

Iterates through all groups the idol is in, specified in data/idols.txt. Expects input via the num variable. Works just like iterateGroupsWithoutIdol but includes the idol.

Sample output, with num=1, corresponding to `Haruka Amami, 765PRO ALLSTARS, HYR, all`:

```
Haruka Amami
765PRO ALLSTARS
HYR
all
```

### displayIdolGroupData

This function is identical to displayIdolGroupDataWithoutIdol, it just calls iterateGroups instead of iterateGroupsWithoutIdol.

Same note about merging applies to this function.

Sample output, with the first parameter being 1, which corresponds to `Haruka Amami, 765PRO ALLSTARS, HYR, all`, is the same as the output for iterateGroups.

### iterateSongs

Iterates through the songs specified in data/songs.txt and prints the lines that contain the string in the first parameter. Used by checkAllSongs to get a list of songs the group is compatible with, which is done repeatedly (see checkAllSongs)

Sample output, with the first parameter being "Haruka Amami", returns `LOVE&JOY, Dearly Stars, Haruka Amami`. Haruka can also cover songs available for the `765PRO ALLSTARS`, `HYR`, and `all` groups, but this function only cares about the one specified; coverAllSongs handles the full group iteration logic.

### checkAllSongs

This calls iterateSongs for all groups for a specified idol. At the end, it prepares the variable songlist which is a list of all the songs the idol is compatible with. Expects input via the first parameter as an idol line number.

This function doesn't output anything.

### getIdolName

Fetches the name of the idol designated by the idol line number. Expects input via the first parameter as a line number corresponding to an idol.

Sample output, with the first parameter being `1`, returns `Haruka Amami` as Haruka is the first idol listed.

### dbgDisplayIdolAndGroups

Displays the idol name and the groups they are in. Used by cliTest. Expects input via the first parameter as a line number corresponding to an idol.

Sample output, with the first parameter being 1, returns 

```
Idol/Unit: Haruka Amami
In 3 groups:
765PRO ALLSTARS
HYR
all
```

### pickSong

Picks a line in $songlist between 1 and the first parameter, and prints it. Used mainly by, and its prerequisites are set up by generateCover. Requires \$songlist and expects input via the first parameter as the last line it can pick.

The sample output is variable and will depend on \$songlist and the random number it picks.

### generateCover

This function prepares prerequisites for and calls getIdolName, checkAllSongs, generatedCover and pickSong. This function does not accept nor require parameters, but the result is exported as one: \$generatedCover.

Sample output: `Meet the Flintstones - Takane Shijou`

### cliMassGenerate

Generates the amount of covers specified by the first parameter. This function can be called directly with `./covergen.sh --massgenerate *` where `*` is the amount of covers you want to generate.

Sample output will vary depending on the contents of the data and the amount of covers you want to generate.

### cliTest

This function will generate a cover, display it, list the idol and the groups they're in, and then list all available songs they can cover.

Sample output:

```
Cover: Snow halation - Haruka Amami
Idol/Unit: Haruka Amami
In 3 groups:
765PRO ALLSTARS
HYR
all
13 songs available:
LOVE&JOY
Dazzling World
Precog
Himitsu no Sangoshou
ALIVE
Cutie Panther
Snow halation
Natte Shimatta!
Meet the Flintstones
Bad Apple!
Hare Hare Yukai
God knows...
Bouken Desho Desho?
```
