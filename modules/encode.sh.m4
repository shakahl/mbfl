# encode.sh.m4 --
# 
# Part of: Marco's BASH Functions Library
# Contents: encode/decode strings
# Date: Wed Apr 23, 2003
# 
# Abstract
# 
# 
# 
# Copyright (c) 2003, 2004, 2005 Marco Maggi
# 
# This is free  software you can redistribute it  and/or modify it under
# the terms of  the GNU General Public License as  published by the Free
# Software Foundation; either  version 2, or (at your  option) any later
# version.
# 
# This  file is  distributed in  the hope  that it  will be  useful, but
# WITHOUT   ANY  WARRANTY;  without   even  the   implied  warranty   of
# MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
# General Public License for more details.
# 
# You  should have received  a copy  of the  GNU General  Public License
# along with this file; see the file COPYING.  If not, write to the Free
# Software Foundation,  Inc., 59  Temple Place -  Suite 330,  Boston, MA
# 02111-1307, USA.
# 

function mbfl_decode_hex () {
    mandatory_parameter(INPUT, 1, input string)

    for ((i=0; $i < ${#INPUT}; i=$(($i + 2)))) ; do
        echo -en "\\x${INPUT:$i:2}"
    done
    echo;# to end the line and let "read" acquire the stuff from a pipeline
}

function mbfl_decode_oct () {
    mandatory_parameter(INPUT, 1, input string)

    for ((i=0; $i < ${#INPUT}; i=$(($i + 3)))) ; do
        echo -en "\\${INPUT:$i:3}"
    done
    echo;# to end the line and let "read" acquire the stuff from a pipeline
}


### end of file
# Local Variables:
# mode: sh
# End:
