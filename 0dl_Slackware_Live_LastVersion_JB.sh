#!/bin/bash
# Autor= João Batista Ribeiro
# Bugs, Agradecimentos, Críticas "construtivas"
# Mande me um e-mail. Ficarei Grato!
# e-mail: joao42lbatista@gmail.com
#
# Este programa é um software livre; você pode redistribui-lo e/ou
# modifica-lo dentro dos termos da Licença Pública Geral GNU como
# publicada pela Fundação do Software Livre (FSF); na versão 2 da
# Licença, ou (na sua opinião) qualquer versão.
#
# Este programa é distribuído na esperança que possa ser útil,
# mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO a
# qualquer MERCADO ou APLICAÇÃO EM PARTICULAR.
#
# Veja a Licença Pública Geral GNU para mais detalhes.
# Você deve ter recebido uma cópia da Licença Pública Geral GNU
# junto com este programa, se não, escreva para a Fundação do Software
#
# Livre(FSF) Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Descrição: Script to download the last version of Slackware Live, made by AlienBob
#
# Última atualização: 12/08/2020
#
echo "Script to download the last version of Slackware Live, made by AlienBob"

#repoLink="http://bear.alienbase.nl/mirrors/slackware-live"
repoLink="https://slackware.nl/slackware-live/"
wget "$repoLink" -O "latestVersion"

versionOnRepo=$(grep "href=\"[0-9]\.[0-9]\.[0-9]" < latestVersion | cut -d 'h' -f2 | cut -d '"' -f2 | cut -d '/' -f1 |  tail -n 1)

versionLocal=$(find . -type d -maxdepth 1 | cut -d '/' -f2 | grep "[0-9]\.[0-9]\.[0-9]" | sort -r | head -n 1)
echo -e "\n   Version Downloaded: $versionLocal\nVersion Online (repo): $versionOnRepo\n"

if [ "$versionLocal" == "$versionOnRepo" ]; then
    echo -e "# No new version found #\n"

    continue=$2
    if [ "$continue" == '' ]; then
        echo "Want continue and maybe download more one ISO?"
        echo -n "(y)es - (n)o (hit enter to no): "
        read -r continue
    fi

    if [ "$continue" != 'y' ]; then
        echo -e "\nJust exiting\n"
        exit 0
    fi
fi

mkdir "Slackware-Live-$versionOnRepo"
cd "Slackware-Live-$versionOnRepo" || exit

wget "$repoLink/$versionOnRepo" -O "latestVersion"

infoISO=$(grep ".iso\"" < latestVersion | sed 's/<//g' | sed 's/>//g')
rm latestVersion

nameISO=$(echo -e "$infoISO" | cut -d '"' -f12)
dateISO=$(echo -e "$infoISO" | cut -d '"' -f15 | cut -d ' ' -f1)
sizeISO=$(echo -e "$infoISO" | cut -d '"' -f17 | cut -d '/' -f1)

alinPrint() {
    inputValue=$1
    countSpaces=$2

    echo -en " # $inputValue"
    spacesUsed=${#inputValue}
    while [ "$spacesUsed" -lt "$countSpaces" ]; do
        echo -n " "
        ((spacesUsed++))
    done
}

printTrace() {
    echo -n " #----------------------------------"
    echo "---------------------------------------#"
}

count1="40"
count2="15"
count3='7'

printTrace
echo -n " # N"
alinPrint "Name" "$count1"
alinPrint "Last modified" "$count2"
alinPrint "Size" "$count3"
echo "#"

countLine=$(echo -e "$nameISO" | wc -l)
((countLine++))
countTmp='1'

while [ "$countTmp" -lt "$countLine" ]; do
    printTrace

    echo -n " # $countTmp"
    tmpInfo=$(echo "$nameISO" | sed -n "${countTmp}p")
    alinPrint "$tmpInfo" "$count1"

    tmpInfo=$(echo "$dateISO" | sed -n "${countTmp}p")
    alinPrint "$tmpInfo" "$count2"

    tmpInfo=$(echo "$sizeISO" | sed -n "${countTmp}p")
    alinPrint "$tmpInfo" "$count3"
    echo "#"

    ((countTmp++))
done

printTrace

echo -e "\nWant download with one of them?"
echo -n "Insert the matching number separated by one space: "
read -r downloadIsoNumbers

countTmp='1'
linkDlFiles=${repoLink}/$versionOnRepo
while [ "$countTmp" -lt "$countLine" ]; do
    tmpInfo=$(echo "$nameISO" | sed -n "${countTmp}p")
    if echo "$downloadIsoNumbers" | grep -q "$countTmp"; then
        echo "Download: $countTmp -  $tmpInfo"
        echo -e "\nwget \"$repoLink/$tmpInfo(|.md5|.asc)\"\n"

        wget -c "$linkDlFiles/$tmpInfo"
        wget -c "$linkDlFiles/$tmpInfo.md5"
        wget -c "$linkDlFiles/$tmpInfo.asc"
    fi

    ((countTmp++))
done

echo "Download \"iso2usb.sh\" (to create usbboot) and the \"README\" (slackware-live changelog)?"
echo -n "(y)es - (n)o (hit enter to yes): "
read -r downloadOrNot

if [ "$downloadOrNot" != 'n' ];then
    repoLinkConfig="http://www.slackware.com/~alien/liveslak/"

    wget -c "$repoLink/README"
    wget -c "${repoLinkConfig}iso2usb.sh"
fi
cd .. || exit

if [ "$versionLocal" != '' ] && [ "$versionLocal" != "$versionOnRepo" ]; then
    echo "Delete the old version ($versionLocal)?"
    echo -n "(y)es - (n)o (hit enter to yes): "
    read -r deleteOldVersion

    if [ "$deleteOldVersion" == 'y' ]; then
        rm -r "$versionLocal"
    fi
fi

rm latestVersion
echo -e "\nEnd of the script\n"
