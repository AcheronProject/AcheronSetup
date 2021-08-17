FULLCOMMAND = $(word $2,$(subst :, ,$1))
ARG1 = $(call FULLCOMMAND, $*, 1)
LIBDIR = libraries
KICADDIR = kicad_files
ACRNPRJ_REPO = git@github.com:AcheronProject
TRASH_COMMAND = gio trash
ifndef CLEANCREATE
	CLEANCREATE = FALSE
endif
ifndef SWITCHTYPE
	SWITCHTYPE = MX
endif
ifndef NOGRAPHICS
	NOGRAPHICS = TRUE
endif
ifndef NOLOGOS
	NOLOGOS = TRUE
endif
ifndef PRJNAME
	PRJNAME = project
endif
ifndef 3DLIB
	3DLIB = TRUE
endif

# ANSI terminal colors (see 'man tput') and
# https://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
# Don't use color if there isn't a $TERM environment variable:
ifneq ($(strip $(TERM)),)
	BOLD=$(shell tput bold)
	RED=$(shell tput setaf 1)
	GREEN=$(shell tput setaf 2)
	BLUE=$(shell tput setaf 4)
	MAGENTA=$(shell tput setaf 5)
	WHITE=$(shell tput setaf 7)
	UL=$(shell tput sgr 0 1)
	RESET=$(shell tput sgr0 )
endif

# gitsetup initializes the git local repository and adds the acheron submodules in the libraries folder.
create:
	@echo -e "$(BOLD) >> Initializing git repo... \c" ; \
	git init > /dev/null 2>&1; \
	git branch -M main ; \
	echo "$(BOLD)$(GREEN)Done.$(RESET)" ; \
	$(MAKE) -s kicadsetup ; \
	$(MAKE) -s check:libdir ; \
	$(MAKE) -s addsymlib:acheron_Symbols ; \
	$(MAKE) -s addfootprintlib:acheron_Components ; \
	$(MAKE) -s addfootprintlib:acheron_Connectors ; \
	$(MAKE) -s addfootprintlib:acheron_Hardware ; \
	$(MAKE) -s addfootprintlib:acheron_${SWITCHTYPE} ; \
	if [ ${NOGRAPHICS} == FALSE ] ; then \
		$(MAKE) -s addfootprintlib:acheron_Graphics ; \
	fi ; \
	if [ ${NOLOGOS} == FALSE ] ; then \
		$(MAKE) -s addfootprintlib:acheron_Logos ; \
	fi ; \
	if [ ${3DLIB} == TRUE ] ; then \
		$(MAKE) -s addsubmodule:acheron_3D ; \
	fi ; \
	if [ ${CLEANCREATE} == TRUE ] ; then \
		${TRASH_COMMAND} Makefile blankproject ; \
	fi ; \
		
addsymlib%:
	@$(MAKE) -s addsubmodule:${ARG1} ; \
	echo -e "$(BOLD) >> Adding ${ARG1} symbol library to KiCAD library table... \c" ; \
	sed -i "2 i (lib (name \"${ARG1}\")(type \"KiCad\")(uri \"$$\{KIPRJMOD\}/${LIBDIR}/${ARG1}/${ARG1}.kicad_sym\")(options \"\")(descr \"Acheron Project symbol library\")) " ${KICADDIR}/sym-lib-table > /dev/null ; \
	echo "$(BOLD)$(GREEN)Done.$(RESET)"

addfootprintlib%:
	@$(MAKE) -s addsubmodule:${ARG1}.pretty ; \
	echo -e "$(BOLD) >> Adding ${ARG1} footprint library to KiCAD library table... \c" ; \
	sed -i "2 i (lib (name \"${ARG1}\")(type \"KiCad\")(uri \"$$\{KIPRJMOD\}/${LIBDIR}/${ARG1}.pretty\")(options \"\")(descr \"Acheron Project footprint library\")) " ${KICADDIR}/fp-lib-table > /dev/null ; \
	echo "$(BOLD)$(GREEN)Done.$(RESET)"
	
# check:libdir checks if the KICADDIR/LIBDIR exists. If not, creates it with the parent KICADDIR if it doesnt exist.
# check:kicaddir checks if the KICADDIR folder exists. If not, creates it.
# check:switchtyperemote checks if the switch type chosen exists as a remote. It sets up a SWITCHREPO variable that returns "HEAD" in case the repo exists and "" else.
check%:
	if [ ${ARG1}==libdir ] ; then \
		if [ ! -d ${KICADDIR}/${LIBDIR} ] ; then \
			echo -e "$(BOLD) >> LIBDIR check: $(RED)Libraries directory at ${KICADDIR}/${LIBDIR} not found$(WHITE). Creating it...$(RESET) \c" ; \
			mkdir -p ${KICADDIR}/${LIBDIR} ; \
			echo "$(BOLD)$(GREEN)Done.$(RESET)" ; \
		fi \
	fi ; \
	if [ ${ARG1}==kicaddir ] ; then \
		if [ ! -d ${KICADDIR} ] ; then \
			echo -e "$(BOLD) >> KICADDIR check: $(RED)KiCAD directory at ${KICADDIR} not found$(WHITE). Creating it...$(RESET) \c" ; \
			mkdir -p ${KICADDIR}; \
			echo " $(BOLD)$(GREEN)Done.$(RESET)" ; \
		fi \
	fi

addsubmodule%:
	@echo -e "$(BOLD) >> Adding $(MAGENTA)${ARG1}$(WHITE) submodule from $(BLUE)$(BOLD)${ACRNPRJ_REPO}/${ARG1}.git$(RESET) at $(RED)$(BOLD)\"$(KICADDIR)/${LIBDIR}/${ARG1}\"$(RESET) folder... \c" ; \
	git submodule add ${ACRNPRJ_REPO}/${ARG1}.git ${KICADDIR}/${LIBDIR}/${ARG1} > /dev/null 2>&1; \
	echo "$(BOLD)$(GREEN)Done.$(RESET)"

	

# clean:git clears all git references, that is, all files and folders in .git*
# clean:kicaddir removes the folder ${KICADDIR}
# clean:all removes both
clean%:
	@if [ ${ARG1}==git ] ; then \
		if [ -d .git ] ; then \
			${TRASH_COMMAND} .git* ; \
			echo "$(BOLD) >> Deleting .git folder$(RESET)" ; \
		fi ; \
	fi ; \
	if [ ${ARG1}==kicaddir ] ; then \
		if [ -d ${KICADDIR} ] ; then \
			${TRASH_COMMAND} ${KICADDIR} ; \
			echo "$(BOLD) >> Deleting ${KICADDIR} folder$(RESET)" ; \
		fi ; \
	fi ; \
	if [ ${ARG1}==all ] ; then \
		echo -e "$(BOLD) >> Deleting ${KICADDIR} folder and .git* files...$(RESET)\c" ; \
		if [ -d .git ] ; then \
			${TRASH_COMMAND} .git* ; \
		fi ; \
		if [ -d ${KICADDIR} ] ; then \
			${TRASH_COMMAND} ${KICADDIR} ; \
		fi ; \
		echo " $(BOLD)$(GREEN)Done.$(RESET)" ; \
	fi ; \

kicadsetup:
	@$(MAKE) -s check:kicaddir ; \
	cat blankproject/blank.kicad_pro > ${KICADDIR}/${PRJNAME}.kicad_pro ; \
	cat blankproject/blank.kicad_pcb > ${KICADDIR}/${PRJNAME}.kicad_pcb ; \
	cat blankproject/blank.kicad_prl > ${KICADDIR}/${PRJNAME}.kicad_prl ; \
	cat blankproject/blank.kicad_sch > ${KICADDIR}/${PRJNAME}.kicad_sch ; \
	cp blankproject/sym-lib-table ${KICADDIR} ; \
	cp blankproject/fp-lib-table ${KICADDIR}
