###############################################################################
# NiNA - Makefile                                                             #
###############################################################################
#    Copyright 2018 ß 2019 Dirk Heisswolf                                     #
#    This file is part of the NiNA project.                                   #
#                                                                             #
#    NiNA is free software: you can redistribute it and/or modify             #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    NiNA is distributed in the hope that it will be useful,                  #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with NiNA.  If not, see <http://www.gnu.org/licenses/>.            #
###############################################################################
# Description:                                                                #
#    This is the project makefile to run all verifcation and documentation    #
#    tasks. A description of all supported rules is given in the help text.   #
#                                                                             #
###############################################################################
# Version History:                                                            #
#   Maz 15, 2018                                                              #
#      - Initial release                                                      #
###############################################################################

#Directories
REPO_DIR        := .
#REPO_DIR       := $(CURDIR)
RTL_DIR         := $(REPO_DIR)/rtl/verilog
BENCH_DIR       := $(REPO_DIR)/bench/verilog
YOSYS_DIR       := $(REPO_DIR)/tools/Yosys
YOSYS_SRC_DIR   := $(YOSYS_DIR)/src
YOSYS_WRK_DIR   := $(YOSYS_DIR)/run
SBY_DIR         := $(REPO_DIR)/tools/SymbiYosys
SBY_SRC_DIR     := $(SBY_DIR)/src
SBY_WRK_DIR     := $(SBY_DIR)/run
GTKW_DIR        := $(REPO_DIR)/tools/gtkwave
GTKW_SRC_DIR    := $(GTKW_DIR)/src
GTKW_WRK_DIR    := $(GTKW_DIR)/run
GIT_REMOTES_DIR := $(REPO_DIR)/.git/refs/remotes

#Tools	      
ifndef EDITOR 
EDITOR          := $(shell which emacs || which xemacs || which nano || which vi)
endif	        
VERILATOR       := verilator -sv --lint-only 
IVERILOG        := iverilog -t null
#YOSYS          := yosys -q
YOSYS           := yosys
SBY             := sby -f
PERL            := perl
GTKWAVE         := gtkwave      
VCD2FST         := vcd2fst
GIT             := git

#Git repositories	      
GIT_ORIGIN      := git@github.com:hotwolf/NiNA.git 
GIT_REMOTES     := git@github.com:hotwolf/N1.git \
		   git@github.com:hotwolf/WbXbc.git



.SECONDEXPANSION:
.PHONY:		help \
		git.update git.update.origin (addprefix git.update., $(basename $(notdir $(GIT_REMOTES))))

#############
# Help text #
#############
help:
	$(info This makefile supports the following targets:)
	$(info )
	$(info git update:                      Update from all remote repositories)
	$(info git.update.<remote>:             Update from all specific remote repositories)
	$(info )


#######
# Git #
#######
#Check remotes
$(GIT_REMOTES_DIR)/origin:
			@echo $(GIT) remote add -f origin $(GIT_ORIGIN)

$(addprefix $(GIT_REMOTES_DIR)/,$(basename $(notdir $(GIT_REMOTES)))):
			$(eval remote_name := $(lastword $(subst /, ,$@)))
			$(eval remote_url  := $(filter %/$(remote_name).git, $(GIT_REMOTES)))
			@echo $(GIT) remote add -f $(remote_name) $(remote_url)

#Update remotes
git.update.origin:	$(GIT_REMOTES_DIR)/origin
			@echo git pull origin master

$(addprefix git.update., $(basename $(notdir $(GIT_REMOTES)))): $$(addprefix $$(GIT_REMOTES_DIR)/,$$(lastword $$(subst ., ,$$@)))
			$(eval remote_name := $(lastword $(subst ., ,$@)))
			@echo $(GIT) pull -s subtree --squash --no-tags $(remote_name) master

git.update:		git.update.origin $(addprefix git.update., $(basename $(notdir $(GIT_REMOTES))))
