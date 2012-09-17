#!/bin/bash
DIR="$( cd $(dirname "${0}") && pwd )"
REPO_DIR="repos"
CONFIG='config'
CUR_REPO=''

#############################################
#                 Functions
#############################################
_config_error() {
	echo "Error: invalid options ${@}" >&2
	exit 1
}

_fetchRepo() {
	case ${1} in
		path)
			CUR_REPO="${DIR}/${REPO_DIR}/${2}"
			echo "In repository ${2}"
		;;
		remote)
			cd ${CUR_REPO} && git fetch ${2}
		;;
		**)
		;;
	esac
}

_initRepo() {
	case ${1} in
		path)
			if [ $# -lt 2 ]; then
				_config_error ${@}
			fi
			if [ -e ${2} -a ! -d ${2} ]; then
				echo "Error: ${2} exists and is not a directory, stop execution."
				exit 1
			fi
			CUR_REPO="${DIR}/${REPO_DIR}/${2}"
			if [ ! -d ${CUR_REPO} ] || [ -d ${CUR_REPO} -a ! -d ${CUR_REPO}/.git ]; then # if repository not exists, init it
				git init ${CUR_REPO}
			fi
		;;
		remote)
			if [ $# -lt 3 ]; then
				_config_error ${@}
			fi
			if [ "$(cd ${CUR_REPO} && git remote | grep ${2})" == "" ]; then
				# remote not exist
				echo "Adding $(basename ${CUR_REPO}) remote ${2} as ${3}"
				cd ${CUR_REPO} && git remote add ${2} ${3}
				cd ${CUR_REPO} && git fetch ${2}
				if [ ${2} == "origin" ]; then
					cd ${CUR_REPO} && git checkout origin/master -B master -q
				fi
			elif [ "$(cd ${CUR_REPO} && git remote show -n ${2} | grep ${3})" == "" ]; then
				echo "Setting $(basename ${CUR_REPO}) remote ${2} as ${3}"
				cd ${CUR_REPO} && git remote set-url ${2} ${3}
				cd ${CUR_REPO} && git fetch ${2}
				if [ ${2} == "origin" ]; then
					cd ${CUR_REPO} && git checkout origin/master -B master -q
				fi
			fi
		;;
		**)
			_config_error ${@}
		;;
	esac
}

_exec() {
	echo "In repository ${2}"
	CUR_REPO="${DIR}/${REPO_DIR}/${2}"
	cd ${CUR_REPO} && ${@:3}
}

_each() {
	# print config file, grep line with content, grep line not start with #(that's comment), then while loop it
	cat ${CONFIG} | grep -e '.' | grep -ve '^\s*#' | while read args; do
	   ${1} $args
	done
}

_eachPath() {
	#echo ${@:2}
	# print config file, grep line start with path, then while loop it
	cat ${CONFIG} | grep -e '^\s*path\s' | while read args; do
	   ${1} $args "${@:2}"
	done
}

# route
case ${1} in
    init)
		echo "Initailizing all repositories within [${CONFIG}]"
		_each "_initRepo"
    ;;
    fetch)
		_each "_initRepo"
		_each "_fetchRepo"
    ;;
	git)
		_each "_initRepo"
		_eachPath "_exec" ${@:1}
	;;
	execute)
		_each "_initRepo"
		_eachPath "_exec" ${@:2}
	;;
    **)
        echo "Usage: ${0} (init|fetch|git command|execute external command)" >&2
        exit 1
    ;;
esac
