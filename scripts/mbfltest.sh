# mbfltest.sh --
# 
# Part of: Marco's BASH Functions Library
# Contents: wrapper for the test library
# Date: Wed Aug 17, 2005
# 
# Abstract
# 
#	Executes a bash subprocess with running test files in it.
# 
# Copyright (c) 2005 Marco Maggi
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

#page
## ------------------------------------------------------------
## MBFL's related options and variables.
## ------------------------------------------------------------

script_PROGNAME=mbfltest.sh
script_VERSION=1.0
script_COPYRIGHT_YEARS='2005'
script_AUTHOR='Marco Maggi'
script_LICENSE=GPL
script_USAGE="usage: ${script_PROGNAME} [options] FILE ..."
script_DESCRIPTION='Interface to the MBFL test library.'
script_EXAMPLES="Usage examples:

\t${script_PROGNAME} module1.test module2.test
\t${script_PROGNAME} --start --end module1.test module2.test"

source "${MBFL_LIBRARY:=$(mbfl-config)}"

# keyword default-value brief-option long-option has-argument description
mbfl_declare_option START no '' start noarg 'print start messages for tests'
mbfl_declare_option END no '' end noarg 'print end messages for tests'
mbfl_declare_option MATCH '' '' match witharg 'select match pattern for tests'
mbfl_declare_option DIRECTORY "${PWD}" \
    '' directory witharg 'change directory before executing tests'
mbfl_declare_option LIBRARY '' '' library witharg 'select the MBFL library'

mbfl_main_declare_exit_code 2 file_not_found

#page
## ------------------------------------------------------------
## Option update functions.
## ------------------------------------------------------------

function script_option_update_start () {
    export TESTSTART='yes'
}
function script_option_update_end () {
    export TESTSUCCESS='yes'
}
function script_option_update_match () {
    local OPTNAME=$1
    local OPTARG=$2
    export TESTMATCH="${OPTARG}"
}

#page
## ------------------------------------------------------------
## Main functions.
## ------------------------------------------------------------

function main () {
    local item FILES i=0 lib testlib=$(mbfl-config --testlib)


    if test $ARGC -eq 0 ; then
        mbfl_message_error "no files on the command line"
        exit_because_file_not_found
    fi
    mbfl_argv_all_files || exit_because_file_not_found
    for item in "${ARGV[@]}" ; do
        if mbfl_file_is_file "${item}" ; then
            FILES[$i]=$(mbfl_file_normalise "${item}")
        else
            mbfl_message_error "file not found '${item}'"
            exit_because_file_not_found
        fi
        let ++i
    done

    if test -n "${script_option_LIBRARY}" ; then
        lib=$(mbfl_file_normalise "${script_option_LIBRARY}")
    else
        lib=$(mbfl-config)
    fi

    mbfl_cd "${script_option_DIRECTORY}"
    for item in "${FILES[@]}" ; do
        mbfl_message_debug "executing subprocess for test '${item}'"
        {
            printf 'source %s || exit 2\n' "${lib}"
            printf 'source %s || exit 2\n' "${testlib}"
            mbfl_option_debug && printf 'mbfl_set_option_debug\n'
            printf 'export MBFL_LIBRARY=%s\n' "${lib}"
            printf 'mbfl_TEST_FILE=%s\n' "${item}"
            printf 'source %s\n' "${item}"
        } | mbfl_program_bash
    done

    exit_success
}

#page
## ------------------------------------------------------------
## Start.
## ------------------------------------------------------------

mbfl_main

### end of file
# Local Variables:
# mode: sh
# End:
