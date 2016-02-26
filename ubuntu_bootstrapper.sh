#!/bin/bash

## ensure running as root
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@" 
  echo ""
fi

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo "	Ubuntu bootstrapper started"
echo ""

PROGRAMS='./programs.txt'

## This function needs bash 4 
## readarray lines < $PROGRAMS
old_IFS=$IFS
IFS=$'\n' read -d '' -r -a lines < $PROGRAMS
IFS=$old_IFS

## Reading all programs and repositories
repos=()
programs=()
for i in ${!lines[@]}
do
	program=${lines[$i]}
	if [[ $program == *","* ]]
	then	
		old_IFS=$IFS
		IFS=", "
		programWithRepo=($program)
		IFS=$olf_IFS
		programs=("${programs[@]}" "${programWithRepo[0]}")
		repos=("${repos[@]}" "${programWithRepo[1]}")		
	else if [[ $program != "#"* ]]
		then 
			programs=("${programs[@]}" "${program[0]}")
		fi
	fi
done

## Addding repositories
for repo in "${repos[@]}" 
do 
	echo -e "${BLUE}➜${NC} Adding repository $repo"
	(sudo add-apt-repository -y ppa:$repo 2>&1 >/dev/null && echo -e "${GREEN}✔${NC} Added repository $repo") || echo -e "${RED}✗${NC} The repository $repo can not be added"
	echo ""
done

## Installing aptitude
echo -e "${BLUE}➜${NC} Installing aptitude"
((apt-get -y install aptitude 2>&1 >/dev/null) && echo -e "${GREEN}✔${NC} Installed aptitude") || echo -e "${RED}✗${NC} Aptitude installation failed"
echo ""

## Updating 
echo -e "${BLUE}➜${NC} Updating system"
((aptitude update 2>&1 >/dev/null) && echo -e "${GREEN}✔${NC} Updated system") || echo -e "${RED}✗${NC} Update failed"
echo ""

## Installing programs
for program in "${programs[@]}" 
do 
	echo -e "${BLUE}➜${NC} Installing $program"
	((aptitude -y install $program 2>&1 >/dev/null) && echo -e "${GREEN}✔${NC} Installed $program") || echo -e "${RED}✗${NC} The program $program installation failed"
	echo ""
done

## Upgrading
echo -e "${BLUE}➜${NC} Upgrading programs"
((aptitude -y upgrade 2>&1 >/dev/null) && echo -e "${GREEN}✔${NC} Upgraded programs") || echo -e "${RED}✗${NC} Upgrade failed"
echo ""

## Installing zsh
echo -e "${BLUE}➜${NC} Installing zsh"
((aptitude -y install zsh 2>&1 >/dev/null) && (aptitude -y install git-core 2>&1 >/dev/null) && ((wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh) 2>&1 >/dev/null) && (chsh -s `which zsh`) && echo -e "${GREEN}✔${NC} Installed zsh") || echo -e "${RED}✗${NC} Zsh installation failed"
echo ""

## Disabling comercial search
echo -e "${BLUE}➜${NC} Disabling comercial search"
(gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope','more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']" && echo -e "${GREEN}✔${NC} Disabled comercial search") || echo -e "${RED}✗${NC} Comercial search can not be disabled"
echo ""

## Enabling workspaces 2x2
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 2
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 2

exit
