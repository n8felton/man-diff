#!/bin/bash
set -euo pipefail

TEMPDIR="/private/tmp/man-diff"

if [[ "$#" -lt "1" ]]; then
	echo useage: $0 output_dir
fi

OUTPUTDIR=$1
if [ -d ${OUTPUTDIR} ]; then
	rm -rf ${OUTPUTDIR}
fi

rm -rf "${TEMPDIR}"
mkdir -p "${TEMPDIR}"
rsync -av --exclude='man3/' --include='man*/' --include='man*/**' --exclude='*' /usr/share/man/ ${TEMPDIR}/man
rsync -av --exclude='man3/' --include='man*/' --include='man*/**' --exclude='*' /usr/X11/lib/X11/man/ ${TEMPDIR}/man
rsync -av --exclude='man3/' --include='man*/' --include='man*/**' --exclude='*' /usr/X11/man/ ${TEMPDIR}/man

for PAGE_PATH in ${TEMPDIR}/man/**/*;
do
	PAGE_NAME=${PAGE_PATH##*/}            #
	PAGE_NAME=${PAGE_NAME%%.gz}           # Remove any .gz extensions
	PAGE_NAME=${PAGE_NAME%%.*}            # Remove any .1-n extensions
	PAGE_SECTION_PATH=${PAGE_PATH%/*}     # src/root/usr/share/man/man1
	PAGE_SECTION=${PAGE_SECTION_PATH##*/} # man1
	OUTPUT_PATH=${OUTPUTDIR}/man/${PAGE_SECTION}
	mkdir -p "$OUTPUT_PATH"
	echo "${PAGE_PATH}"
	export MANWIDTH=80
	/usr/bin/man -c "$PAGE_PATH" \
		| /usr/bin/col -bx \
		| sed '$d' \
		> "$OUTPUT_PATH/$PAGE_NAME"
done

ditto /System/Library/CoreServices/SystemVersion.plist "${OUTPUTDIR}/SystemVersion.plist"

