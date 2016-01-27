#!/bin/bash

## ensure running as root
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@" 
  echo ""
fi

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
	echo → Adding repository $repo 
	(sudo add-apt-repository -y ppa:$repo 2>&1 >/dev/null && echo ✔ Added repository $repo) || echo ✗ The repository $repo can not be added
	echo ""
done

## Installing aptitude
echo → Installing aptitude
((apt-get -y install aptitude 2>&1 >/dev/null) && echo ✔ Installed aptitude) || echo ✗ Aptitude installation failed
echo ""

## Updating 
echo → Updating system
((aptitude update 2>&1 >/dev/null) && echo ✔ Updated system) || echo ✗ Update failed
echo ""

## Installing programs
for program in "${programs[@]}" 
do 
	echo → Installing $program
	((aptitude -y install $program 2>&1 >/dev/null) && echo ✔ Installed $program) || echo ✗ The program $program installation failed
	echo ""
done

## Upgrading
echo → Upgrading programs
((aptitude -y upgrade 2>&1 >/dev/null) && echo ✔ Upgraded programs ) || echo ✗ Upgrade failed
echo ""

## Installing zsh
echo → Installing zsh
((aptitude -y install zsh 2>&1 >/dev/null) && (aptitude -y install git-core 2>&1 >/dev/null) && ((wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh) 2>&1 >/dev/null) && (chsh -s `which zsh`) && echo ✔ Installed zsh) || echo ✗ Zsh installation failed
echo ""

## Disabling comercial search
echo → Disabling comercial search
(gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope','more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']" && echo ✔ Disabled comercial search) || echo ✗ Comercial search can not be disabled
echo ""

exit
