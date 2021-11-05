#!/bin/bash
# Defining the makefile commands
# make <command>:<target>

# ANSI terminal colors (see 'man tput') ----- {{{1
# See 'man tput' and https://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/. Don't use color if there isn't a $TERM environment variable.
BOLD=`tput bold`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
WHITE=`tput setaf 7`
RESET=`tput sgr0`

#}}}1

# Default directories ------------------------------------------------------------------------- {{{1
TRASH_COMMAND='gio trash'
#}}}1

# Usage function ------------------------------------------------------------------------------ {{{1
# This function displays the usage section of the code/
function usage() {
	echo "${BOLD}ACHERON PROJECT KEYBOARD CREATOR TOOL ${RESET}
${BOLD}Created by:${RESET} Álvaro "Gondolindrim" Volpato
${BOLD}Link:${RESET} https://acheronproject.com/acheron_setup/acheron_setup/
${BOLD}Version:${RESET} 1.0 (november 4, 2021)
${BOLD}Description: ${RESET}The Acheron Keyboard Creator tool is a bash-script tool aimed at automating the process of creating a KiCAD PCB project for a keyboard PCB. The produced files are ready-to-use and can be edited and modified using the latest KiCAD nightly (november 4, 2021 or newer) and include configuration settings such as copper clearance and tolerance, soldermask clearance and minimum width aimed at being compatible across multiple factories.
${BOLD}Usage: $0 [options] [arguments] (Note: ${GREEN}green${WHITE} values signal default values. Options and arguments are case-sensitive.)
${GREEN}>>${WHITE} Options:${RESET}
	${BOLD}[-h,  --help]${RESET}		Displays this message and exists.
        ${BOLD}[-pc, --purgeclean]${RESET}	Deletes all generated files before execution (*.git folders and files and the KICADDIR), leaving only the original repository, and proceeds normal execution. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-cc, --cleancreate]${RESET}	Creates cleanly, removing all base files including this script, leaving only the final files. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-ng, --nographics]${RESET}	Do not include graphics library submodule. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-nl, --nologos]${RESET}	Do not include logos library submodule. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-n3, --no3d]${RESET}		Do not include 3D models library submodule. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-nr, --norepo]${RESET}		Do not init a git repository. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-ns, --nosubmodule]${RESET}	Do not add libraries as git submodules. (Note: if the --norepo flag is not passed, a git repository will still be initiated). ${BOLD}${GREEN}(F)${RESET}
${GREEN}>>${BOLD}${WHITE} Arguments:${RESET}
	${BOLD}[-t,  --template]${RESET}	Choose what template to use. ${BOLD}Options are:
						${GREEN}- BLANK${WHITE} for a blank PCB with pre-configured settings
						- J48 for the 48-pin joker template
						- J64 for the 64-pin joker template
	${BOLD}[-p,  --projectname]${RESET}	Do not include 3D models library submodule. ${BOLD}${GREEN}('project')${RESET}
	${BOLD}[-kd, --kicaddir]${RESET}	Chooses the project parent folder name ${BOLD}${GREEN}('kicad_files')${RESET}
	${BOLD}[-ld, --libdir]${RESET}		Chooses the folder inside KICADDIR where libraries and submodules are added. ${BOLD}${GREEN}('libraries')${RESET}
	${BOLD}[-s,  --switchtype]${RESET}	Select what switch type library submodule to be added. ${BOLD} Options are:
						${GREEN}- 'MX'${WHITE} for simple MX support (https://github.com/AcheronProject/acheron_MX.pretty)
						- 'MX_soldermask' for MX support with covered front switches (https://github.com/AcheronProject/acheron_MX_soldermask.pretty)
						- 'MXA' for MX and Alps suport (https://github.com/AcheronProject/acheron_MXA.pretty)
						- 'MXH' for MX hostwap (https://github.com/AcheronProject/acheron_MXH.pretty)
${RESET}"
}
# }}}1

# Parsing options and arguments --------------------------------------------------------------- {{{1
# DEFAULTS
LIBDIR='libraries'
KICADDIR='kicad_files'
ACRNPRJ_REPO='git@github.com:AcheronProject'
NOGRAPHICS=false
NO3D=false
NOLOGOS=false
NO_GIT_REPO=false
NO_GIT_SUBMODULES=false
CLEANCREATE=false
PURGECLEAN=false
SWITCHTYPE='MX'
PRJNAME='project'
TEMPLATE='BLANK'

while :; do
	case $1 in
	# HANDLING ARGUMENTS ---------------------
		-h | --help)
			usage
			exit 0
			;;
		-cc | --cleancreate)
			CLEANCREATE=true
			;;
		-nl | --nologos)
			NOLOGOS=true
			;;
		-ng | --nographics)
			NOGRAPHICS=true
			;;
		-n3 | --no3d)
			NO3D=true
			;;
		-nr | --norepo)
			NO_GIT_REPO=true
			;;
		-ns | --nosubmodule)
			NO_GIT_SUBMODULES=true
			;;
		-pc | --purgeclean)
			PURGECLEAN=true
			;;
	# HANDLING OPTIONS -----------------------
		# TEMPLATE ARGUMENT --------------
		-t | --template)
			if ["$2" ]; then
				TEMPLATE=$2
				shift
			else
				echo "${BOLD}${RED} ERROR:${RESET} --template argument requires a string."
			fi
			;;
		--template=?*)
			TEMPLATE=${1#*=} # Deletes everything up to "=" and assigns the remainder
			;;
		--template=)
			echo "${BOLD}${RED} ERROR:${RESET} --template argument requires a string."
			;;
		# KICADDIR ARGUMENT --------------
		-kd | --kicaddir)
			if ["$2" ]; then
				KICADDIR=$2
				shift
			else
				echo "${BOLD}${RED} ERROR:${RESET} --kicaddir argument requires a string."
			fi
			;;
		--kicaddir=?*)
			KICADDIR=${1#*=} # Deletes everything up to "=" and assigns the remainder
			;;
		--kicaddir=)
			echo "${BOLD}${RED} ERROR:${RESET} --kicaddir argument requires a string."
			;;
		# LIBDIR ARGUMENT ----------------
		-ld | --libdir)
			if ["$2" ]; then
				LIBDIR=$2
				shift
			else
				echo "${BOLD}${RED} ERROR:${RESET} --libdir argument requires a string."
			fi
			;;
		--libdir=?*)
			LIBDIR=${1#*=} # Deletes everything up to "=" and assigns the remainder
			;;
		--libdir=)
			echo "${BOLD}${RED} ERROR:${RESET} --libdir argument requires a string."
			;;
		# LIBDIR ARGUMENT ----------------
		-p | --projectname)
			if ["$2" ]; then
				PRJNAME= $2
				shift
			else
				echo "${BOLD}${RED} ERROR:${RESET} --projectname argument requires a string."
			fi
			;;
		--projectname=?*)
			PRJNAME=${1#*=} # Deletes everything up to "=" and assigns the remainder
			;;
		--projectname=)
			echo "${BOLD}${RED} ERROR:${RESET} --projectname argument requires a string."
			;;
		-s | --switchtype)
			if ["$2" ]; then
				SWITCHTYPE = $2
				shift
			else
				echo "${BOLD}${RED} ERROR:${RESET} --switchtype argument requires a string."
			fi
			;;
		--switchtype=?*)
			SWITCHTYPE=${1#*=} # Deletes everything up to "=" and assigns the remainder
			;;
		--switchtype=)
			echo "${BOLD}${RED} ERROR:${RESET} --switchtype argument requires a string."
			;;
		*)
			break
	esac
	shift
done
#}}}1

# Checking if the limited options are in the allowed values ----------------------------------- {{{1
ALLOWED_SWITCHTYPES=(MX MX_soldermask MXA MXH) 
if [[ ! ${ALLOWED_SWITCHTYPES[*]} =~ (^|[[:space:]])"${SWITCHTYPE}"($|[[:space:]]) ]]; then
	echo "${BOLD}${RED}>> ERROR:${WHITE} switch type option '${SWITCHTYPE}' is not recognized. Run the script with the '-h' option for usage guidelines.${RESET}"
	exit 1
fi

ALLOWED_TEMPLATES=(BLANK J48 J64)
if [[ ! ${ALLOWED_TEMPLATES[*]} =~ (^|[[:space:]])"${TEMPLATE}"($|[[:space:]]) ]]; then
	echo "${BOLD}${RED}>> ERROR:${WHITE} template option '${TEMPLATE}' is not recognized. Run the script with the '-h' option for usage guidelines.${RESET}"
	exit 1
fi
#}}}1

# check function ---------------------------- {{{1
# check is a function made to check if a folder exists. If not, creates that folder. The folder to be checked is signalled through the "TARGET_FOLDER" argument.
# The function accepts a single obligatory option which can be two values: kicaddir and libdir, the former checking and creating ${KICADDIR} and the latter ${LIBDIR}. One interesting thing to note is that the LIBDIR check calls the mkdir command with a -p option, meaning that if adittionally ${KICADDIR} does not exist it will be created as well. This is because most of the time, check libdir will suffice.
check() {
	if [ -z "$1" ] ; then
		echo -e "${BOLD}${RED} >> ERROR:${WHITE} function check called with no argument passed.${RESET}"
		return '0'
	fi
	local TARGET_FOLDER="$1"
	case $TARGET_FOLDER in
	libdir)
		if [ ! -d ${KICADDIR}/${LIBDIR} ] ; then
			echo -e "${BOLD} >> LIBDIR check: ${RED}Libraries directory at ${KICADDIR}/${LIBDIR} not found${WHITE}. Creating it...${RESET} \c"
			mkdir -p ${KICADDIR}/${LIBDIR}
			echo "${BOLD}${GREEN}Done.${RESET}"
		fi
		return 1
		;; 
	kicaddir)
		if [ ! -d ${KICADDIR} ] ; then 
			echo -e "${BOLD} >> KICADDIR check: ${RED}KiCAD directory at ${KICADDIR} not found${WHITE}. Creating it...${RESET} \c" ; 
			mkdir -p ${KICADDIR}; 
			echo " ${BOLD}${GREEN}Done.${RESET}" ; 
		fi
		return 1
		;;
	*)
		echo -e "${BOLD}${YELLOW} >> WARNING:${WHITE} check() function called with unrecognized argument.${RESET}"
		return 2
	esac
}
#}}}1
#
# kicad_setup function ---------------------- {{{1
# kicad_setup is a function that checks if kicaddir exists; if not, creates it; then copies the files in joker_template to kicaddir and adds symbol and footprint library tables.
# This function takes one argument: "TEMPLATE_NAME", which can be "blank", "joker48" or "joker64" pertaining to each available template.
kicad_setup() {
	if [ -z "$1" ] ; then
		echo "${RED}${BOLD} >> ERROR${WHITE} on function kicad_setup:${RESET} no argument passed."
		return 0
	fi
	local TEMPLATE_NAME="$1" 
	local TEMPLATE_DIR='blank_template'
	local TEMPLATE_FILENAME='blank'
	case $TEMPLATE_NAME in
		BLANK)
			;;
		J48)
			TEMPLATE_DIR='joker48_template'
			TEMPLATE_FILENAME='joker48'
			;;
		J64)
			TEMPLATE_DIR='joker64_template'
			TEMPLATE_FILENAME='joker64'
			;;
		*)
			echo "${RED}${BOLD} >> ERROR${WHITE} on function kicad_setup:${RESET} TEMPLATE_NAME option '${TEMPLATE_NAME}' unrecognized."
			return 0
	esac
	check libdir
	cat ${TEMPLATE_DIR}/${TEMPLATE_FILENAME}.kicad_pro > ${KICADDIR}/${PRJNAME}.kicad_pro
	cat ${TEMPLATE_DIR}/${TEMPLATE_FILENAME}.kicad_pcb > ${KICADDIR}/${PRJNAME}.kicad_pcb
	cat ${TEMPLATE_DIR}/${TEMPLATE_FILENAME}.kicad_prl > ${KICADDIR}/${PRJNAME}.kicad_prl
	cat ${TEMPLATE_DIR}/${TEMPLATE_FILENAME}.kicad_sch > ${KICADDIR}/${PRJNAME}.kicad_sch
	cp  ${TEMPLATE_DIR}/sym-lib-table ${KICADDIR}
	cp  ${TEMPLATE_DIR}/fp-lib-table ${KICADDIR}
	return 1
}


#}}}1

# git "add" functions ----------------------- {{{1
# The add_library function does exactly that: adds a library to the project. However, this can be done in two ways: either as a git submodule or simply cloning the library from its repository; the behavior depends on the NO_GIT_SUBMODULES flag set when the script is called. The other two functions, add_symlib and add_footprint lib, are based on add_submodule. What they do, adittionally to adding a symbol or footprint library submodule, is also adding that library to KiCAD's library tables "sym-lib-table" and "fp-lib-table" throught the sed command. It must be noted that these two files should not be created from scratch as they have a header and a footer; hence, the template folders contain unedited, blank version of these files.
add_library() {
	if [ -z "$1" ] ; then
		echo "${RED}${BOLD} >> ERROR${WHITE} on function add_submodule():${RESET} no argument passed."
		exit 0
	fi
	if [ -z "$2" ] ; then
		echo "${RED}${BOLD} >> ERROR${WHITE} on function add_submodule():${RESET} not enough arguments passed (2 required, only 1 passed)."
		exit 0
	fi
	local TARGET_LIBRARY="$1"
	local NO_GIT_SUBMODULES="$2" 
	if [ "$NO_GIT_SUBMODULES" = 'false' ] ; then
		echo -e "${BOLD} >> Adding ${MAGENTA}${TARGET_LIBRARY}${WHITE} library as a submodule from ${BLUE}${BOLD}${ACRNPRJ_REPO}/${TARGET_LIBRARY}.git${RESET} at ${RED}${BOLD}\"${KICADDIR}/${LIBDIR}/${TARGET_LIBRARY}\"${RESET} folder... \c" 
		git submodule add ${ACRNPRJ_REPO}/${TARGET_LIBRARY}.git ${KICADDIR}/${LIBDIR}/${TARGET_LIBRARY} > /dev/null 2>&1
	else
		echo -e "${BOLD} >> Cloning ${MAGENTA}${TARGET_LIBRARY}${WHITE} library from ${BLUE}${BOLD}${ACRNPRJ_REPO}/${TARGET_LIBRARY}.git${RESET} at ${RED}${BOLD}\"${KICADDIR}/${LIBDIR}/${TARGET_LIBRARY}\"${RESET} folder... \c" 
		git clone ${ACRNPRJ_REPO}/${TARGET_LIBRARY}.git ${KICADDIR}/${LIBDIR}/${TARGET_LIBRARY} > /dev/null 2>&1
	fi
	echo "${BOLD}${GREEN}Done.${RESET}"
		
}

add_symlib() {
	add_library $1 $2
	echo -e "${BOLD} >> Adding ${MAGENTA}${1}${WHITE} symbol library to KiCAD library table... \c"
	sed -i "2 i (lib (name \"${1}\")(type \"KiCad\")(uri \"\$\{KIPRJMOD\}/${LIBDIR}/${1}/${1}.kicad_sym\")(options \"\")(descr \"Acheron Project symbol library\")) " ${KICADDIR}/sym-lib-table > /dev/null
	echo "${BOLD}${GREEN}Done.${RESET}"
}

add_footprintlib(){
	add_library $1.pretty $2
	echo -e "${BOLD} >> Adding ${MAGENTA}${1}${WHITE} footprint library to KiCAD library table... \c"
	sed -i "2 i (lib (name \"${1}\")(type \"KiCad\")(uri \"\$\{KIPRJMOD\}/${LIBDIR}/${1}.pretty\")(options \"\")(descr \"Acheron Project footprint library\")) " ${KICADDIR}/fp-lib-table > /dev/null
	echo "${BOLD}${GREEN}Done.${RESET}"
}
#}}}1

# clean() function: get the tool back to original state --------- {{{1
# This function deletes all *.git files and folders, also the ${KICADDIR}.
clean(){
	echo -e "${YELLOW}${BOLD} >> CLEANING${WHITE} produced files... \c"
	${TRASH_COMMAND} .git .gitmodules ${KICADDIR} > /dev/null 2>&1
	echo -e "${BOLD}${GREEN}Done.${RESET}"
}
#}}}1

# MAIN FUNCTION ----------------------------- {{{1
main(){
	if [ -z "$1" ] ; then
		echo "${RED}${BOLD} >> ERROR${WHITE} on function main:${RESET} no argument passed."
		exit 0
	fi
	local TARGET_TEMPLATE="$1" 
	local NOGRAPHICS="$2"
	local NOLOGOS="$3"
	local NO3D="$4"
	local LOCAL_CLEANCREATE="$5"
	local NO_GIT_REPO="$6"
	local NO_GIT_SUBMODULE="$7"
	local PURGECLEAN="$8"
	local SWITCHTYPE="$9"
	if [ "$PURGECLEAN" = 'true' ] ; then clean ; fi
	if [ "$NO_GIT_REPO" = 'false' ] ; then
		echo -e "${BOLD}${GREEN}>>${WHITE} Initializing git repo... \c"
		git init > /dev/null 2>&1
		git branch -M main 
		echo "${BOLD}${GREEN}Done.${RESET}" 
	fi
	kicad_setup $TARGET_TEMPLATE
	add_symlib acheron_Symbols $NO_GIT_SUBMODULE
	add_footprintlib acheron_Components $NO_GIT_SUBMODULE
	add_footprintlib acheron_Connectors $NO_GIT_SUBMODULE
	add_footprintlib acheron_Hardware $NO_GIT_SUBMODULE
	add_footprintlib acheron_${SWITCHTYPE} $NO_GIT_SUBMODULE
	if [ "$NOGRAPHICS" = 'false' ] ; then
		add_footprintlib acheron_Graphics $NO_GIT_SUBMODULE
	fi
	if [ "$NOLOGOS" = 'false' ] ; then
		add_footprintlib acheron_Logo $NO_GIT_SUBMODULE
	fi
	if [ "$NO3D" = 'false' ] ; then
		add_library acheron_3D $NO_GIT_SUBMODULE 
	fi
	#echo ${LOCAL_CLEANCREATE}
	if [  "$LOCAL_CLEANCREATE" = 'true' ] ; then
		echo -e "${BOLD}${YELLOW}>>${WHITE} Cleaning up... ${RESET}\c"
		${TRASH_COMMAND} keyboard_create.sh *_template
		echo "${BOLD}${GREEN} Done.${RESET}"
	fi
}
#}}}1

main $TEMPLATE $NOGRAPHICS $NOLOGOS $NO3D $CLEANCREATE $NO_GIT_REPO $NO_GIT_SUBMODULES $PURGECLEAN $SWITCHTYPE
