#!/bin/sh


VERSION="0.1.0"
CONFIG_DIR="$HOME/.config/rem"
STORAGE="$CONFIG_DIR/storage"
FILE="memory"
EDITOR="nano"
FULL_PATH="$STORAGE/$FILE"
PASSWORD=""
#
USE_EDITOR=1 # 1 false, 0 true


source "$(dirname "$0")/style.sh"
source "$(dirname "$0")/func.sh"

if [ ! -f "$FULL_PATH" ];then
	mkdir -p "$STORAGE" && touch "$FULL_PATH"
	cat "$(dirname "$0")/conf" > "$CONFIG_DIR/rem.conf"
fi
source "$(dirname "$0")/config.sh"


# file "$FILE"


logo()
{
	NAME="r,e,m"
	i=0
	IFS=","
	echo -e "$(color fg red)"
	for c in $NAME; do
		echo -n "[ $c ]"	
	done
	echo -e "$NC e m b e r"
}


show_help()
{
	logo		
	echo -e "\n$(color fg red)usage: rem [option] [arguments]${NC}\n"
	echo -e "rem - second memory.\n"
	echo "options: "
	printf "  %-30s %s\n" "-h, --help" "Shows this help menu."
	printf "  %-30s %s\n" "-f, --file [name]" "Specify the memory file to use. If the file doesn’t exist, you’ll be prompted to create it."
	printf "  %-30s %s\n" "-a, --add" "Adds a new memory"
	printf "  %-30s %s\n" "-s, --search [arg]" "Searches for a memory. The argument is optional"
	printf "  %-30s %s\n" "-d, --delete [ID/index]" "Removes a memory from ID or index. ID or index is required"
	printf "  %-30s %s\n" "-df, --delete-file [name]" "Removes a file memory from name. name is required"
	printf "  %-30s %s\n" "-e, --edit [ID/index]" "Edits a memory from ID or index. ID or index is required."
	printf "  %-30s %s\n" "-p, --password [name]" "Sets/changes password of a file."
	printf "  %-30s %s\n" "-l, --list [ID/index]" "Lists memory either by id or index."
	printf "  %-30s %s\n" "-la, --list-all" "Lists all memory."
	printf "  %-30s %s\n" "-lf, --list-files" "Lists all memory files."
	printf "  %-30s %s\n" "-v, --version" "Shows version."

	echo -e "\nconfiguration: "
	printf "  %-30s %s\n" "--default-file" "Returns the default file's name."
	printf "  %-30s %s\n" "--set-default-file [name]" "Sets the default file."
	printf "  %-30s %s\n" "--default-editor" "Returns the default terminal text editor."
	printf "  %-30s %s\n" "--set-default-editor [command]" "Sets the default editor."
	printf "  %-30s %s\n" "--use-editor" "Returns whether the editor is being used always."
	printf "  %-30s %s\n" "--set-use-editor [value]" "Sets rem to either use the editor when possible. (0: yes, 1:no)."
}

pre_break()
{
	if [ -n "$PASSWORD" ]; then
		encrypt "$FILE"
	fi
}
multi_arg()
{
	CURRENT=""
	while [ -n "$2" && "$2" != -* ]; do
		CURRENT="$CURRENT $2"
		shift
	done
	shift
}

if [ $# -gt 0 ]; then
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-a|--add|-ae)
				if [ "$1" = "-ae" ];then
					USE_EDITOR=0
				fi
				add
				shift
				;;
			-s|--search)
				if [[ -n "$2" && "$2" != -* ]]; then
					CURRENT=""
					while [[ -n "$2" && "$2" != -* ]]; do
						CURRENT="$CURRENT $2"
						shift
					done
					search_warg "$CURRENT"
					shift 
				else
					search
					shift
				fi
				;;
			-p|--password)
				if [[ -n "$2" && "$2" != -* ]]; then
					password "$2"
					shift 2
				else
					echo "name is required"
					exit 1
				fi
				;;
			-d|--delete)
				if [[ -n "$2" && "$2" != -* ]]; then
					delete_memory "$2"
					shift 2
				else
					echo "ID or index is required"
					exit 1
				fi
				;;
			-e|--edit|-ee)
				if [ "$1" = "-ee" ];then
					USE_EDITOR=0
				fi
				if [[ -n "$2" && "$2" != -* ]]; then
					edit_memory "$2"
					shift 2
				else
					echo "ID is required"
					exit 1
				fi
				;;
			-l|--list)
				if [[ -n "$2" && "$2" != -* ]]; then
					list "$2"
					shift 2
				else
					echo "ID or index is required"
					exit 1
				fi
				;;
			-la|--list-all)
				list_all
				shift
				;;
			-lf|--list-files)
				list_files
				shift
				;;
			-df|--delete-file)
				if [[ -n "$2" && "$2" != -* ]]; then
					delete_file "$2"
					shift 2
				else
					echo "name is required"
					exit 1
				fi
				;;
			-h|--help)
				show_help		
				shift
				;;
			-f|--file)
				if [[ -n "$2" && "$2" != -* ]]; then
					file "$2"
					shift 2
				else
					message reject "file name required"
					exit 1
				fi
				;;
			-v|--version)
				echo -e "\nVersion : $VERSION\n"
				shift
				break
				;;
			--default-file)
				echo -e "\n default_file = $FILE \n"
				shift
				break
				;;
			--set-default-file)
				if [[ -n "$2" && "$2" != -* ]];then
					set_default_file "$2"
					shift 2
				else
					message reject "file name required"
					exit 1
				fi
				break
				;;
			--default-editor)
				echo -e "\n default_editor = $EDITOR \n"
				shift
				break
				;;
			--set-default-editor)
				if [[ -n "$2" && "$2" != -* ]];then
					set_default_editor "$2"
					shift 2
				else
					message reject "editor command required"
					exit 1
				fi
				break
				;;
			--use-editor)
				echo -e "\n use_editor = $USE_EDITOR \n"
				shift
				break
				;;
			--set-use-editor)
				if [[ -n "$2" && "$2" != -* ]];then
					set_use_editor "$2"
					shift 2
				else
					message reject "value is requried (0: yes, 1:no)"
					exit 1
				fi
				break
				;;
			--)
				shift
				break
				;;
			*)
				show_help
				exit 1
				;;
		esac
	done
else
	show_help
fi

pre_break





