# libMBFL.m4 --
# 
# Part of: Marco's BASH Functions Library
# Contents: library file
# Date: Fri Nov 28, 2003
# 
# Abstract
# 
#	This is the library file of MBFL. It must be sourced in shell
#	scripts at the beginning of evaluation.
# 
# Copyright (c) 2003, 2004 Marco Maggi
# 
# This is free software; you  can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the
# Free Software  Foundation; either version  2.1 of the License,  or (at
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
# USA
# 

mbfl_LOADED_MBFL='yes'

shopt -s expand_aliases


function mbfl_set_maybe () {
test -n "${1}" && eval ${1}=\'"${2}"\'
}
function mbfl_read_maybe_null () {
local VARNAME=${1:?"missing variable name parameter to '${FUNCNAME}'"}
if mbfl_option_null ; then
	read -d $'\x00' $VARNAME
else
	read $VARNAME
fi
}
function mbfl_create_option_procedures () {
local NAME=${1:?"missing option name parameter to ${FUNCNAME}"}
eval function mbfl_set_option_${NAME} \(\) \{ \
eval function mbfl_option_${NAME} \\\(\\\) \\{ return 0\\\; \\\}\; \}
eval function mbfl_unset_option_${NAME} \(\) \{ \
eval function mbfl_option_${NAME} \\\(\\\) \\{ return 1\\\; \\\}\; \}
mbfl_unset_option_${NAME}
}
mbfl_create_option_procedures test
mbfl_create_option_procedures verbose_program
mbfl_create_option_procedures show_program
mbfl_create_option_procedures verbose
mbfl_create_option_procedures debug
mbfl_create_option_procedures null
mbfl_create_option_procedures interactive
mbfl_create_option_procedures encoded_args
function mbfl_exit_program_not_found () { exit 20; }

function mbfl_string_chars () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local i j ch
for ((i=0, j=0; $i < "${#STRING}"; ++i, ++j)) ; do
ch=
if test "${STRING:$i:1}" = \\ ; then
test $i != "${#STRING}" && ch=\\
let ++i
fi
SPLITFIELD[$j]="${ch}${STRING:$i:1}"
ch=
done
SPLITCOUNT=$j
return 0
}
function mbfl_string_equal_substring () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local POSITION=${2:?"missing position parameter to '${FUNCNAME}'"}
local PATTERN=${3:?"missing pattern parameter to '${FUNCNAME}'"}
local i
test $(($POSITION+${#PATTERN})) -gt ${#STRING} && return 1
for ((i=0; $i < "${#PATTERN}"; ++i)) ; do
test "${PATTERN:$i:1}" != "${STRING:$(($POSITION+$i)):1}" && \
return 1
done
return 0
}
function mbfl_string_split () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local SEPARATOR=${2:?"missing separator parameter to '${FUNCNAME}'"}
local i j k=0 first=0
for ((i=0; $i < "${#STRING}"; ++i)) ; do
test $(($i+${#SEPARATOR})) -gt ${#STRING} && break
mbfl_string_equal_substring "${STRING}" $i "${SEPARATOR}" && {
# here $i is the index of the first char in the separator
SPLITFIELD[$k]="${STRING:$first:$(($i-$first))}"
let ++k
i=$(($i+${#SEPARATOR}-1))
	    # place the "first" marker to the beginning of the
	    # next substring; "i" will be incremented by "for",
	    # that is why we do "+1" here
first=$(($i+1))
}
done
SPLITFIELD[$k]="${STRING:$first}"
let ++k
SPLITCOUNT=$k
return 0
}
function mbfl_string_first () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local CHAR=${2:?"missing char parameter to '${FUNCNAME}'"}
local BEGIN="${3:-0}"
local i
for ((i=$BEGIN; $i < ${#STRING}; ++i)) ; do
test "${STRING:$i:1}" = "$CHAR" && {
printf "$i\n"
return 0
}
done
return 0
}
function mbfl_string_last () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local CHAR=${2:?"missing char parameter to '${FUNCNAME}'"}
local i="${3:-${#STRING}}"
for ((; $i >= 0; --i)) ; do
test "${STRING:$i:1}" = "$CHAR" && {
printf "$i\n"
return 0
}
done
return 0
}
function mbfl_string_index () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local INDEX=${2:?"missing index parameter to '${FUNCNAME}'"}
printf "${STRING:$INDEX:1}\n"
}
function mbfl_string_is_alpha_char () {
! test \( "$1" \< A -o Z \< "$1" \) -a \( "$1" \< a -o z \< "$1" \)
}
function mbfl_string_is_digit_char () {
! test "$1" \< 0 -o 9 \< "$1"
}
function mbfl_string_is_alnum_char () {
mbfl_string_is_alpha_char "$1" || mbfl_string_is_digit_char "$1"
}
function mbfl_string_is_name_char () {
mbfl_string_is_alnum_char "$1" || test "$1" = _
}
function mbfl_string_is_noblank_char () {
test \( "$1" != " " \) -a \
	\( "$1" != $'\n' \) -a \( "$1" != $'\r' \) -a \
	\( "$1" != $'\t' \) -a \( "$1" != $'\f' \)
}
for class in alpha digit alnum noblank ; do
alias "mbfl_string_is_${class}"="mbfl_p_string_is $class"
done    
function mbfl_p_string_is () {
local CLASS=${1:?"missing class parameter to '${FUNCNAME}'"}
local STRING=${2:?"missing string parameter to '${FUNCNAME}'"}
local i
test "${#STRING}" = 0 && return 1
for ((i=0; $i < ${#STRING}; ++i));  do
	"mbfl_string_is_${CLASS}_char" "${STRING:$i:1}" || return 1
done
return 0
}
function mbfl_string_is_name () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
mbfl_p_string_is name "${STRING}" && ! mbfl_string_is_digit "${STRING:0:1}"
}
function mbfl_string_range () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local BEGIN=${2:?"missing begin parameter to '${FUNCNAME}'"}
local END="${3:-}"
if test -z "$END" -o "$END" = "end" -o "$END" = "END"
then printf "${STRING:$BEGIN}\n"
else printf "${STRING:$BEGIN:$END}\n"
fi
}
function mbfl_string_replace () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local PATTERN=${2:?"missing pattern parameter to '${FUNCNAME}'"}
local SUBST="${3:-}"
printf "${STRING//$PATTERN/$SUBST}\n"
}
function mbfl_string_skip () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local POSNAME=${2:?"missing position parameter to '${FUNCNAME}'"}
local CHAR=${3:?"missing char parameter to '${FUNCNAME}'"}
local position=${!POSNAME}
while test "${STRING:$position:1}" = "$CHAR" ; do let ++position ; done
eval $POSNAME=$position
}
function mbfl_string_toupper () {
mbfl_p_string_uplo toupper "${1}"
}
function mbfl_string_tolower () {
mbfl_p_string_uplo tolower "${1}"
}
function mbfl_p_string_uplo () {
local MODE=${1:?"missing mode parameter to '${FUNCNAME}'"}
local STRING="${2:-}"
local ch lower upper flag=0
test "${#STRING}" = 0 && return 0
for ch in \
a A b B c C d D e E f F g G h H i I j J k K l L m M \
n N o O p P q Q r R s S t T u U v V w W x X y Y z Z ; do
if test $flag = 0; then
lower=$ch
flag=1
else
upper=$ch
if test "${MODE}" = toupper ; then
STRING="${STRING//$lower/$upper}"
else
STRING="${STRING//$upper/$lower}"
fi
flag=0
fi
done
printf "${STRING}\n"
return 0
}
function mbfl_sprintf () {
local VARNAME="${1:?missing variable name parameter in ${FUNCNAME}}"
local FORMAT="${2:?missing format parameter in ${FUNCNAME}}"
local OUTPUT=
shift 2

OUTPUT=`printf "${FORMAT}" "$@"`
eval "${VARNAME}"=\'"${OUTPUT}"\'
}
function mbfl_string_is_equal_unquoted_char () {
local STRING="${1:?missing string parameter to ${FUNCNAME}}"
local pos="${2:?missing position parameter to ${FUNCNAME}}"
local char="${3:?missing known char parameter to ${FUNCNAME}}"
test "${STRING:$pos:1}" = "$char" || mbfl_string_is_quoted_char "$STRING" $pos
}
function mbfl_string_is_quoted_char () {
local STRING="${1:?missing string parameter to ${FUNCNAME}}"
local i="${2:?missing position parameter to ${FUNCNAME}}"
local count
let --i
for ((count=0; $i >= 0; --i))
do
if test "${STRING:$i:1}" = \\
then let ++count
else break
fi
done
let ${count}%2
}
function mbfl_string_quote () {
local STRING=${1:?"missing string parameter to '${FUNCNAME}'"}
local i ch

for ((i=0; $i < "${#STRING}"; ++i)) ; do
ch="${STRING:$i:1}"
test "$ch" = \\ && ch=\\\\
printf '%s' "$ch"
done
printf '\n'
return 0
}

function mbfl_decode_hex () {
local INPUT=${1:?"missing input string parameter to '${FUNCNAME}'"}
for ((i=0; $i < ${#INPUT}; i=$(($i + 2)))) ; do
echo -en "\\x${INPUT:$i:2}"
done
echo;# to end the line and let "read" acquire the stuff from a pipeline
}
function mbfl_decode_oct () {
local INPUT=${1:?"missing input string parameter to '${FUNCNAME}'"}
for ((i=0; $i < ${#INPUT}; i=$(($i + 3)))) ; do
echo -en "\\${INPUT:$i:3}"
done
echo;# to end the line and let "read" acquire the stuff from a pipeline
}

function mbfl_cd () {
mbfl_change_directory "$@"
mbfl_message_verbose "entering directory: '${PWD}'\n"
}
function mbfl_change_directory () {
cd "$@" &>/dev/null
}
function mbfl_file_extension () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local i=

for ((i="${#PATHNAME}"; $i >= 0; --i)); do
test "${PATHNAME:$i:1}" = '/' && return
if mbfl_string_is_equal_unquoted_char "${PATHNAME}" $i '.' ; then
let ++i
printf '%s\n' "${PATHNAME:$i}"
return
fi
done
}
function mbfl_file_dirname () {
local PATHNAME="${1:-''}"
local i=
# Do not change "${PATHNAME:$i:1}" with "$ch"!! We need to extract the
# char at each loop iteration.
for ((i="${#PATHNAME}"; $i >= 0; --i)); do
if test "${PATHNAME:$i:1}" = "/" ; then
while test \( $i -gt 0 \) -a \( "${PATHNAME:$i:1}" = "/" \) ; do
let --i
done
if test $i = 0 ; then
printf '%s\n' "${PATHNAME:$i:1}"
else
let ++i
printf '%s\n' "${PATHNAME:0:$i}"
fi
return 0
fi
done
printf '.\n'
return 0
}
function mbfl_file_subpathname () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local BASEDIR=${2:?"missing base directory parameter to '${FUNCNAME}'"}
if test "${BASEDIR:$((${#BASEDIR}-1))}" = '/'; then
BASEDIR="${BASEDIR:0:$((${#BASEDIR}-1))}"
fi
if test "${PATHNAME}" = "${BASEDIR}" ; then
printf './\n'
return 0
elif test "${PATHNAME:0:${#BASEDIR}}" = "${BASEDIR}"; then
printf  './%s\n' "${PATHNAME:$((${#BASEDIR}+1))}"
return 0
else
return 1
fi
}
function mbfl_file_normalise () {
local pathname="${1:?}"
local prefix="${2}"
local dirname=
local tailname=
local ORGDIR="${PWD}"
if mbfl_file_is_absolute "${pathname}" ; then
mbfl_p_file_normalise1 "${pathname}"
elif mbfl_file_is_directory "${prefix}" ; then
pathname="${prefix}/${pathname}"
mbfl_p_file_normalise1 "${pathname}"
elif test -n "${prefix}" ; then
prefix=`mbfl_p_file_remove_dots_from_pathname "${prefix}"`
pathname=`mbfl_p_file_remove_dots_from_pathname "${pathname}"`
echo "${prefix}/${pathname}"
else
mbfl_p_file_normalise1 "${pathname}"
fi
cd "${ORGDIR}" >/dev/null
return 0
}
function mbfl_p_file_normalise1 () {
if mbfl_file_is_directory "${pathname}"; then
mbfl_p_file_normalise2 "${pathname}"
else
local tailname=`mbfl_file_tail "${pathname}"`
local dirname=`mbfl_file_dirname "${pathname}"`
if mbfl_file_is_directory "${dirname}"; then
mbfl_p_file_normalise2 "${dirname}" "${tailname}"
else
echo "${pathname}"
fi
fi
}
function mbfl_p_file_normalise2 () {
cd "$1" >/dev/null
if test -n "$2" ; then echo "${PWD}/$2"; else echo "${PWD}"; fi
cd - >/dev/null
}
function mbfl_p_file_remove_dots_from_pathname () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local item i
local SPLITPATH SPLITCOUNT; declare -a SPLITPATH
local output output_counter=0; declare -a output
local input_counter=0 
mbfl_file_split "${PATHNAME}"
for ((input_counter=0; $input_counter < $SPLITCOUNT; ++input_counter)) ; do
case "${SPLITPATH[$input_counter]}" in
.)
;;
..)
let --output_counter
;;
*)
output[$output_counter]="${SPLITPATH[$input_counter]}"
let ++output_counter
;;
esac
done
PATHNAME="${output[0]}"
for ((i=1; $i < $output_counter; ++i)) ; do
PATHNAME="${PATHNAME}/${output[$i]}"
done
printf '%s\n' "${PATHNAME}"
}
function mbfl_file_rootname () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local i="${#PATHNAME}"
test $i = 1 && { printf '%s\n' "${PATHNAME}"; return 0; }
for ((i="${#PATHNAME}"; $i >= 0; --i)) ; do
ch="${PATHNAME:$i:1}"
if test "$ch" = "." ; then
if test $i -gt 0 ; then
printf '%s\n' "${PATHNAME:0:$i}"
break
else
printf '%s\n' "${PATHNAME}"
fi
elif test "$ch" = "/" ; then
printf '%s\n' "${PATHNAME}"
break
fi
done
return 0
}
function mbfl_file_split () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local i=0 last_found=0
mbfl_string_skip "${PATHNAME}" i /
last_found=$i
for ((SPLITCOUNT=0; $i < "${#PATHNAME}"; ++i)) ; do
test "${PATHNAME:$i:1}" = / && {
SPLITPATH[$SPLITCOUNT]="${PATHNAME:$last_found:$(($i-$last_found))}"
let ++SPLITCOUNT; let ++i
mbfl_string_skip "${PATHNAME}" i /
last_found=$i
}
done
SPLITPATH[$SPLITCOUNT]="${PATHNAME:$last_found}"
let ++SPLITCOUNT
return 0
}
function mbfl_file_tail () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local i=
for ((i="${#PATHNAME}"; $i >= 0; --i)) ; do
if test "${PATHNAME:$i:1}" = "/" ; then
let ++i
printf '%s\n' "${PATHNAME:$i}"
return 0
fi
done
printf '%s\n' "${PATHNAME}"
return 0
}
function mbfl_file_find_tmpdir () {
local TMPDIR="${1}"
if test -n "${TMPDIR}" -a -d "${TMPDIR}" -a -w "${TMPDIR}"
then
echo "${TMPDIR}"
return 0
fi
if test -n "${USER}"
then
TMPDIR="/tmp/${USER}"
if test -n "${TMPDIR}" -a -d "${TMPDIR}" -a -w "${TMPDIR}"
then
echo "${TMPDIR}"
return 0
fi
fi
TMPDIR=/tmp
if test -n "${TMPDIR}" -a -d "${TMPDIR}" -a -w "${TMPDIR}"
then
echo "${TMPDIR}"
return 0
fi
mbfl_message_error "cannot find usable value for 'TMPDIR'"
return 1
}
function mbfl_file_enable_remove () {
mbfl_declare_program rm
mbfl_declare_program rmdir
}
function mbfl_file_remove () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local FLAGS="--force --recursive"
if test ! mbfl_option_test ; then
if test -e "${PATHNAME}" ; then
mbfl_message_error "pathname does not exist '${PATHNAME}'"
return 1
fi
fi
mbfl_exec_rm "${PATHNAME}" ${FLAGS}
}
function mbfl_file_remove_file () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local FLAGS="--force"
if test ! mbfl_option_test ; then
if ! mbfl_file_is_file "${PATHNAME}" ; then
mbfl_message_error "pathname is not a file '${PATHNAME}'"
return 1
fi
fi
mbfl_exec_rm "${PATHNAME}" ${FLAGS}    
}
function mbfl_exec_rm () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
shift
local RM=`mbfl_program_found rm` FLAGS
if mbfl_option_verbose_program ; then FLAGS="${FLAGS} --verbose" ; fi
if ! mbfl_program_exec "${RM}" ${FLAGS} "$@" -- "${PATHNAME}" ; then
return 1
fi
}
function mbfl_file_enable_copy () {
mbfl_declare_program cp
}
function mbfl_file_copy () {
local SOURCE=${1:?"missing source pathname parameter to '${FUNCNAME}'"}
local TARGET=${2:?"missing target pathname parameter to '${FUNCNAME}'"}
shift 2
if test ! mbfl_option_test ; then
if test ! -f "${SOURCE}" ; then
mbfl_message_error "pathname is not a file '${SOURCE}'"
return 1
fi
fi
mbfl_exec_cp "${SOURCE}" "${TARGET}" "$@"
}
function mbfl_file_copy_recursively () {
local SOURCE=${1:?"missing source pathname parameter to '${FUNCNAME}'"}
local TARGET=${2:?"missing target pathname parameter to '${FUNCNAME}'"}
shift 2
if test ! mbfl_option_test ; then
if test ! -f "${SOURCE}" ; then
mbfl_message_error "pathname is not a file '${SOURCE}'"
return 1
fi
fi
mbfl_exec_cp "${SOURCE}" "${TARGET}" --recursive "$@"
}
function mbfl_exec_cp () {
local SOURCE=${1:?"missing source pathname parameter to '${FUNCNAME}'"}
local TARGET=${2:?"missing target pathname parameter to '${FUNCNAME}'"}
shift 2
local CP=`mbfl_program_found cp` FLAGS
if mbfl_option_verbose_program ; then FLAGS="${FLAGS} --verbose" ; fi
if ! mbfl_program_exec ${CP} ${FLAGS} "$@" -- "${SOURCE}" "${TARGET}" ; then
return 1
fi
}
function mbfl_file_remove_directory () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local REMOVE_SILENTLY="${2:-no}"
local FLAGS=
if ! mbfl_file_is_directory "${PATHNAME}" ; then
mbfl_message_error "pathname is not a directory '${PATHNAME}'"
return 1
fi
if test "${REMOVE_SILENTLY}" = 'yes' ; then
FLAGS="${FLAGS} --ignore-fail-on-non-empty"
fi
mbfl_exec_rmdir "${PATHNAME}" ${FLAGS}
}
function mbfl_file_remove_directory_silently () {
mbfl_file_remove_directory "$1" yes
}
function mbfl_exec_rmdir () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
shift
local RMDIR=`mbfl_program_found rmdir` FLAGS
if mbfl_option_verbose_program ; then FLAGS="${FLAGS} --verbose" ; fi
if ! mbfl_program_exec "${RMDIR}" $FLAGS "$@" "${PATHNAME}" ; then
return 1
fi
}
function mbfl_file_enable_make_directory () {
mbfl_declare_program mkdir
}
function mbfl_file_make_directory () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local PERMISSIONS="${2:-0775}"
local MKDIR=`mbfl_program_found mkdir`
local FLAGS="--parents"
FLAGS="${FLAGS} --mode=${PERMISSIONS}"
if test -d "${PATHNAME}" ; then return 0; fi
if mbfl_option_verbose_program ; then FLAGS="${FLAGS} --verbose" ; fi
mbfl_program_exec "${MKDIR}" $FLAGS "${PATHNAME}" || return 1    
}
function mbfl_file_enable_symlink () {
mbfl_declare_program ln
}
function mbfl_file_symlink () {
local ORIGINAL_NAME=${1:?"missing original name parameter to '${FUNCNAME}'"}
local SYMLINK_NAME=${2:?"missing symbolic link name parameter to '${FUNCNAME}'"}
local LN=`mbfl_program_found ln`
local FLAGS="--symbolic"
if mbfl_option_verbose_program ; then FLAGS="${FLAGS} --verbose" ; fi
mbfl_program_exec "${LN}" ${FLAGS} "${ORIGINAL_name}" "${SYMLINK_NAME}" || return 1    
}
function mbfl_file_enable_listing () {
mbfl_declare_program ls readlink
}
function mbfl_file_get_owner () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local LS_FLAGS="-l"
set -- `mbfl_file_p_invoke_ls || return 1`
printf '%s\n' "$3"
}
function mbfl_file_get_group () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local LS_FLAGS="-l"

set -- `mbfl_file_p_invoke_ls || return 1`
printf '%s\n' "$4"
}
function mbfl_file_get_size () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
local LS_FLAGS="--block-size=1 --size"
set -- `mbfl_file_p_invoke_ls || return 1`
printf '%s\n' "$1"
}
function mbfl_file_p_invoke_ls () {
local LS=`mbfl_program_found ls`
mbfl_program_exec $LS $LS_FLAGS "${PATHNAME}"
}
function mbfl_file_normalise_link () {
local READLINK=`mbfl_program_found readlink`
mbfl_program_exec $READLINK -fn $1
}
function mbfl_p_file_print_error_return_result () {
local RESULT=$?
if test ${RESULT} != 0 -a "${PRINT_ERROR}" = 'print_error' ; then
mbfl_message_error "${ERROR_MESSAGE}"
fi
return $RESULT
}
function mbfl_file_pathname_is_readable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
local ERROR_MESSAGE="not readable pathname '${PATHNAME}'"
test -n "${PATHNAME}" -a -r "${PATHNAME}"
mbfl_p_file_print_error_return_result
}
function mbfl_file_pathname_is_writable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
local ERROR_MESSAGE="not writable pathname '${PATHNAME}'"
test -n "${PATHNAME}" -a -w "${PATHNAME}"
mbfl_p_file_print_error_return_result
}
function mbfl_file_pathname_is_executable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}    
local ERROR_MESSAGE="not executable pathname '${PATHNAME}'"
test -n "${PATHNAME}" -a -x "${PATHNAME}"
mbfl_p_file_print_error_return_result
}
function mbfl_file_is_file () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}    
local ERROR_MESSAGE="unexistent file '${PATHNAME}'"
test -n "${PATHNAME}" -a -f "${PATHNAME}"
mbfl_p_file_print_error_return_result
}
function mbfl_file_is_readable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
mbfl_file_is_file "${PATHNAME}" "${PRINT_ERROR}" && \
mbfl_file_pathname_is_readable "${PATHNAME}" "${PRINT_ERROR}"
}
function mbfl_file_is_writable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
mbfl_file_is_file "${PATHNAME}" "${PRINT_ERROR}" && \
mbfl_file_pathname_is_writable "${PATHNAME}" "${PRINT_ERROR}"
}
function mbfl_file_is_executable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
mbfl_file_is_file "${PATHNAME}" "${PRINT_ERROR}" && \
mbfl_file_pathname_is_executable "${PATHNAME}" "${PRINT_ERROR}"
}
function mbfl_file_is_directory () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
local ERROR_MESSAGE="unexistent directory '${PATHNAME}'"
test -n "${PATHNAME}" -a -d "${PATHNAME}"
mbfl_p_file_print_error_return_result
}
function mbfl_file_directory_is_readable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
mbfl_file_is_directory "${PATHNAME}" "${PRINT_ERROR}" && \
mbfl_file_pathname_is_readable "${PATHNAME}" "${PRINT_ERROR}"    
}
function mbfl_file_directory_is_writable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
mbfl_file_is_directory "${PATHNAME}" "${PRINT_ERROR}" && \
mbfl_file_pathname_is_writable "${PATHNAME}" "${PRINT_ERROR}"    
}
function mbfl_file_directory_is_executable () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}
mbfl_file_is_directory "${PATHNAME}" "${PRINT_ERROR}" && \
mbfl_file_pathname_is_executable "${PATHNAME}" "${PRINT_ERROR}"    
}
function mbfl_file_is_absolute () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
test "${PATHNAME:0:1}" = /
}
function mbfl_file_is_absolute_dirname () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
mbfl_file_is_directory "${PATHNAME}" && mbfl_file_is_absolute "${PATHNAME}"
}
function mbfl_file_is_absolute_filename () {
local PATHNAME=${1:?"missing pathname parameter to '${FUNCNAME}'"}
mbfl_file_is_file "${PATHNAME}" && mbfl_file_is_absolute "${PATHNAME}"
}
function mbfl_file_is_symlink () {
local PATHNAME=${1}
local PRINT_ERROR=${2:-no}    
local ERROR_MESSAGE="not a symbolic link pathname '${PATHNAME}'"
test -n "${PATHNAME}" -a -L "${PATHNAME}"
mbfl_p_file_print_error_return_result
}
function mbfl_file_enable_tar () {
mbfl_declare_program tar
}
function mbfl_tar_create_to_stdout () {
local DIRECTORY=${1:?"missing directory name parameter to '${FUNCNAME}'"}
shift
if ! mbfl_tar_exec --directory="${DIRECTORY}" --create --file=- "$@" . ; then
return 1
fi
}
function mbfl_tar_extract_from_stdin () {
local DIRECTORY=${1:?"missing directory name parameter to '${FUNCNAME}'"}
shift
if ! mbfl_tar_exec --directory="${DIRECTORY}" --extract --file=- "$@" ; then
return 1
fi
}
function mbfl_tar_extract_from_file () {
local DIRECTORY=${1:?"missing directory name parameter to '${FUNCNAME}'"}
local ARCHIVE_FILENAME=${2:?"missing archive pathname parameter to '${FUNCNAME}'"}
shift 2
if ! mbfl_tar_exec --directory="${DIRECTORY}" --extract --file="${ARCHIVE_FILENAME}" "$@" ; then
return 1
fi
}
function mbfl_tar_create_to_file () {
local DIRECTORY=${1:?"missing directory name parameter to '${FUNCNAME}'"}
local ARCHIVE_FILENAME=${2:?"missing archive pathname parameter to '${FUNCNAME}'"}
shift 2
if ! mbfl_tar_exec --directory="${DIRECTORY}" --create --file="${ARCHIVE_FILENAME}" "$@" . ; then return 1 ; fi
}
function mbfl_tar_archive_directory_to_file () {
local DIRECTORY=${1:?"missing directory name parameter to '${FUNCNAME}'"}
local ARCHIVE_FILENAME=${2:?"missing archive pathname parameter to '${FUNCNAME}'"}
shift 2
local PARENT=`mbfl_file_dirname "${DIRECTORY}"`
local DIRNAME=`mbfl_file_tail "${DIRECTORY}"`
if ! mbfl_tar_exec --directory="${PARENT}" --create --file="${ARCHIVE_FILENAME}" "$@" "${DIRNAME}" ; then return 1 ; fi
}
function mbfl_tar_list () {
local ARCHIVE_FILENAME=${1:?"missing archive pathname parameter to '${FUNCNAME}'"}
shift
if ! mbfl_tar_exec --list --file="${ARCHIVE_FILENAME}" "$@" ; then
return 1
fi
}
function mbfl_tar_exec () {
local TAR=`mbfl_program_found tar`
local FLAGS
if mbfl_option_verbose_program ; then FLAGS="${FLAGS} --verbose" ; fi
mbfl_program_exec "${TAR}" ${FLAGS} "$@"
}

if test "${mbfl_INTERACTIVE}" != 'yes'; then
declare -i ARGC=0
declare -a ARGV ARGV1
for ((ARGC1=0; $# > 0; ++ARGC1)); do
ARGV1[$ARGC1]="$1"
shift
done
mbfl_getopts_INDEX=0
declare -a mbfl_getopts_KEYWORDS
declare -a mbfl_getopts_DEFAULTS
declare -a mbfl_getopts_BRIEFS
declare -a mbfl_getopts_LONGS
declare -a mbfl_getopts_HASARG
declare -a mbfl_getopts_DESCRIPTION
fi
if test "${mbfl_INTERACTIVE}" != 'yes'; then
mbfl_message_DEFAULT_OPTIONS="
\t-i
\t--interactive
\t\task before doing dangerous operations
\t-f
\t--force
\t\tdo not ask before dangerous operations
\t--encoded-args
\t\tdecode arguments following this option
\t\tfrom the hex format (example: 414243 -> ABC)
\t-v
\t--verbose
\t\tverbose execution
\t--silent
\t\tsilent execution
\t--verbose-program
\t\tverbose execution for external program (if supported)
\t--show-program
\t\tprint then command line of executed external programs
\t--null
\t\tuse the null character as terminator
\t--debug
\t\tprint debug messages
\t--test
\t\ttests execution
\t--validate-programs
\t\tchecks the existence of all the required external programs
\t--version
\t\tprint version informations and exit
\t--version-only
\t\tprint version number and exit
\t--license
\t\tprint license informations and exit
\t-h
\t--help
\t--usage
\t\tprint usage informations and exit
\t-H
\t--brief-help
\t--brief-usage
\t\tprint usage informations and the list of script specific
\t\toptions, then exit
\t--print-options
\t\tprint a list of long option switches
"
fi
function mbfl_declare_option () {
local keyword="$1"
local default="$2"
local brief="$3"
local long="$4"
local hasarg="$5"
local description="$6"
local index=$(($mbfl_getopts_INDEX + 1))
mbfl_p_declare_option_test_length $keyword keyword $index
mbfl_getopts_KEYWORDS[$mbfl_getopts_INDEX]=`mbfl_string_toupper "$keyword"`
mbfl_getopts_BRIEFS[$mbfl_getopts_INDEX]=$brief
mbfl_getopts_LONGS[$mbfl_getopts_INDEX]=$long
mbfl_p_declare_option_test_length $hasarg hasarg $index
if test "$hasarg" != "witharg" -a "$hasarg" != "noarg" ; then
mbfl_message_error \
"wrong value '$hasarg' to hasarg field in option declaration number ${index}"
exit 2
fi
mbfl_getopts_HASARG[$mbfl_getopts_INDEX]=$hasarg
if test "$hasarg" = "noarg" ; then
if test "$default" != "yes" -a "$default" != "no" ; then
mbfl_message_error \
"wrong value '$default' as default for option with no argument number ${index}"
fi
fi
mbfl_getopts_DEFAULTS[$mbfl_getopts_INDEX]=$default
mbfl_p_declare_option_test_length $description description $index
mbfl_getopts_DESCRIPTION[$mbfl_getopts_INDEX]=$description
mbfl_getopts_INDEX=$index
# Creates the global option variable
eval script_option_`mbfl_string_toupper $keyword`=\'"${default}"\'
}
function mbfl_p_declare_option_test_length () {
local value="${1}"
local value_name="${2}"
local option_number=${3}
test -z "$value" && {
mbfl_message_error \
"null ${value_name} in declared option number ${option_number}"
exit 2
}
}
function mbfl_getopts_p_process_script_option () {
local OPT=${1:?"missing option name parameter to '${FUNCNAME}'"}
local OPTARG="${2:-}"
local i=0
local value=
local brief= long= hasarg= keyword= procedure= variable=
for ((i=0; $i < $mbfl_getopts_INDEX; ++i)); do
keyword="${mbfl_getopts_KEYWORDS[$i]}"
brief="${mbfl_getopts_BRIEFS[$i]}"
long="${mbfl_getopts_LONGS[$i]}"
hasarg="${mbfl_getopts_HASARG[$i]}"
if test \
\( -n "$OPT" \) -a \( \( -n "$brief" -a "$brief" = "$OPT" \) -o \
\( -n "$long"  -a "$long"  = "$OPT" \) \)
then
if test "$hasarg" = "witharg"; then
if mbfl_option_encoded_args; then
value=`mbfl_decode_hex "${OPTARG}"`
else
value="$OPTARG"
fi
else
value="yes"
fi

procedure=script_option_update_`mbfl_string_tolower $keyword`
variable=script_option_`mbfl_string_toupper $keyword`
eval $variable=\'"${value}"\'
mbfl_invoke_script_function $procedure
return 0
fi
done
return 1
}
function mbfl_getopts_parse () {
local p_OPT= p_OPTARG=
local argument= i=0
local found_end_of_options_delimiter=0
for ((i=0; $i < $ARGC1; ++i)); do
argument="${ARGV1[$i]}"
if test "$found_end_of_options_delimiter" = 1 ; then
ARGV[$ARGC]="${argument}"
let ++ARGC
elif test "${argument}" = '--' ; then
found_end_of_options_delimiter=1
elif mbfl_getopts_isbrief "${argument}" p_OPT || \
mbfl_getopts_islong "${argument}" p_OPT
then
mbfl_getopts_p_process_predefined_option_no_arg "${p_OPT}"
elif \
mbfl_getopts_isbrief_with "${argument}" p_OPT p_OPTARG || \
mbfl_getopts_islong_with  "${argument}" p_OPT p_OPTARG
then
mbfl_getopts_p_process_predefined_option_with_arg "${p_OPT}" "${p_OPTARG}"
else
ARGV[$ARGC]="${argument}"
let ++ARGC
fi
done
mbfl_getopts_p_decode_hex
return 0
}
function mbfl_getopts_p_process_predefined_option_no_arg () {
local OPT="${1:?}"
local i=0
case "${OPT}" in
	encoded-args)
mbfl_set_option_encoded_args
	    ;;
	v|verbose)
mbfl_set_option_verbose
	    ;;
	silent)
mbfl_unset_option_verbose
	    ;;
	verbose-program)
mbfl_set_option_verbose_program
	    ;;
	show-program)
mbfl_set_option_show_program
	    ;;
	debug)
mbfl_set_option_verbose
	    ;;
	test)
mbfl_set_option_test
	    ;;
	null)
mbfl_set_option_null
	    ;;
f|force)
mbfl_unset_option_interactive
	    ;;
i|interactive)
mbfl_set_option_interactive
	    ;;
validate-programs)
mbfl_main_set_private_main mbfl_program_main_validate_programs
;;
	version)
	    echo -e "${mbfl_message_VERSION}"
	    exit 0
	    ;;
	version-only)
	    echo -e "${script_VERSION}"
	    exit 0
	    ;;
	license)
case "${script_LICENSE}" in
GPL)
echo -e "${mbfl_message_LICENSE_GPL}"
;;
LGPL)
echo -e "${mbfl_message_LICENSE_LGPL}"
;;
BSD)
echo -e "${mbfl_message_LICENSE_BSD}"
;;
*)
mbfl_message_error "unknown license: \"${script_LICENSE}\""
exit 2
;;
esac
	    exit 0
	    ;;
	h|help|usage)
	    echo -e "${script_USAGE}"
test -n "${script_DESCRIPTION}" && echo -e "${script_DESCRIPTION}"
echo 'options:'
mbfl_getopts_p_build_and_print_options_usage
echo -e "${mbfl_message_DEFAULT_OPTIONS}"
	    exit 0
	    ;;
	H|brief-help|brief-usage)
	    echo -e "${script_USAGE}"
test -n "${script_DESCRIPTION}" && echo -e "${script_DESCRIPTION}"
echo 'options:'
mbfl_getopts_p_build_and_print_options_usage
	    exit 0
	    ;;
print-options)
mbfl_getopts_print_long_switches
exit 0
;;
	*)
mbfl_getopts_p_process_script_option "${OPT}" || {
mbfl_message_error "unknown option: '${OPT}'"
exit 2
}
	    ;;
esac
return 0
}
function mbfl_getopts_p_process_predefined_option_with_arg () {
local OPT="${1:?}"
local OPTARG="${2:?}"
mbfl_option_encoded_args && OPTARG=$(mbfl_decode_hex "${OPTARG}")
# at present no options with argument are declared by MBFL
case "${OPT}" in
	*)
	    mbfl_getopts_p_process_script_option "${OPT}" "${OPTARG}" || {
mbfl_message_error "unknown option \"${OPT}\""
exit 2
}
	    ;;
esac
return 0
}
function mbfl_getopts_p_build_and_print_options_usage () {
local i=0 item
local brief= long= description= long_hasarg= long_hasarg=
for ((i=0; $i < $mbfl_getopts_INDEX; ++i)); do
if test "${mbfl_getopts_HASARG[$i]}" = 'witharg' ; then
brief_hasarg="VALUE"
long_hasarg="=VALUE"
else
brief_hasarg=
long_hasarg=
fi
brief="${mbfl_getopts_BRIEFS[$i]}"
test -n "$brief" && echo -e "\t-${brief}${brief_hasarg}"
long="${mbfl_getopts_LONGS[$i]}"
test -n "$long" && echo -e "\t--${long}${long_hasarg}"
description="${mbfl_getopts_DESCRIPTION[$i]}"
if test -z "${description}" ; then
description='undocumented option'
fi
if test "${mbfl_getopts_HASARG[$i]}" = 'witharg' ; then
item="${mbfl_getopts_DEFAULTS[$i]}"
if test -n "${item}" ; then
description="${description}\n\t\t(default: '${item}')"
else
description="${description}\n\t\t(default: empty)"
fi
fi
echo -e "\t\t$description"
done
}
function mbfl_getopts_islong () {
local ARGUMENT=${1:?"missing argument parameter to '${FUNCNAME}'"}
local OPTION_VARIABLE_NAME="${2:-}"
local len="${#ARGUMENT}" i ch
test $len -lt 3 -o "${ARGUMENT:0:2}" != "--"  && return 1
for ((i=2; $i < $len; ++i)); do
ch="${ARGUMENT:$i:1}"
mbfl_p_getopts_not_char_in_long_option_name "$ch" && return 1
done
mbfl_set_maybe "${OPTION_VARIABLE_NAME}" "${ARGUMENT:2}"
return 0
}
function mbfl_getopts_islong_with () {
local ARGUMENT=${1:?"missing argument parameter to '${FUNCNAME}'"}
local OPTION_VARIABLE_NAME="${2:-}"
local VALUE_VARIABLE_NAME="${3:-}"
local len="${#ARGUMENT}" equal_position
# The min length of a long option with is 5 (example: --o=1).
test $len -lt 5 && return 1
equal_position=`mbfl_string_first "${ARGUMENT}" =`
test -z "$equal_position" -o $(($equal_position + 1)) = $len && return 1
mbfl_getopts_islong "${ARGUMENT:0:$equal_position}" || return 1
mbfl_set_maybe "${OPTION_VARIABLE_NAME}" \
"${ARGUMENT:2:$(($equal_position - 2))}"
mbfl_set_maybe "${VALUE_VARIABLE_NAME}" \
"${ARGUMENT:$(($equal_position + 1))}"
return 0
}
function mbfl_p_getopts_not_char_in_long_option_name () {
test \
\( "$1" \< A -o Z \< "$1" \) -a \
\( "$1" \< a -o z \< "$1" \) -a \
\( "$1" \< 0 -o 9 \< "$1" \) -a \
"$1" != _ -a "$1" != -
}
function mbfl_getopts_isbrief () {
local COMMAND_LINE_ARGUMENT=${1:?"missing command line argument parameter to '${FUNCNAME}'"}
local OPTION_VARIABLE_NAME="${2:-}"
local ch
test "${#COMMAND_LINE_ARGUMENT}" = 2 -a \
"${COMMAND_LINE_ARGUMENT:0:1}" = "-" || return 1
mbfl_p_getopts_not_char_in_brief_option_name \
"${COMMAND_LINE_ARGUMENT:1:1}" && return 1
mbfl_set_maybe "${OPTION_VARIABLE_NAME}" "${COMMAND_LINE_ARGUMENT:1}"
return 0
}
function mbfl_getopts_isbrief_with () {
local COMMAND_LINE_ARGUMENT=${1:?"missing command line argument parameter to '${FUNCNAME}'"}
local OPTION_VARIABLE_NAME="${2:-}"
local VALUE_VARIABLE_NAME="${3:-}"
test "${#COMMAND_LINE_ARGUMENT}" -gt 2 -a \
"${COMMAND_LINE_ARGUMENT:0:1}" = "-" || return 1
mbfl_p_getopts_not_char_in_brief_option_name \
"${COMMAND_LINE_ARGUMENT:1:1}" && return 1
mbfl_set_maybe "${OPTION_VARIABLE_NAME}" "${COMMAND_LINE_ARGUMENT:1:1}"
local QUOTED_VALUE=`mbfl_string_quote "${COMMAND_LINE_ARGUMENT:2}"`
mbfl_set_maybe "${VALUE_VARIABLE_NAME}" "${QUOTED_VALUE}"
return 0
}
function mbfl_p_getopts_not_char_in_brief_option_name () {
test \
\( "$1" \< A -o Z \< "$1" \) -a \
\( "$1" \< a -o z \< "$1" \) -a \
\( "$1" \< 0 -o 9 \< "$1" \)
}
function mbfl_getopts_p_decode_hex () {
local i=0
mbfl_option_encoded_args && {
for ((i=0; $i < $ARGC; ++i))
do ARGV[$i]=`mbfl_decode_hex "${ARGV[$i]}"`
done
}
return 0
}
function mbfl_wrong_num_args () {
local required=${1:?"missing required number of args parameter to '${FUNCNAME}'"}
local argc=${2:?"missing given number of args parameter to '${FUNCNAME}'"}
test $required != $argc && {
mbfl_message_error "number of arguments required: $required"
return 1
}
return 0
}
function mbfl_argv_from_stdin () {
local file=
test $ARGC -eq 0 || {
while mbfl_read_maybe_null file ; do
ARGV[$ARGC]="${file}"
let ++ARGC
done
}
return 0
}
function mbfl_argv_all_files () {
local i file
for ((i=0; $i < $ARGC; ++i)) ; do
	file=`mbfl_file_normalise "${ARGV[$i]}"`
	if test ! -f "${file}" ; then
	    mbfl_message_error "unexistent file '${file}'"
	    return 1
	fi
	ARGV[$i]="${file}"
done
return 0
}
function mbfl_getopts_p_test_option () {
test "${!1}" = "yes" && return 0
return 1
}
function mbfl_getopts_print_long_switches () {
for ((i=0; $i < ${#mbfl_getopts_LONGS[@]}; ++i)); do
if test -n "${mbfl_getopts_LONGS[$i]}" ; then
echo -n "--${mbfl_getopts_LONGS[$i]}"
else
continue
fi
test $(($i+1)) -lt ${#mbfl_getopts_LONGS[@]} && echo -n ' '
done
echo
return 0
}

mbfl_message_PROGNAME="${0}"
mbfl_message_CHANNEL="2"
function mbfl_message_set_progname () {
mbfl_message_PROGNAME="${1:?${FUNCNAME} error: missing program name argument}"
}
function mbfl_message_set_channel () {
mbfl_message_CHANNEL="${1:?${FUNCNAME} error: missing channel argument}"
}
function mbfl_message_p_print () {
printf "${2:?${1} error: missing argument}" >&${mbfl_message_CHANNEL}
}
function mbfl_message_p_print_prefix () {
mbfl_message_p_print ${1} "${mbfl_message_PROGNAME}: ${2}"
}
function mbfl_message_string () {
mbfl_message_p_print ${FUNCNAME} "$1"
return 0
}
function mbfl_message_verbose () {
mbfl_option_verbose && mbfl_message_p_print_prefix ${FUNCNAME} "$1"
return 0
}
function mbfl_message_verbose_end () {
mbfl_option_verbose && mbfl_message_p_print ${FUNCNAME} "$1\n"
return 0
}
function mbfl_message_debug () {
mbfl_option_debug && mbfl_message_p_print_prefix ${FUNCNAME} "debug: $1\n"
return 0
}
function mbfl_message_warning () {
mbfl_message_p_print_prefix ${FUNCNAME} "warning: $1\n"
return 0
}
function mbfl_message_error () {
mbfl_message_p_print_prefix ${FUNCNAME} "error: $1\n"
return 0
}

function mbfl_program_check () {
local item= path=
for item in "${@}"; do
path=`mbfl_program_find "${item}"`
if test ! -x "${path}" ; then
mbfl_message_error "cannot find executable '${item}'"
return 1
fi
done
return 0
}
function mbfl_program_find () {
local PROGRAM=${1:?"missing program parameter to ${FUNCNAME}"}
local program=
for program in `type -ap "${PROGRAM}"`; do
if test -n "${program}" -a -x "${program}"; then
echo "${program}"
return 0
fi
done
return 0
}
function mbfl_program_exec () {
if mbfl_option_test || mbfl_option_show_program ; then
echo "${@}" >&2
fi
if ! mbfl_option_test ; then
"${@}"
fi
}
if test "${mbfl_INTERACTIVE}" != 'yes'; then
declare -a mbfl_program_NAMES mbfl_program_PATHS
declare -i mbfl_program_INDEX=0
fi
function mbfl_declare_program () {
local PROGRAM=${1:?"missing program parameter to ${FUNCNAME}"}
local i=$mbfl_program_INDEX
mbfl_program_NAMES[$i]="${PROGRAM}"
mbfl_program_PATHS[$i]=`mbfl_program_find "${PROGRAM}"`
mbfl_program_INDEX=$(($i + 1))
return 0
}
function mbfl_program_validate_declared () {
local i= name= path= retval=0
for ((i=0; $i < $mbfl_program_INDEX; ++i)); do
name="${mbfl_program_NAMES[$i]}"
path="${mbfl_program_PATHS[$i]}"
if test -n "${path}" -a -x "${path}"; then
mbfl_message_verbose "found '${name}': '${path}'\n"
else
mbfl_message_verbose "*** not found '${name}', path: '${path}'\n"
retval=1
fi
done
return $retval
}
function mbfl_program_found () {
local PROGRAM="${1:?${FUNCNAME} error: missing program name}"
local i=
if test "${PROGRAM}" != ':' ; then
for ((i=0; $i < $mbfl_program_INDEX; ++i)); do
if test "${mbfl_program_NAMES[$i]}" = "${PROGRAM}" ; then
echo "${mbfl_program_PATHS[$i]}"
return 0
fi
done
fi
mbfl_message_error "executable not found \"${PROGRAM}\""
mbfl_exit_program_not_found
}
function mbfl_program_main_validate_programs () {
mbfl_program_validate_declared || mbfl_exit_program_not_found
}

if test "${mbfl_INTERACTIVE}" != 'yes'; then
declare -a mbfl_signal_HANDLERS
i=0
{ while kill -l $i ; do let ++i; done; } &>/dev/null
declare -i mbfl_signal_MAX_SIGNUM=$i
fi
function mbfl_signal_map_signame_to_signum () {
local SIGSPEC=${1:?"missing signal name parameter to '${FUNCNAME}'"}
local i name
for ((i=0; $i < $mbfl_signal_MAX_SIGNUM; ++i)) ; do
test "SIG`kill -l $i`" = "${SIGSPEC}" && {
echo $i
return 0
}
done
return 1
}
function mbfl_signal_attach () {
local SIGSPEC=${1:?"missing signal name parameter to '${FUNCNAME}'"}
local HANDLER=${2:?"missing function name parameter to '${FUNCNAME}'"}
local signum
signum=`mbfl_signal_map_signame_to_signum "${SIGSPEC}"` || return 1
if test -z ${mbfl_signal_HANDLERS[${signum}]} ; then
mbfl_signal_HANDLERS[${signum}]=${HANDLER}
else
mbfl_signal_HANDLERS[${signum}]="${mbfl_signal_HANDLERS[${signum}]}:${HANDLER}"
fi
mbfl_message_debug "attached '$HANDLER' to signal ${SIGSPEC}"
trap -- "mbfl_signal_invoke_handlers ${signum}" ${signum}
}
function mbfl_signal_invoke_handlers () {
local SIGNUM=${1:?"missing signal number parameter to '${FUNCNAME}'"}
local handler ORGIFS="$IFS"
mbfl_message_debug "received signal 'SIG`kill -l ${SIGNUM}`'"
IFS=:
for handler in ${mbfl_signal_HANDLERS[$SIGNUM]} ; do
IFS="$ORGIFS"
mbfl_message_debug "registered handler: ${handler}"
test -n "${handler}" && eval ${handler}
done
IFS="$ORGIFS"
return 0
}

function mbfl_variable_find_in_array () {
local ELEMENT=${1:?"missing element parameter parameter to '${FUNCNAME}'"}
declare -i i ARRAY_DIM=${#mbfl_FIELDS[*]}

for ((i=0; $i < ${ARRAY_DIM}; ++i)) ; do
	test "${mbfl_FIELDS[$i]}" = "${ELEMENT}" && { printf "$i\n"; return 0; }
done
return 1
}
function mbfl_variable_element_is_in_array () {
local pos
pos=`mbfl_variable_find_in_array "$@"`
}
function mbfl_variable_colon_variable_to_array () {
local COLON_VARIABLE=${1:?"missing colon variable parameter to '${FUNCNAME}'"}
local ORGIFS="${IFS}" item count=0
IFS=:
for item in ${!COLON_VARIABLE} ; do
	IFS="${ORGIFS}"
	mbfl_FIELDS[${count}]="${item}"
	let ++count
done
IFS="${ORGIFS}"
return 0
}
function mbfl_variable_array_to_colon_variable () {
local COLON_VARIABLE=${1:?"missing colon variable parameter to '${FUNCNAME}'"}
declare -i i dimension=${#mbfl_FIELDS[*]}
if test ${dimension} = 0 ; then
	eval ${COLON_VARIABLE}=
else
	eval ${COLON_VARIABLE}=\'"${mbfl_FIELDS[0]}"\'
	for ((i=1; $i < ${dimension}; ++i)); do
	    eval ${COLON_VARIABLE}=\'"${!COLON_VARIABLE}:${mbfl_FIELDS[$i]}"\'
	done
fi
return 0
}
function mbfl_variable_colon_variable_drop_duplicate () {
local COLON_VARIABLE=${1:?"missing colon variable parameter to '${FUNCNAME}'"}
local item
declare -a mbfl_FIELDS FIELDS
declare -i dimension count i 
mbfl_variable_colon_variable_to_array "${COLON_VARIABLE}"
dimension=${#mbfl_FIELDS[*]}
FIELDS=("${mbfl_FIELDS[@]}")
mbfl_FIELDS=()
for ((i=0, count=0; $i < ${dimension}; ++i)); do
	item="${FIELDS[$i]}"
	mbfl_variable_element_is_in_array "${item}" && continue
	mbfl_FIELDS[${count}]="${item}"
	let ++count
done
mbfl_variable_array_to_colon_variable ${COLON_VARIABLE}
return 0
}

function mbfl_dialog_yes_or_no () {
local STRING=${1:?"missing prompt string parameter to '${FUNCNAME}'"}
local PROGNAME="${2:-${script_PROGNAME}}"
local PROMPT="${PROGNAME}: ${STRING}? (yes/no) "
local ANS=

while read -e -p "${PROMPT}" ANS && test "$ANS" != 'yes' -a "$ANS" != 'no'; do
echo "${PROGNAME}: please answer yes or no."
done
if test "$ANS" = yes ; then return 0; else return 1; fi
}
function mbfl_dialog_ask_password () {
local PROMPT=${1:?"missing prompt parameter to '${FUNCNAME}'"}
local PASSWORD=
local STTY=`mbfl_program_found stty`
echo -n "${prompt}: " >&2
${STTY} cbreak -echo </dev/tty >/dev/tty 2>&1
read PASSWORD
${STTY} -cbreak echo </dev/tty >/dev/tty 2>&1
echo >&2
echo -n "${PASSWORD}"
}

if test "${mbfl_INTERACTIVE}" != 'yes'; then
mbfl_option_TMPDIR="${TMPDIR:-/tmp}"
mbfl_ORG_PWD="${PWD}"
mbfl_main_SCRIPT_FUNCTION=main
mbfl_main_PRIVATE_SCRIPT_FUNCTION=
fi
function mbfl_main_set_main () {
mbfl_main_SCRIPT_FUNCTION="${1:?}"
}
function mbfl_main_set_private_main () {
mbfl_main_PRIVATE_SCRIPT_FUNCTION="${1:?}"
}
if test "${mbfl_INTERACTIVE}" != 'yes'; then
mbfl_message_LICENSE_GPL="${script_PROGNAME} version ${script_VERSION}
Written by ${script_AUTHOR}.\n
Copyright (C) ${script_COPYRIGHT_YEARS} by ${script_AUTHOR}.\n
This file  is free software you  can redistribute it  and/or modify it
under the terms of the GNU  General Public License as published by the
Free Software  Foundation; either version  2, or (at your  option) any
later version.\n
This  file is  distributed in  the hope  that it  will be  useful, but
WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
General Public License for more details.\n
You  should have received  a copy  of the  GNU General  Public License
along with this file; see the file COPYING.  If not, write to the Free
Software Foundation,  Inc., 59  Temple Place -  Suite 330,  Boston, MA
02111-1307, USA.
"
mbfl_message_LICENSE_LGPL="${script_PROGNAME} version ${script_VERSION}
Written by ${script_AUTHOR}.\n
Copyright (C) ${script_COPYRIGHT_YEARS} by ${script_AUTHOR}.\n
This is free software; you  can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the
Free Software  Foundation; either version  2.1 of the License,  or (at
your option) any later version.\n
This library  is distributed in the  hope that it will  be useful, but
WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
Lesser General Public License for more details.\n
You  should have  received a  copy of  the GNU  Lesser  General Public
License along  with this library; if  not, write to  the Free Software
Foundation, Inc.,  59 Temple Place,  Suite 330, Boston,  MA 02111-1307
USA.
"
mbfl_message_LICENSE_BSD="${script_PROGNAME} version ${script_VERSION}
Written by ${script_AUTHOR}.\n
Copyright (C) ${script_COPYRIGHT_YEARS} by ${script_AUTHOR}.\n
The author  hereby grant permission to use,  copy, modify, distribute,
and  license this  software  and its  documentation  for any  purpose,
provided that  existing copyright notices  are retained in  all copies
and that  this notice  is included verbatim  in any  distributions. No
written agreement, license, or royalty  fee is required for any of the
authorized uses.  Modifications to this software may be copyrighted by
their authors and need not  follow the licensing terms described here,
provided that the new terms are clearly indicated on the first page of
each file where they apply.\n
IN NO  EVENT SHALL THE AUTHOR  OR DISTRIBUTORS BE LIABLE  TO ANY PARTY
FOR  DIRECT, INDIRECT, SPECIAL,  INCIDENTAL, OR  CONSEQUENTIAL DAMAGES
ARISING OUT  OF THE  USE OF THIS  SOFTWARE, ITS DOCUMENTATION,  OR ANY
DERIVATIVES  THEREOF, EVEN  IF THE  AUTHOR  HAVE BEEN  ADVISED OF  THE
POSSIBILITY OF SUCH DAMAGE.\n
THE  AUTHOR  AND DISTRIBUTORS  SPECIFICALLY  DISCLAIM ANY  WARRANTIES,
INCLUDING,   BUT   NOT  LIMITED   TO,   THE   IMPLIED  WARRANTIES   OF
MERCHANTABILITY,    FITNESS   FOR    A    PARTICULAR   PURPOSE,    AND
NON-INFRINGEMENT.  THIS  SOFTWARE IS PROVIDED  ON AN \"AS  IS\" BASIS,
AND  THE  AUTHOR  AND  DISTRIBUTORS  HAVE  NO  OBLIGATION  TO  PROVIDE
MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
"
fi
if test "${mbfl_INTERACTIVE}" != 'yes'; then
mbfl_message_VERSION="${script_PROGNAME} version ${script_VERSION}
Written by ${script_AUTHOR}.\n
Copyright (C) ${script_COPYRIGHT_YEARS} by ${script_AUTHOR}.\n
This is  free software; see the  source or use the  --license option for
copying conditions.  There is NO warranty; not  even for MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.
"
fi
function mbfl_main () {
local exit_code=0
local action_func=
local item=
mbfl_message_set_progname "${script_PROGNAME}"
mbfl_invoke_script_function script_before_parsing_options
mbfl_getopts_parse
mbfl_invoke_script_function script_after_parsing_options
if test -n "${mbfl_main_PRIVATE_SCRIPT_FUNCTION}" ; then
mbfl_invoke_script_function ${mbfl_main_PRIVATE_SCRIPT_FUNCTION}
else
mbfl_invoke_script_function ${mbfl_main_SCRIPT_FUNCTION}
fi
}
function mbfl_invoke_script_function () {
local item="${1:?${FUNCNAME} error: missing function name}"
if test "`type -t ${item}`" = "function"; then ${item}; else return 0; fi
}


### end of file
# Local Variables:
# mode: sh
# End: