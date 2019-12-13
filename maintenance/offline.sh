#!/usr/bin/env bash
echo "Installing mediawiki-extension-archive-leaf fonts for offline use of Palm wiki"
set -e
BASEMEDIAWIKI="../.."
ARCHIVELEAFDIR="."
#BASEMEDIAWIKI=/usr/share/mediawiki
#ARCHIVELEAFDIR=${BASEMEDIAWIKI}/extensions/ArchiveLeaf
#TODO offline-fonts could just use the env variables
export BASEMEDIAWIKI ARCHIVELEAFDIR

# This is following the steps in README.md
pushd ${ARCHIVELEAFDIR} >>/dev/null
maintenance/transcriber-install # yarn dependencies
maintenance/offline-fonts.sh # Install offline fonts
maintenance/transcriber-build # transcriber javascript and css
maintenance/templates-import # import the required Template:Entry and Template:EntryImage pages into MediaWiki.
# The Metrolook skin is included here, because MediaWiki's skin distribution system makes it impossible (maybe intentionally)
# to script fetching skins.
# You can get the skin at https://www.mediawiki.org/wiki/Skin:Metrolook
# and I've opened a discussion at https://www.mediawiki.org/wiki/Extension_talk:ExtensionDistributor
# but searching some past history suggests this is one of those wicked discussions they'll never solve
# because they've scoped the problem just too hard!
if [ -d ${BASEMEDIAWIKI}/skins/Metrolook ]
then
  echo "Metrolook skin appears to be installed"
else
  tar -xzf Metrolook.tar.gz -C ${BASEMEDIAWIKI}/skins
fi
while read LOCALSETTING
do
    grep "${LOCALSETTING}" ${BASEMEDIAWIKI}/LocalSettings.php >>/dev/null || echo "${LOCALSETTING}" >>${BASEMEDIAWIKI}/LocalSettings.php
done <<EOT
\$wgAllowExternalImages = true;
\$wgAllowImageTag = true;
\$wgCapitalLinks = false;
\$wgAllowDisplayTitle = true;
\$wgRestrictDisplayTitle = false;
\$wgAllowCopyUploads = true;
\$wgEnableUploads = true;
ini_set('max_execution_time', 0);
# recommended (requires ImageMagick install)
\$wgUseImageMagick = true;
# load ArchiveLeaf extension
wfLoadExtension( 'ArchiveLeaf' );
# use Metrolook (required for mobile)
wfLoadSkin( 'Metrolook' );
\$wgMetrolookDownArrow = false;
\$wgMetrolookUploadButton = false;
\$wgDefaultSkin = 'Metrolook';
\$wgGroupPermissions['user']['archiveleaf'] = true; # Allow users to import pages (by default only "sysops" allowed to improt pages)
\$wgArchiveLeafBaseURL = 'https://archive.org'; # base URL (default shown)
\$wgArchiveLeafApiURL = 'https://api.archivelab.org'; # API URL (default shown)
\$wgArchiveLeafTemplateName = 'Entry'; # primary template (default shown)
\$wgArchiveLeafTemplateImageName = 'EntryImage'; # per-image template (default shown)
#\$wgArchiveLeafImportScript = '/home/davidk/script/update_ia_item.py'; # script to run after importing IA item as a new wiki page. item identifier is passed as an argument.
EOT
popd >>/dev/null
