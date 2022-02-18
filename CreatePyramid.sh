#!/bin/sh

# Creates the necassary commands for Minecraft build a Pyramid with a given position
# as middle and a given number of levels.
#
#  Created by Felix Miske on 11/10/2018.
#

X=""
Y=""
Z=""
LEVEL=""
DELETE="FALSE"
BLOCK="air"

# Read parameters
# x: = x coordinate (east <-> west)
# y: = y coordinate (up <-> down)
# z: = z koordinate (south <-> north)
# <d>: = set flag to delete the teleport room, value: block type
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord] [-l number of level] [-d (optional) to delete pyramid]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:l:d" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        l) LEVEL="$OPTARG";;
        d) DELETE="TRUE";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate missing"; exit 1; fi
if [ "$LEVEL" = "" ]; then echo "number of levels missing"; exit 1; fi

echo "Create Pyramid at position $X/$Y/$Z with $LEVEL level"
echo ""

# $1 p_min.x
# $2 heigh
# $3 p_min.z
# $4 length
createPlattform () {
    length=$4
    i=1
    j=1
    block="glass"
    lock=false

#    echo "createPlatform p_min.x: $1, height: $2, p_min.z: $3, length: $4"

    switchblock () {
        if [ "$block" = "glass" ]; then block="grass_block"; return; fi
        block="glass"
    }

    switchlock () {
        if [ "$lock" = true ]; then lock=false; return; fi
        lock=true
    }

    for x in $(seq 0 $(($length - 1))); do
        if [ "$j" = 2 ]; then j=0; switchblock; switchlock; fi
        for y in $(seq 0 $(($length - 1))); do
            if [ "$i" = 2 ]; then
                i=0
                if [ "$lock" = false ]; then switchblock; fi
            fi
            echo "setblock $(($1 + $x)) $2 $(($3 + $y)) $block"
            i=$(($i + 1))
        done
        j=$(($j + 1))
    done

    # $1 x
    # $2 y
    # $3 z
    setTorchBlock () {
        echo "setblock $1 $2 $3 dirt"
        echo "setblock $(($1 + 1)) $2 $3 wall_torch[facing=east]"
        echo "setblock $1 $2 $(($3 + 1)) wall_torch[facing=south]"
        echo "setblock $(($1 - 1)) $2 $3 wall_torch[facing=west]"
        echo "setblock $1 $2 $(($3 - 1)) wall_torch[facing=north]"
    }

    setTorchBlock $(($1 + 2)) $(($2 - 1)) $(($3 + 2))
    setTorchBlock $(($1 + 5)) $(($2 - 1)) $(($3 + 2))
    setTorchBlock $(($1 + 2)) $(($2 - 1)) $(($3 + 5))
    setTorchBlock $(($1 + 5)) $(($2 - 1)) $(($3 + 5))
    echo ""
}

# $1 p_min.x
# $2 height
# $3 p_min.z
# $4 length
# $5 sea level / y value at which to stop
createRing () {
    length=$(($4 - 1))
    i=1
    j=1
    block="glass"
    lock=false

#    echo "createRing p_min.x: $1, height: $2, p_min.z: $3, length: $4, sea level: $5"

    # stop recursive call
    if [ $2 -lt $5 ]; then return; fi

    switchblock () {
        if [ "$block" = "glass" ]; then block="grass_block"; return; fi
        block="glass"
    }

    switchlock () {
        if [ "$lock" = true ]; then lock=false; return; fi
        lock=true
    }

    for v in $(seq 0 3); do
        if [ "$j" = 2 ]; then j=0; switchblock; switchlock; fi
        for u in $(seq 1 $(($length + $(($v * 2))))); do
            if [ "$i" = 2 ]; then
                i=0
                if [ "$lock" = false ]; then switchblock; fi
            fi
            #echo ""
            #echo "\$1: $1, \$2: $2, \$3: $3, \$u: $u, \$v: $v"
            echo "setblock $(($1 + $u - $v)) $2 $(($3 - $v)) $block"
            echo "setblock $(($1 + $length + $v)) $2 $(($3 + $u - $v)) $block"
            echo "setblock $(($1 + $length - $u + $v)) $2 $(($3 + $length + $v)) $block"
            echo "setblock $(($1 - $v)) $2 $(($3 + $length - $u + $v)) $block"

            # Beleuchtung
            if [ "$v" = 0 ] && [ $block = "grass_block" ]; then
                echo "setblock $(($1 + $u)) $2 $(($3 + 1)) wall_torch[facing=south]"
                echo "setblock $(($1 + $length - 1)) $2 $(($3 + $u)) wall_torch[facing=west]"
                echo "setblock $(($1 + $length - $u)) $2 $(($3 + $length - 1)) wall_torch[facing=north]"
                echo "setblock $(($1 + 1)) $2 $(($3 + $length - $u)) wall_torch[facing=east]"
            fi

            i=$(($i + 1))
        done
        j=$(($j + 1))
    done
    echo ""

    createRing $(($1 - 4)) $(($2 - 1)) $(($3 - 4)) $(($4 + 8)) $5
}

# $1 p_centrum.x
# $2 sea level / minimum y
# $3 p_centrum.z
# $4 level
createLevel () {
#    echo "createLevel p_centrum.x: $1, sea level / minimum y: $2, p_centrum.z: $3, level: $4"
    echo ""
    echo "Level $4"

    # convert from p_centrum to p_min
    minX=$(($1 - 3))
    minZ=$(($3 - 3))
    height=$(($2 + $(($4 * 4))))
    createPlattform $minX $height $minZ 8
    createRing $(($minX - 1)) $(($height - 1)) $(($minZ - 1)) 10 $2
}

clearArea () {
    height=$(($LEVEL * 4))
    max=4
    min=3

    for h in $(seq $(($Y + $height)) $Y); do
        ./Subfunctions/fillArea.sh -u $(($X - $min)) -v $h -w $(($Z - min)) -x $(($X + $max)) -y $h -z $(($Z + $max))
        max=$(($max + 4))
        min=$(($max - 1))
    done
}

clearArea
if [ "$DELETE" = "TRUE" ]; then exit 0; fi

for i in $(seq 1 $LEVEL); do
    createLevel $X $Y $Z $i
done
