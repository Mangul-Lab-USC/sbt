#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('-r', '--reinstall', action='store_true',default=False, help='Reinstall tools, even if they are already present. [default %(default)s]')
parser.add_argument('-c', '--clean_only', action='store_true',default=False, help='Just remove installed tools. [default %(default)s]')
parser.add_argument('-n', '--native', action='store_true',default=False, help='MiniConda will not be downloaded. You may use environment.yml to set up your python environment. [default %(default)s]')
parser.add_argument('-d', '--db_location', default="NA", type=str,help='Pick a number [default %(default)s]')
EOF



DIR=`dirname $(readlink -f "$0")`

if [[ "$DB_LOCATION" != "NA" ]]
then
echo the answer: "$DB_LOCATION"
else
DB_LOCATION=$DIR
fi
echo "Datbase location ", $DB_LOCATION

cd $DIR

DIR_GENEIMP=$DIR/tools/R/


echo "Prepare GeneImp.sh"
sed -e "s|xxxxx|${DIR_GENEIMP}|" GeneImp.template.sh >GeneImp.sh



ORGANISM='human'

cd "$DB_LOCATION"
mkdir "db_$ORGANISM"
cd "db_$ORGANISM"


cd "$DIR/tools"



if [ $CLEAN_ONLY ]
then
echo '----- Removing previous versions -----------------------------------------------'
rm -fr imrep metaphlan2 MiniConda needle ichorCNA
echo 'Done: Cleaning complete.'
exit 0
fi


if [ $REINSTALL ]
then
echo '----- Removing previous versions -----------------------------------------------'
rm -fr imrep metaphlan2 MiniConda needle ichorCNA
fi


if [ -d 'imrep' ]
then
echo 'Existing installation found. Skipping tools download. To reinstall, please use the -r option.'
else

if [ $REINSTALL ]
then
echo '----- Removing previous versions -----------------------------------------------'
rm -fr imrep metaphlan2 MiniConda needle ichorCNA
fi



# Download ImReP.
echo '----- Downloading ImRep --------------------------------------------------------'
git clone https://github.com/mandricigor/imrep.git
cd imrep
./install.sh
cd ..

#Download needle
echo '----- Downloading Needle --------------------------------------------------'
git clone https://github.com/smangul1/needle.git
cd needle
./install.sh -n -d $DB_LOCATION
cd ..


# Download MetaPhlAn 2.
echo '----- Downloading MetaPhlAn 2 --------------------------------------------------'
hg clone https://bitbucket.org/biobakery/metaphlan2
cd metaphlan2
ln -s ../../db_human/databases
cd ..

#Download ichorCNA
git clone https://github.com/broadinstitute/ichorCNA.git


# Download MiniConda
echo '----- Setting up Python environment --------------------------------------------'
if [ $NATIVE ]
then
echo "MiniConda will not be downloaded. You may use environment.yml to set up your python environment."
else
./install-MiniConda.sh
cd MiniConda/lib
ln -s libncursesw.so.5 libtinfow.so.5
cd ../..
cd MiniConda/bin/
./conda install r=4.0.1
cd ../..
MiniConda="$PWD/MiniConda/bin/python"
fi


fi


##################   DB   ##################

echo "Download databases"
cd $DIR/db_${ORGANISM}/


download_list=$'metaphlan'


declare -A DB_ID_HUMAN=(
['metaphlan']='15UGuZ4klBjIEYV-tv6t1nYa2GdyadZAm'
)

declare -A DB_MD5_HUMAN=(
['metaphlan']='3c9b9d6414d86a0c3d5018aefa5aaec4'
)


echo '----- Downloading MetaPhlAn 2 database ----------------------------------------------------'
for download in $download_list; do
echo "Downloading item: $download for $ORGANISM"
success=false
while [ $success = false ]; do
case "$ORGANISM" in
human)
db_id="${DB_ID_HUMAN[$download]}"
db_md5="${DB_MD5_HUMAN[$download]}"
;;
mouse)
db_id="${DB_ID_MOUSE[$download]}"
db_md5="${DB_MD5_MOUSE[$download]}"
;;
*)
echo 'Error: Unknown ORGANISM.' >&2
exit 1
;;
esac
confirm_code=`curl --silent --insecure --cookie-jar cookies.txt \
"https://docs.google.com/uc?export=download&id=$db_id" \
| sed -rn 's .*confirm=([0-9A-Za-z_]+).* \1\n p'`
curl --location --insecure --cookie cookies.txt -o "$download.tar.gz" \
"https://docs.google.com/uc?export=download&confirm=$confirm_code&id=$db_id"
rm cookies.txt
if [ `md5sum "$download.tar.gz" | sed 's \(.*\)\ .* \1 '` = "$db_md5" ]; then
tar -zxvf "$download.tar.gz"
rm "$download.tar.gz"
success=true
else
echo "Download of $download for $ORGANISM failed (checksum" \
'mismatch. Retrying.'
fi
done
done











