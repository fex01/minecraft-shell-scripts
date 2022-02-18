# minecraft-shell-scripts
Playing around with shell scripts to generate structures on a Minecraft Server

## What does it do?
These scripts generate text to build structures in Minecraft - just copy / pipe the resulting text into your Minecraft Server Console.
 * works with default Minecraft servers - no plugin / mods needed
 * the older scripts (*Elevator*, *Pyramid*, *TeleporterRoom*) where written for the Java version
 * *CountryHouse* can also produce output for Bedrock (flag `-b`)
 * in general you will find a comment in the script telling you if the script is compatible with Java, Bedrock or both
(Yes, this would be possible via about every programming language - but I wanted to play around with shell scripts :grin:)

## How?
Checkout the repo, check the comments in the head of the script to see which parameters are possible, run the script and use the output.

Example:
```sh
#!/bin/sh

# Work in Progress - not functional
# Creates the necassary commands for Minecraft to create the Avo's
# Journey (https://www.youtube.com/channel/UCeprnLp3l8oZPAig8XjVLnA)
# XP Farm
# Currently only for Bedrock
#
#  Created by fex on 17/02/2022.
#

X=""
Y=""
Z=""
ORIENTATION="north"
DELETE="FALSE"
BLOCK=""
EDITION="java"
ENCLOSE="FALSE"

# Read parameters
# x: = x coordinate (east(+) <-> west(-))
# y: = y coordinate (up(+) <-> down(-))
# z: = z coordinate (south(+) <-> north(-))
# <o>: = orientation (south, west, north or east), default is south
# <d>: = set flag to delete the structure
# <b>: = set flag to generate output for Bedrock
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord] [-o (optional) orientation] [-d (optional) to delete the structure] [-b (optional) set for Bedrock Edition]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:o:db" VALUE "$@" ; do
...

```
At the beginning of the script you will find comments with general information and explaning the parameters.

Mandatory for about every script are the xyz-coordinates where you want the structure to be created, one of the optional parameters is the orientation (in which direction should the structure face?). For creating an XP-Farm (design by [Avo's Journey](https://www.youtube.com/channel/UCeprnLp3l8oZPAig8XjVLnA)) at, for example 14/60/-73, for a Bedrock Server execute the script with 
```
cd </wherever/I/have/my/minecraft-scripts>
./CreateXPFarm.sh -x 14 -y 60 -z -73 -b
```
(Parameter for orientation south can be skippt since south is the default orientation)

After the script finished writing Minecraft commands just copy the whole text and paste it into your Minecraft Server Console. I would recommend to be in the game watching the coordinates to make sure that the chunks are loaded - and it might be fun the see the structure being createt in just a few seconds :-)

And if the structure is not to your liking just delete it with pasting the result of `./CreateXPFarm.sh -x 14 -y 60 -z -73 -d -b`
