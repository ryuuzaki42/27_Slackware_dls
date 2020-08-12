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
# Descrição: Script to download the last version VirtualBox
#
# Última atualização: 12/08/2020
#
case "$(uname -m)" in
    i?86) archDL="x86" ;;
    x86_64) archDL="amd64" ;;
    *) archDL=$(uname -m) ;;
esac

progName="virtualbox"

linkGetVersion="https://www.virtualbox.org/wiki/Downloads"
wget "$linkGetVersion" -O "${progName}_latest"

version=$(grep "VirtualBox.* platform packages" ${progName}_latest | cut -d '>' -f4 | cut -d ' ' -f2)
rm "${progName}_latest"

installedVersion=$(find VirtualBox* | cut -d '-' -f2)
echo -e "\n   Latest version: $version\nVersion installed: $installedVersion\n"
if [ "$installedVersion" != '' ]; then
    if [ "$version" == "$installedVersion" ]; then
        echo -e "Version installed ($installedVersion) is equal to latest version ($version)"
        echo -n "Want continue? (y)es - (n)o (hit enter to no): "
        read -r continue

        if [ "$continue" != 'y' ]; then
            echo -e "\nJust exiting\n"
            exit 0
        fi
    fi
fi

mirrorDl="http://download.virtualbox.org/virtualbox/$version"
wget "$mirrorDl/MD5SUMS" -O MD5SUMS

runFileMd5=$(grep "VirtualBox-$version.*-Linux_$archDL.run" < MD5SUMS)
extpackFileMd5=$(grep "Oracle_VM_VirtualBox_Extension_Pack-$version.*vbox-extpack" < MD5SUMS | head -n 1)

runFile=$(echo "$runFileMd5" | cut -d '*' -f2)
extpackFile=$(echo "$extpackFileMd5" | cut -d '*' -f2)
rm MD5SUMS

mkdir "${progName}-${version}-new"
cd "$progName-$version-new" || exit

wget -c "$mirrorDl/$runFile"
wget -c "$mirrorDl/$extpackFile"
#wget -c "$mirrorDl/UserManual.pdf"

echo  -e "\\nCheck md5sum files download\\n"
tmpFile=$(mktemp)
echo "$runFileMd5" > "$tmpFile"
echo "$extpackFileMd5" >> "$tmpFile"

md5sum -c "$tmpFile"
rm "$tmpFile"