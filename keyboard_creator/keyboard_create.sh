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
function usage() {
	echo "${BOLD}ACHERON PROJECT KEYBOARD CREATOR TOOL ${RESET}
${BOLD}Created by:${RESET} Álvaro "Gondolindrim" Volpato
${BOLD}Link:${RESET} https://acheronproject.com/acheron_setup/acheron_setup/
${BOLD}Version:${RESET} 1.0 (november 4, 2021)
${BOLD}Description: ${RESET}The Acheron Keyboard Creator tool is a bash-script tool aimed at automating the process of creating a KiCAD PCB project for a keyboard PCB. The produced files are ready-to-use and can be edited and modified using the latest KiCAD nightly (november 4, 2021 or newer) and include configuration settings such as copper clearance and tolerance, soldermask clearance and minimum width aimed at being compatible across multiple factories.
${BOLD}Usage: $0 [options] [arguments] (Note: ${GREEN}green${WHITE} values signal default values. Options and arguments are case-sensitive.)
${GREEN}>>${WHITE} Options:${RESET}
	${BOLD}[-h,  --help]${RESET}		Displays this message.
	${BOLD}[-c,  --cleancreate]${RESET}	Creates cleanly, removing all base files including this script, leaving only the final files. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-ng, --nographics]${RESET}	Do not include graphics library submodule. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-nl, --nologos]${RESET}	Do not include logos library submodule. ${BOLD}${GREEN}(F)${RESET}
	${BOLD}[-n3, --no3d]${RESET}		Do not include 3D models library submodule. ${BOLD}${GREEN}(F)${RESET}
${GREEN}>>${BOLD}${WHITE} Arguments:${RESET}
	${BOLD}[-t,  --template]${RESET}	Choose what template to use. ${BOLD}Options are:
						${GREEN}- BLANK${WHITE} for a blank PCB with pre-configured settings
						- J48 for the 48-pin joker template
						- J64 for the 64-pin joker template
	${BOLD}[-p,  --projectname]${RESET}	Do not include 3D models library submodule. ${BOLD}${GREEN}('project')${RESET}
	${BOLD}[-kd, --kicaddir]${RESET}	Chooses the project parent folder name ${BOLD}${GREEN}('kicad_files')${RESET}
	${BOLD}[-ld, --libdir]${RESET}		Chooses the folder inside KICADDIR where libraries and submodules are added. ${BOLD}${GREEN}('libraries')${RESET}
	${BOLD}[-s,  --switchtype]${RESET}	Select what switch type library submodule to be added. ${BOLD} Options are:
						${GREEN}-> 'MX'${WHITE} for simple MX support (https://github.com/AcheronProject/acheron_MX.pretty)
						- 'MX_soldermask' for MX support with covered front switches (https://github.com/AcheronProject/acheron_MX_soldermask.pretty)
						- 'MXA' for MX and Alps suport (https://github.com/AcheronProject/acheron_MXA.pretty)
						- 'MXH' for MX hostwap (https://github.com/AcheronProject/acheron_MXH.pretty)
"
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
CLEANCREATE=false
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
		-c | --cleancreate)
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
	# HANDLING OPTIONS -----------------------
		# TEMPLATE ARGUMENT --------------
		-t | --template)
			if ["$2" ]; then
				TEMPLATE = $2
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
				KICADDIR = $2
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
				LIBDIR = $2
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
		# TEMPLATE ARGUMENT
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

add_submodule() {
	if [ -z "$1" ] ; then
		echo "${RED}${BOLD} >> ERROR${WHITE} on function add)submodule():${RESET} no argument passed."
		return 0
	fi
	local TARGET_SUBMODULE="$1" 
	echo -e "${BOLD} >> Adding ${MAGENTA}${1}${WHITE} submodule from ${BLUE}${BOLD}${ACRNPRJ_REPO}/${ARG1}.git${RESET} at ${RED}${BOLD}\"${KICADDIR}/${LIBDIR}/${1}\"${RESET} folder... \c" 
	git submodule add ${ACRNPRJ_REPO}/${1}.git ${KICADDIR}/${LIBDIR}/$1 > /dev/null 2>&1
	echo "${BOLD}${GREEN}Done.${RESET}"
}

add_symlib() {
	add_submodule $1
	echo -e "${BOLD} >> Adding ${MAGENTA}${1}${WHITE} symbol library to KiCAD library table... \c"
	sed -i "2 i (lib (name \"${1}\")(type \"KiCad\")(uri \"\{KIPRJMOD\}/${LIBDIR}/${1}/${1}.kicad_sym\")(options \"\")(descr \"Acheron Project symbol library\")) " ${KICADDIR}/sym-lib-table > /dev/null
	echo "${BOLD}${GREEN}Done.${RESET}"
}

add_footprintlib(){
	add_submodule $1.pretty
	echo -e "${BOLD} >> Adding ${MAGENTA}${1}${WHITE} footprint library to KiCAD library table... \c"
	sed -i "2 i (lib (name \"${1}\")(type \"KiCad\")(uri \"\{KIPRJMOD\}/${LIBDIR}/${1}.pretty\")(options \"\")(descr \"Acheron Project footprint library\")) " ${KICADDIR}/fp-lib-table > /dev/null
	echo "${BOLD}${GREEN}Done.${RESET}"
}

# MAIN FUNCTION ----------------------------- {{{1
main(){
	if [ -z "$1" ] ; then
		echo "${RED}${BOLD} >> ERROR${WHITE} on function main:${RESET} no argument passed."
		return 0
	fi

	local TARGET_TEMPLATE="$1" 
	local NOGRAPHICS="$2"
	local NOLOGOS="$3"
	local NO3D="$4"
	local LOCAL_CLEANCREATE="$5"
	local SWITCHTYPE="$6"

	echo -e "${BOLD}${GREEN}>>${WHITE} Initializing git repo... \c"
	git init > /dev/null 2>&1
	git branch -M main 
	echo "${BOLD}${GREEN}Done.${RESET}" 
	kicad_setup $TARGET_TEMPLATE
	add_symlib acheron_Symbols
	add_footprintlib acheron_Components
	add_footprintlib acheron_Connectors
	add_footprintlib acheron_Hardware
	add_footprintlib acheron_${SWITCHTYPE}
	if [ ${NOGRAPHICS}=='false' ] ; then
		add_footprintlib acheron_Graphics
	fi
	if [ ${NOLOGOS}=='false' ] ; then
		add_footprintlib acheron_Logos
	fi
	if [ ${NO3D}=='false' ] ; then
		add_submodule acheron_3D 
	fi
	echo ${LOCAL_CLEANCREATE}
	if [[ ${LOCAL_CLEANCREATE}=='true' ]] ; then
		echo -e "${BOLD}${YELLOW}>>${WHITE} Cleaning up... ${RESET}\c"
		${TRASH_COMMAND} keyboard_create.sh *_template
		echo "${BOLD}${GREEN} Done.${RESET}"
	fi
}
#}}}1

echo $CLEANCREATE
main $TEMPLATE $NOGRAPHICS $NOLOGOS $NO3D false $SWITCHTYPE
