#!/bin/bash

apk add --update nodejs npm jq
npm install -g linkinator
URL="$(ni get -p '{.websiteURL}')"
echo "${URL}"
LINKS_ARRAY="$(linkinator "${URL}" --recurse --format JSON)"
BAD_LINKS=$( jq '[.links[] | select(.status == 404) | .url]' <<<"${LINKS_ARRAY}" )
LINKS_COUNT=$( jq 'length' <<<"${BAD_LINKS}" )
echo "Bad links found ${LINKS_COUNT}"

if [ "$LINKS_COUNT" -eq 0 ]
then
  MESSAGE="There are no broken links"
else
  LINKS_STR=$(jq -r 'join(", ")' <<<"${BAD_LINKS}")
  MESSAGE="The broken links are ${LINKS_STR}"
fi

ni output set --key brokenLinks --value "${MESSAGE}"