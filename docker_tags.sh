#!/usr/local/bin/bash
# Listing local registry images
# Provides as-is

MIRROR_SERVER="${MIRROR_SERVER:-office-server.localdomain:5000}"
PROTO=${PROTO:-http}
JQ_CMD=$(command -v jq)
CURL_CMD=$(command -v curl)
SED_CMD=$(command -v sed)
GREP_CMD=$(command -v grep)
_SEARCH="${*:-}"

function log()
{
  local _input
  _input="${*}"
  echo "LOG: ${_input}"
}

function get_images()
{
    for repository in $(curl "${PROTO}://${MIRROR_SERVER}/v2/_catalog" 2>/dev/null| ${JQ_CMD} .repositories[] | ${SED_CMD} -e 's/"//g')
    do
        _images=0
        echo "### Processing image ${repository}"
        for entry in $(${CURL_CMD} "${PROTO}://${MIRROR_SERVER}/v2/${repository}/tags/list" 2>/dev/null | ${JQ_CMD}  -r '. | .tags[] as $tag | .name+":"+$tag')
        do
            echo "${PROTO}://${MIRROR_SERVER}/${entry}"
            _images=$(( _images + 1))
        done
        echo "### Image ${repository} has ${_images} tags"
        echo ''
    done
}

# MAIN

get_images