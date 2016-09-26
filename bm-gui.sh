#!/bin/bash

#TODO : Backup Method/Pipe
#	Backup Method/Tarball

#CAN BE OPTIMIZE :
#	Encryption	

########################################################
#
#		      VAR
#
########################################################

DIALOG=${DIALOG=dialog}

CONFfile="/etc/backup-manager.conf"
TMPfile="/tmp/.output-BMG.tmp"
OUTPUT=""
FORM=""
ARGS=""
originalIFS=$IFS

########################################################
#
#	            FUNCTIONS
#
########################################################

function getOutput() {
OUTPUT=`cat $TMPfile`
rm -rf $TMPfile
}

function setArg() {
SLASH="\/"
BACK_SLASH="\\\\\/"
arg2=`echo $2 | sed -e "s/$SLASH/$BACK_SLASH/g"`

command sed -i -e \
  's/[#]*\(.*'$1'=\).*$/\1"'$arg2'"/' \
    $CONFfile
}

function createMenu() {
menu='--title "Backup-Manager GUI" --clear --ok-label "Select" --cancel-label "Back" --menu "'${1}'" 20 51 10'
j=1
IFS=$','
for i in ${2}
do
  menu="${menu} \"${j}\" \"${i}\""
  j=$(($j+1))
done
IFS=${originalIFS}
menu="${DIALOG} ${menu} 2> ${TMPfile}"
eval ${menu}
getOutput
}

function newForm() {
forms='--title "'${1}'"  --clear --cancel-label "Back" --ok-label "Save" --form "'${2}'" 15 50 0'
j=1
IFS=$','
for i in ${3}
do
#Espacement avec la gauche/Longueur du champ/
  forms="${forms} \"${i}\" ${j} 1 \"${!ARGS[$(($j-1))]}\" ${j} 20 25 100"
  j=$(($j+1))
done
IFS=${originalIFS}
forms="exec 3>&1; FORM=\$(${DIALOG} ${forms} 2>&1 1>&3);exec 3>&-"
eval ${forms}
}

function saveNewValues() {
IFS=$'\n'
j=0
for i in $FORM
do
  setArg "${ARGS[$j]}" "$i"
  j=$j+1
done
IFS=$originalIFS
}

########################################################
#
#		    PROGRAM
#
########################################################

if [ ! -f "/etc/backup-manager.conf" ]; then
  OUTPUT="Q"
  echo "> /etc/backup-manager.conf doesn't exist !"
fi

while [ "$OUTPUT" != "Q" ]; do

  source $CONFfile
  
  $DIALOG --title "Backup-Manager GUI" --clear \
	--no-cancel \
	--ok-label "Select" \
	--menu "Main menu" 50 50 10 \
	"1" "Repository Settings" \
	"2" "Archives Settings" \
	"3" "Encryption Settings" "4" "Backup Method" \
	"5" "Upload Method" \
	"6" "Burning Method" \
	"7" "Advanced Settings" \
	"Q" "Quit" \
	2> $TMPfile

  getOutput

    #Le choix de l'utilisateur
      case ${OUTPUT} in
        0) echo "ERROR";;
#========================= Repository Settings ===============================
        1)
	ARGS=("BM_DAILY_CRON" "BM_REPOSITORY_ROOT" "BM_TEMP_DIR" "BM_REPOSITORY_SECURE" "BM_REPOSITORY_USER" "BM_REPOSITORY_GROUP" "BM_REPOSITORY_CHMOD")

newForm "Repository Settings" "" "Cron,Root,Temp Dir,Secure,User,Group,CHMOD"

saveNewValues
	;;
#========================= Archives Settings ===============================
	2)
ARGS=("BM_ARCHIVE_CHMOD" "BM_ARCHIVE_TTL" "BM_ARCHIVE_FREQUENCY" "BM_REPOSITORY_RECURSIVEPURGE" "BM_ARCHIVE_PURGEDUPS" "BM_ARCHIVE_PREFIX" "BM_ARCHIVE_STRICTPURGE" "BM_ARCHIVE_NICE_LEVEL" "BM_ARCHIVE_METHOD")

newForm "Archives Settings" "" "CHMOD,TTL,Frequency,Recursive Purge,Purge Dups,Prefix,Strict Purge,Nice Level,Method"

saveNewValues
;;
#========================= Encryption Settings ===============================
	3)
	ARGS=("BM_ENCRYPTION_RECIPIENT")
newForm "Encryption Settings" "Add the lines\nexport BM_ENCRYPTION_METHOD="'\"\"'"\nexport BM_ENCRYPTION_RECIPIENT="'\"\"'"\nin the encryption part to use this form" "Encryption method,Recipient"
	saveNewValues
	;;
#========================= Backup Method ===============================
	4)
createMenu "Backup Method" "Tarball,Tarball-incremental,MYSQL,PostgreSQL,SVN,Pipe"
case ${OUTPUT} in
        0) echo "ERROR";;
#------------------------- Tarball -------------------------------------
        1)
ARGS=("BM_TARBALL_NAMEFORMAT" "BM_TARBALL_FILETYPE" "BM_TARBALL_OVER_SSH" "BM_TARBALL_DUMPSYMLINKS" "BM_TARBALL_BLACKLIST" "BM_TARBALL_SLICESIZE" "BM_TARBALL_EXTRA_OPTIONS")

newForm "Tarball" "" "Name Format,File TYpe,Over SSH, Dump Sym Links,Blacklist,Slice Size,Extra Options"

saveNewValues
	;;
#------------------------- Tarball-incremental ------------------------
        2)
ARGS=("BM_TARBALLINC_MASTERDATETYPE" "BM_TARBALLINC_MASTERDATEVALUE")

newForm "Backup Method - Tarball-incremental" "" "Master Date Type,Master Date Value"

saveNewValues
        ;;
#------------------------- MYSQL -------------------------------------
        3)
ARGS=("BM_MYSQL_DATABASES" "BM_MYSQL_SAFEDUMPS" "BM_MYSQL_ADMINLOGIN" "BM_MYSQL_ADMINPASS" "BM_MYSQL_HOST" "BM_MYSQL_PORT" "BM_MYSQL_FILETYPE" "BM_MYSQL_EXTRA_OPTIONS")

newForm "Backup Method - MYSQL" "" "Databases,Safe dumps,Admin Login,Admin Pass,HOst,Port,File Type,Extra Options"

saveNewValues
        ;;
#------------------------- PostgreSQL --------------------------------
        4)
ARGS=("BM_PGSQL_DATABASES" "BM_PGSQL_ADMINLOGIN" "BM_PGSQL_ADMINPASS" "BM_PGSQL_HOST" "BM_PGSQL_PORT" "BM_PGSQL_FILETYPE" "BM_PGSQL_EXTRA_OPTIONS")

newForm "Backup Method - MYSQL" "" "Databases,Admin Login,Admin Pass,HOst,Port,File Type,Extra Options"

saveNewValues
        ;;
#------------------------- SVN -------------------------------------
        5)
ARGS=("BM_SVN_REPOSITORIES" "BM_SVN_COMPRESSWITH")

newForm "Backup Method - SVN" "" "Repositories,Compress with"

saveNewValues
        ;;
#------------------------- Pipe -------------------------------------
        6)
        ARGS=("BM_SSHGPG_RECIPIENT")

newForm "Backup Method - Pipe" "" "LINES"

saveNewValues
        ;;
esac 
;;
#========================= Upload Method ===============================
	5)	   
	   createMenu "Upload Method" "General Settings,SSH,SSH-GPG,FTP,S3,RSYNC"

        case ${OUTPUT} in
        0) echo "ERROR";;
#------------------------- General Settings ------------------------
	1)
	ARGS=("BM_UPLOAD_METHOD" "BM_UPLOAD_HOSTS" "BM_UPLOAD_DESTINATION")
	newForm "Upload Method - General Settings" "" "Method,Hosts,Destination"
	saveNewValues
	;;
#------------------------- SSH -------------------------------------
	2)
ARGS=("BM_UPLOAD_SSH_USER" "BM_UPLOAD_SSH_KEY" "BM_UPLOAD_SSH_HOSTS" "BM_UPLOAD_PORT" "BM_UPLOAD_SSH_DESTINATION" "BM_UPLOAD_SSH_PURGE" "BM_UPLOAD_SSH_TTL")

newForm "Upload Method - SSH" "" "User,Key Dir,Hosts,Port,Destinationn,Purge,TTL"

saveNewValues
	;;
#------------------------- SSH-GPG ------------------------------------
	3)
ARGS=("BM_UPLOAD_SSHGPG_RECIPIENT")

newForm "Upload Method - SSH-GPG" "" "Recipient"

saveNewValues
	;;
#------------------------- FTP -------------------------------------
	4)
ARGS=("BM_UPLOAD_FTP_SECURE" "BM_UPLOAD_FTP_PASSIVE" "BM_UPLOAD_FTP_TEST" "BM_UPLOAD_FTP_USER" "BM_UPLOAD_FTP_PASSWORD" "BM_UPLOAD_FTP_HOSTS" "BM_UPLOAD_FTP_PURGE" "BM_UPLOAD_FTP_TTL" "BM_UPLOAD_FTP_DESTINATION")

newForm "Upload Method - FTP" "" "Secure,Passive Mode,Test,User,Password,Hosts,Purge,TTL,Destination"

saveNewValues
	;;
#------------------------- S3 -------------------------------------
	5)
ARGS=("BM_UPLOAD_S3_DESTINATION" "BM_UPLOAD_S3_ACCESS_KEY" "BM_UPLOAD_S3_SECRET_KEY" "BM_UPLOAD_FTP_PURGE")

newForm "Upload Method - Amazon S3" "" "Destination,Access Key,Secret Key,Purge"

saveNewValues
	;;
#------------------------- RSYNC -------------------------------------
	6)
ARGS=("BM_UPLOAD_RSYNC_DIRECTORIES" "BM_UPLOAD_RSYNC_DESTINATION" "BM_UPLOAD_RSYNC_HOSTS" "BM_UPLOAD_RSYNC_DUMPSYMLINKS")
        
newForm "Upload Method - RSYNC" "" "Directories,Destination,Hosts,Dump Sym Links"
        
saveNewValues
	;;
	esac
	;;
#========================= Burning Method ===============================
	6)
	    ARGS=("BM_BURNING_METHOD" "BM_BURNING_CHKMD5" "BM_BURNING_DEVICE" "BM_BURNING_DEVFORCED" "BM_BURNING_ISO_FLAGS" "BM_BURNING_MAXSIZE")

newForm "Burning Method" "" "Method,Check md5,device,device forced,iso flags,max size"
      
saveNewValues
	;;
#========================= Advanced Settings ===============================
	7)
		ARGS=("BM_LOGGER" "BM_LOGGER_LEVEL" "BM_LOGGER_FACILITY" "BM_PRE_BACKUP_COMMAND" "BM_POST_BACKUP_COMMAND")

newForm "Advanced Settings" "" "Logger,Logger Level,Logger Facility,Pre Backup Command,Post Backup Command"

saveNewValues
	;;
#========================= Quit ===============================
	"Q") echo "Quit";;
      esac
done
