#!/usr/bin/env bash
echo "Installing mediawiki-extension-archive-leaf fonts for offline use of Palm wiki"
# NOTE THIS SHOULD BE RUN FROM THE ARCHIVELEAF EXTENSION DIRECTORY AS "maintenance/offline-fonts.sh"

# TODO INTEGRATE NOTES FROM EVERNOTE IN HERE
#BASEMEDIAWIKI=/usr/share/mediawiki
#ARCHIVELEAFDIR=${BASEMEDIAWIKI}/extensions/ArchiveLeaf
BASEMEDIAWIKI="../.."
ARCHIVELEAFDIR="."
FONTSDIR=${ARCHIVELEAFDIR}/fonts
FONTSURL=/mediawiki/extensions/ArchiveLeaf/fonts
FONTSSCSS=${ARCHIVELEAFDIR}/scss/fonts-custom.scss
set -e # End script on first error
mkdir -p ${FONTSDIR}
touch ${FONTSSCSS} # Make sure it exists
while read -ra FONTLINE
do
    FONTNAME=${FONTLINE[0]}
    FONTURL=${FONTLINE[1]}
    FONTVER=${FONTLINE[2]}
    for FONTEXT in .woff .woff2 .ttf
    do
       [ -f ${FONTSDIR}/${FONTNAME}${FONTEXT} ] || curl -L -o${FONTSDIR}/${FONTNAME}${FONTEXT} ${FONTURL}${FONTEXT}${FONTVER} &
    done
    wait
    cp ${FONTSSCSS} /tmp/m1
    grep -v ${FONTNAME} /tmp/m1 > ${FONTSSCSS} || echo "adding ${FONTNAME}" # So doesnt end script if fontname not there
    echo "\$${FONTNAME}: \"${FONTSURL}/${FONTNAME}\";" >>${FONTSSCSS}
done <<EOT
vimala https://bali.panlex.org/transcriber/fonts/Vimala ?v22
pustaka https://bali.panlex.org/transcriber/fonts/Pustaka ?v22
noto_balinese https://archive.org/cors/NotoFonts/NotoSerifBalinese-Regular
noto_grantha https://archive.org/cors/NotoFonts/NotoSansGrantha-Regular
noto_khmer https://archive.org/cors/NotoFonts/NotoSansKhmer-Regular
noto_malayalam https://archive.org/cors/NotoFonts/NotoSansMalayalam-Regular
noto_myanmar https://archive.org/cors/NotoFonts/NotoSansMyanmar-Regular
noto_sinhala https://archive.org/cors/NotoFonts/NotoSansSinhala-Regular
noto_tamil https://archive.org/cors/NotoFonts/NotoSansTamil-Regular
noto_telugu https://archive.org/cors/NotoFonts/NotoSansTelugu-Regular
EOT
echo Ending font install