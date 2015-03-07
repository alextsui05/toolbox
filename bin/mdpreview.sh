#!/bin/bash
#
# Preview some markdown in Firefox.
#
# Uses md2man:
# https://sunaku.github.io/md2man
#
OPEN_BROWSER=firefox
if [[ "${OSTYPE}" == "darwin"* ]]; then
    OPEN_BROWSER=open
fi
if [[ $# < 1 ]]; then
    echo "Usage: $(basename $0) file.md"
    exit 0
fi
md2man-html $1 > /tmp/tmp.html && ${OPEN_BROWSER} /tmp/tmp.html
