#!/bin/bash
# check for any yaml files that aren't properly formatted

set -o errexit
set -o nounset
set -o pipefail

if env | grep -q '^TRAVIS=true$'; then
	echo "Travis gives wonky results here, skipping test!"
	exit 0
fi

ROOT=$(dirname "${BASH_SOURCE}")/..

RUBY=`which ruby`
if [ -z $RUBY ]; then
	echo "The 'ruby' utility can't be found."
	exit 1
fi

$RUBY -e "require 'yaml'" 2>/dev/null || (
	echo "The ruby 'yaml' library can't be found."
	exit 1
)

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
