#!/bin/sh

# Creates the necassary commands for Minecraft to create a Teleport
# Room at a given position
# $1: x coordinate
# $2: y coordinate
# $3: z coordinate
#
#  Created by Felix Miske on 03/10/2018.
#

X=""
Y=""
Z=""
ORIENTATION="south"
DELETE="FALSE"
BLOCK=""

# Read parameters
# x: = x coordinate (east <-> west)
# y: = y coordinate (up <-> down)
# z: = z koordinate (south <-> north)
# <o>: = orientation (south, west, north or east), default is south
# <d>: = set flag to delete the teleport room, value: block type
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord] [-o (optional) orientation] [-d (optional) to delete teleport room]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:o:d:" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        d) DELETE="TRUE"; BLOCK="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate missing"; exit 1; fi
if [ "$ORIENTATION" != "south" ] && [ "$ORIENTATION" != "west" ] && [ "$ORIENTATION" != "north" ] && [ "$ORIENTATION" != "east" ]
then
    echo "Orientation must be south, west, north or east."
    exit 1
fi

echo "Create Teleport Room at position $X/$Y/$Z facing $ORIENTATION"
echo ""

# outer edges
minX="-28"
maxX="28"
minY="-2"
maxY="5"
minZ="-28"
maxZ="28"

locationNames[0]="Home"
locations[0]="24 64 -2 facing 24 64 -1"

locationNames[1]="Gestrandet"
locations[1]="273 69 -2129"

locationNames[2]="Djungeltempel"
locations[2]="-215 70 632 facing -216 70 632"

locationNames[3]="Baumhaus"
locations[3]="-686 116 1522 facing -686 116 1523"

locationNames[4]="Villa"
locations[4]="-798 89 -2099 facing -799 89 -2099"

locationNames[5]="Schloss"
locations[5]="78 68 -1115 facing 79 68 -1115"

locationNames[6]="Burg"
locations[6]="263 67 -1062 facing 265 67 -1062"

locationNames[7]="Savanne-Dorf"
locations[7]="-300 65 -2682 facing -300 65 -2684"

locationNames[8]="Tod"
locations[8]="0 0 0"

setBorders () {
    case $ORIENTATION in
        south) minX=-14; maxX=14; minY=-2; maxY=5; minZ=0; maxZ=28;;
        west) minX=-28; maxX=0; minY=-2; maxY=5; minZ=-14; maxZ=14;;
        north) minX=-14; maxX=14; minY=-2; maxY=5; minZ=-28; maxZ=0;;
        east) minX=0; maxX=28; minY=-2; maxY=5; minZ=-14; maxZ=14;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}

createDoor () {
    echo "setblock $1 $2 $3 air"
    echo "setblock $1 $(($2 + 1)) $3 air"
    echo "setblock $1 $(($2 - 1)) $3 smooth_quartz"
    echo "setblock $1 $(($2 + 2)) $3 smooth_quartz"
    echo "setblock $1 $2 $3 light_weighted_pressure_plate"

    case $ORIENTATION in
        south)
            echo "setblock $1 $2 $(($3 + 1)) air"
            echo "setblock $1 $(($2 + 1)) $(($3 + 1)) air"

            echo "setblock $(($1 - 1)) $2 $3 smooth_quartz"
            echo "setblock $(($1 - 1)) $(($2 + 1)) $3 smooth_quartz"
            echo "setblock $(($1 + 1)) $2 $3 smooth_quartz"
            echo "setblock $(($1 + 1)) $(($2 + 1)) $3 smooth_quartz"

            echo "setblock $1 $2 $(($3 + 1)) iron_door[facing=south,half=lower]"
            echo "setblock $1 $(($2 + 1)) $(($3 + 1)) iron_door[facing=south,half=upper]"
            echo "setblock $1 $2 $(($3 + 2)) light_weighted_pressure_plate"
            ;;
        west)
            echo "setblock $(($1 - 1)) $2 $3 air"
            echo "setblock $(($1 - 1)) $(($2 + 1)) $3 air"

            echo "setblock $1 $2 $(($3 - 1)) smooth_quartz"
            echo "setblock $1 $(($2 + 1)) $(($3 - 1)) smooth_quartz"
            echo "setblock $1 $2 $(($3 + 1)) smooth_quartz"
            echo "setblock $1 $(($2 + 1)) $(($3 + 1)) smooth_quartz"

            echo "setblock $(($1 - 1)) $2 $3 iron_door[facing=west,half=lower]"
            echo "setblock $(($1 - 1)) $(($2 + 1)) $3 iron_door[facing=west,half=upper]"
            echo "setblock $(($1 - 2)) $2 $3 light_weighted_pressure_plate"
            ;;
        north)
            echo "setblock $1 $2 $(($3 - 1)) air"
            echo "setblock $1 $(($2 + 1)) $(($3 - 1)) air"

            echo "setblock $(($1 - 1)) $2 $3 smooth_quartz"
            echo "setblock $(($1 - 1)) $(($2 + 1)) $3 smooth_quartz"
            echo "setblock $(($1 + 1)) $2 $3 smooth_quartz"
            echo "setblock $(($1 + 1)) $(($2 + 1)) $3 smooth_quartz"

            echo "setblock $1 $2 $(($3 - 1)) iron_door[facing=north,half=lower]"
            echo "setblock $1 $(($2 + 1)) $(($3 - 1)) iron_door[facing=north,half=upper]"
            echo "setblock $1 $2 $(($3 - 2)) light_weighted_pressure_plate"
            ;;
        east)
            echo "setblock $(($1 + 1)) $2 $3 air"
            echo "setblock $(($1 + 1)) $(($2 + 1)) $3 air"

            echo "setblock $1 $2 $(($3 - 1)) smooth_quartz"
            echo "setblock $1 $(($2 + 1)) $(($3 - 1)) smooth_quartz"
            echo "setblock $1 $2 $(($3 + 1)) smooth_quartz"
            echo "setblock $1 $(($2 + 1)) $(($3 + 1)) smooth_quartz"

            echo "setblock $(($1 + 1)) $2 $3 iron_door[facing=east,half=lower]"
            echo "setblock $(($1 + 1)) $(($2 + 1)) $3 iron_door[facing=east,half=upper]"
            echo "setblock $(($1 + 2)) $2 $3 light_weighted_pressure_plate"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}

prepareArea () {

    # Outer lining with bedrock
    ./Subfunctions/lineRectangle.sh -u $(($1 + $minX)) -v $(($2 + $minY)) -w $(($3 + $minZ)) -x $(($1 + $maxX)) -y $(($2 + $maxY)) -z $(($3 + $maxZ)) -b "bedrock"

    # Inner lining with quartz
    ./Subfunctions/lineRectangle.sh -u $(($1 + $minX)) -v $(($2 + $minY)) -w $(($3 + $minZ)) -x $(($1 + $maxX)) -y $(($2 + $maxY)) -z $(($3 + $maxZ)) -b "smooth_quartz" -o 1

    # Clear inner area
    ./Subfunctions/fillArea.sh -u $(($1 + $minX)) -v $(($2 + $minY)) -w $(($3 + $minZ)) -x $(($1 + $maxX)) -y $(($2 + $maxY)) -z $(($3 + $maxZ)) -b "air" -o 2
}

decorateArea () {
    # Create outer glowstone band
    ./Subfunctions/createBand.sh -u $(($1 + $minX)) -w $(($3 + $minZ)) -x $(($1 + $maxX)) -y $(($2 - 1)) -z $(($3 + $maxZ)) -b "glowstone" -o 2
    # Create inner glowstone band
    ./Subfunctions/createBand.sh -u $(($1 + $minX)) -w $(($3 + $minZ)) -x $(($1 + $maxX)) -y $(($2 - 1)) -z $(($3 + $maxZ)) -b "glowstone" -o 10

    # Insert Door
    createDoor $1 $2 $3
}

setSign () {
    setSignX=""
    setSignZ=""
    rotation=""
    case $ORIENTATION in
        south) setSignX=$1; setSignZ=$(($3 + 1)); rotation=8;;
        west) setSignX=$(($1 - 1)); setSignZ=$3; rotation=12;;
        north) setSignX=$1; setSignZ=$(($3 - 1)); rotation=0;;
        east) setSignX=$(($1 + 1)); setSignZ=$3; rotation=4;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
    echo "setblock $setSignX $(($2 + 1)) $setSignZ sign[rotation=$rotation]{Text2:\"{\\\"text\\\":\\\"$4\\\"}\"}"
}

createTeleporters () {
    orientX=""
    orientZ=""
    case $ORIENTATION in
        south) orientX=$1; orientZ=$(($3 + 7));;
        west) orientX=$(($1 - $maxZ)); orientZ=$(($3 + $minZ + 7));;
        north) orientX=$1; orientZ=$(($3 + $minZ + 7));;
        east) orientX=$(($1 + $maxZ)); orientZ=$(($3 + $minZ + 7));;
        *) "Orientation must be south, west, north or east."; exit 1
    esac

    i=0
    for x in {-1..1}; do
        for z in {0..2}; do
            tempX=$(($orientX + $(($x * 8))))
            tempZ=$(($orientZ + $(($z * 8))))
            ./Subfunctions/createTeleporterPodest.sh -x $tempX -y $2 -z $tempZ
            echo "setblock $tempX $(($2 + 3)) $tempZ glowstone" # install lights
            setSign $tempX $2 $tempZ "${locationNames[$i]}"
            i=$(($i + 1))
        done
    done

    # Set TPLocations last to avoid trouble
    i=0
    for x in {-1..1}; do
        for z in {0..2}; do
            tempX=$(($orientX + $(($x * 8))))
            tempZ=$(($orientZ + $(($z * 8))))
            ./Subfunctions/setCommand.sh -x $tempX -y $(($2 - 1)) -z $tempZ -c "tp @p ${locations[$i]}"
            i=$(($i + 1))
        done
    done
}

deleteTPRoom () {
    ./Subfunctions/fillArea.sh -u $(($1 + $minX)) -v $(($2 + $minY)) -w $(($3 + $minZ)) -x $(($1 + $maxX)) -y $(($2 + $maxY)) -z $(($3 + $maxZ)) -b "$BLOCK"
}

setBorders

if [ "$DELETE" = "TRUE" ]; then deleteTPRoom $X $Y $Z; exit 0; fi

prepareArea $X $Y $Z
decorateArea $X $Y $Z
createTeleporters $X $Y $Z
echo ""
