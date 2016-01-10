#!/bin/bash
# Written by Ian Y. Choi (ianyrchoi@gmail.com)
# Last update: Jan 10, 2016
#
# License: http://www.apache.org/licenses/LICENSE-2.0

CURR_DIR=$PWD
TOX_OUTPUT=$CURR_DIR/output-tox.log
source $CURR_DIR/localrc

# 0. echo: shell script information
echo " This program retrieves po files from Zanata, "
echo "  applies to openstack-manuals for install-guide, "
echo "  and uploads html files to a specific git repo. "
echo " == Started =="
# 1. update po files (zanata_exec.sh -> ko-KR)
./expect_zanata.sh

# 2. pull && clean if needed
./pull_manuals.sh $BRANCH

# 3. copy po files to openstack-manuals
mkdir -p $OPENSTACK_MANUALS_DIR/$COMMON_RST_BASE_DIR/$LOCALE_SUBDIR/$LOCALE/
mkdir -p $OPENSTACK_MANUALS_DIR/$INSTALL_GUIDE_BASE_DIR/$LOCALE_SUBDIR/$LOCALE/
cp ./$COMMON_RST_BASE_DIR/$LOCALE_SUBDIR/$PO_FILENAME $OPENSTACK_MANUALS_DIR/$COMMON_RST_BASE_DIR/$LOCALE_SUBDIR/$LOCALE/$COMMON_RST_PO_FILENAME
cp ./$INSTALL_GUIDE_BASE_DIR/$LOCALE_SUBDIR/$PO_FILENAME $OPENSTACK_MANUALS_DIR/$INSTALL_GUIDE_BASE_DIR/$LOCALE_SUBDIR/$LOCALE/$INSTALL_GUIDE_PO_FILENAME

# 3. Move the target directory and change to the stable branch
cd $OPENSTACK_MANUALS_DIR
git checkout -b $BRANCH remotes/origin/$BRANCH

# 4. Override the conf
cp $CURR_DIR/$LANG_CONF_FILENAME-$LOCALE ./$LANG_CONF_FILENAME

# 5. Exec tox
rm -rf $PUBLISH_DOCS_SUBDIR/*
tox -e publishlang > $TOX_OUTPUT 2>&1

# 6. Copy the result to gh-pages git local repo
cd $PUBLISH_DOCS_SUBDIR
cp -r liberty/$LOCALE/* $CURR_DIR/$GH_PAGES_REPO_TARGET_DIR
cd $CURR_DIR/$GH_PAGES_REPO_TARGET_DIR

# 7. Replacement: Github does not support directories named with _.
grep -rl '_static' ./ | xargs sed -i 's/_static/..\/static/g'
grep -rl '_images' ./ | xargs sed -i 's/_images/..\/images/g'

# 8. commit and push
#git commit -a -m "[ko_KR] refreshed using the latest Zanata data"
#git push origin gh-pages:gh-pages

# 9. echo results
echo " == Finished! =="
echo " Local HTML files (openstack-manuals, relative): "
echo "  - $OPENSTACK_MANUALS_DIR/$PUBLISH_DOCS_SUBDIR"
echo " Tox output log files: $TOX_OUTPUT"
echo " ==============="
