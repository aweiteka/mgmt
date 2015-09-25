#!/bin/bash
# check for any yaml files that aren't properly formatted

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(dirname "${BASH_SOURCE}")/..
cd "${ROOT}"

find_files() {
	find . -not \( \
		\( \
			-wholename './old' \
			-o -wholename './tmp' \
		\) -prune \
	\) -name '*.yaml'
}

bad_files=$(
	for i in $(find_files); do
		if ! diff -q <( ruby -e "require 'yaml'; puts YAML.load_file('$i').to_yaml" 2>/dev/null ) <( cat "$i" ) &>/dev/null; then
			echo "$i"
		fi
	done
)

if [[ -n "${bad_files}" ]]; then
	echo 'FAIL'
	echo 'The following files are not properly formatted:'
	echo "${bad_files}"
	exit 1
fi