#! /bin/bash

GIT_BRANCH="$1"
OS_NAME="$2"

echo ""
echo "########################################################################"
echo ""
echo "Checking commit hash"
echo ""
#sudo apt-get -y update
#sudo apt-get install -y wget git || exit 1
rm -f /tmp/commit-${GIT_BRANCH}-${OS_NAME}.hash
#wget https://github.com/jcelaya/hdrmerge/releases/download/nightly/commit-${GIT_BRANCH}-${OS_NAME}.hash -O /tmp/commit-${GIT_BRANCH}-${OS_NAME}.hash
curl -L https://github.com/jcelaya/hdrmerge/releases/download/nightly/commit-${GIT_BRANCH}-${OS_NAME}.hash -o /tmp/commit-${GIT_BRANCH}-${OS_NAME}.hash

rm -f travis.cancel
if  [ -e /tmp/commit-${GIT_BRANCH}-${OS_NAME}.hash ]; then
	git rev-parse --verify HEAD > /tmp/commit-${GIT_BRANCH}-${OS_NAME}-new.hash
	echo -n "Old ${GIT_BRANCH} hash: "
	cat /tmp/commit-${GIT_BRANCH}-${OS_NAME}.hash
	echo -n "New ${GIT_BRANCH} hash: "
	cat /tmp/commit-${GIT_BRANCH}-${OS_NAME}-new.hash
	diff /tmp/commit-${GIT_BRANCH}-${OS_NAME}-new.hash /tmp/commit-${GIT_BRANCH}-${OS_NAME}.hash
	if [ $? -eq 0 ]; then 
		touch travis.cancel
		echo "No new commit to be processed"
		#exit 0
	fi
fi
cp /tmp/commit-${GIT_BRANCH}-${OS_NAME}-new.hash ./commit-${GIT_BRANCH}-${OS_NAME}.hash

