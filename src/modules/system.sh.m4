# system.sh.m4 --
#
# Part of: Marco's BASH Functions Library
# Contents: system interface functions
# Date: Mon Apr 11, 2005
#
# Abstract
#
#
#
# Copyright (c) 2005, 2009, 2013, 2018 Marco Maggi <marco.maggi-ipsu@poste.it>
#
# This is free software; you  can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the
# Free Software  Foundation; either version  3.0 of the License,  or (at
# your option) any later version.
#
# This library  is distributed in the  hope that it will  be useful, but
# WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
# MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
# Lesser General Public License for more details.
#
# You  should have  received a  copy of  the GNU  Lesser  General Public
# License along  with this library; if  not, write to  the Free Software
# Foundation, Inc.,  59 Temple Place,  Suite 330, Boston,  MA 02111-1307
# USA.
#

#page
#### user id conversion

function mbfl_system_enable_programs () {
    mbfl_declare_program grep
    mbfl_declare_program cut
}
function mbfl_system_numerical_user_id_to_name () {
    local GREP CUT RESULT
    mbfl_mandatory_parameter(ID, 1, numerical user id)
    mbfl_program_found_var GREP grep || exit $?
    mbfl_program_found_var CUT cut   || exit $?
    mbfl_program_exec "$GREP" "^[^:]\+:[^:]\+:${ID}:" /etc/passwd | mbfl_program_exec "$CUT" -d: -f1
}
function mbfl_system_user_name_to_numerical_id () {
    local GREP CUT
    mbfl_mandatory_parameter(NAME, 1, user name)
    mbfl_program_found_var GREP grep || exit $?
    mbfl_program_found_var CUT cut   || exit $?
    mbfl_program_exec "$GREP" "^${NAME}" /etc/passwd | mbfl_program_exec "$CUT" -d: -f3
}

#page
#### file permissions

declare -a mbfl_symbolic_permissions
mbfl_symbolic_permissions[0]='---'
mbfl_symbolic_permissions[1]='--x'
mbfl_symbolic_permissions[2]='-w-'
mbfl_symbolic_permissions[3]='-wx'
mbfl_symbolic_permissions[4]='r--'
mbfl_symbolic_permissions[5]='r-x'
mbfl_symbolic_permissions[6]='rw-'
mbfl_symbolic_permissions[7]='rwx'

function mbfl_system_symbolic_to_octal_permissions () {
    mbfl_mandatory_parameter(MODE, 1, symbolic permissions)
    local -i i
    for ((i=0; $i < 8; ++i))
    do
	if test "${mbfl_symbolic_permissions[$i]}" = "$MODE"
	then
            printf "%s\n" $i
            return 0
        fi
    done
    return 1
}
function mbfl_system_octal_to_symbolic_permissions () {
    mbfl_mandatory_parameter(MODE, 1, symbolic permissions)
    printf '%s\n' "${mbfl_symbolic_permissions[${MODE}]}"
}

### end of file
# Local Variables:
# mode: sh
# End:
