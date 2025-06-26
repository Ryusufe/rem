#!/bin/sh



MEMORY=""
KEYWORDS=""
TARGET=""
fIDs=""
ANSWER=""


#------+
# MAIN |
#------+

add()
{
	if [ "$USE_EDITOR" -eq 0 ]; then
		temp=$(mktemp)
		"$EDITOR" "$temp"
		clean_memory "$temp"
		rm "$temp"
	fi
	if [ -z "$MEMORY" ]; then
		ask "What would you like to remember :"
		MEMORY="$(echo -n "$ANSWER" | awk '{ printf "%s\\n", $0}')"
	fi
	MEMORY=$(clean_str "$MEMORY")
	ask "Give it some keywords (separated by space) : "
	KEYWORDS=$(clean_str "$ANSWER")
	save "$(random_id)"
	message confirm "Memory Saved"
}

search()
{
	ask "Enter some keywords (seperated by space)"
	TARGET="$ANSWER"
	search_warg "$TARGET"
}
search_warg()
{
	TARGET="$1"
	search_output
		
}
search_output()
{
	FOUND=$(awk -F'|' -v target="$TARGET" -v al="$ALINE" -v gl="$GLINE" '
	BEGIN{
		
		split(target, tmp, " ")
		for (i in tmp) target_keys[tmp[i]] = 1
		
	}
	{
		split($3, list, " ")
		for (i in list){
			if (list[i] in target_keys){
				print $0
				break
			}
		}
	}
	' "$FULL_PATH")

	output_list "$FOUND"
}

list_all()
{
	output_list "$(cat "$FULL_PATH")"
}

list()
{
	INPUT_TYPE="$(id_or_index "$1")"
	if [ $INPUT_TYPE -eq 0 ]; then
		list_by_id "$1"
	else
		list_by_index "$1"
	fi
}

list_by_id(){
	output_list "$(grep "^$1" "$STORAGE/$FILE")"
}

list_by_index()
{
	# if [ "$(wc -l < "$STORAGE/$FILE" | tr -d ' ')" -ge "$(("$1" + 1))" ]; then
	output_list "$(head -n $(("$1" + 1)) "$STORAGE/$FILE" | tail -n 1)"
	# else
	# 	message reject "index is out of range"
	# fi
}

delete_memory()
{
	INPUT_TYPE="$(id_or_index "$1")"
	LINE_INDEX=""
	if [ $INPUT_TYPE -eq 0 ]; then
		TARGET_LINE="$(cat "$FULL_PATH" | grep -n "$1")"
		LINE_INDEX="$( echo $TARGET_LINE | cut -d: -f1)"
		LINE_TEXT="$( echo $TARGET_LINE | cut -d: -f2-)"
		output_list "$LINE_TEXT"
	else
		LINE_INDEX="$(("$1" + 1))"
		list_by_index "$1"
	fi
	ask "You sure you want to remove it? (y/n)"
	if [ $ANSWER = "y" ]; then
		sed -i "${LINE_INDEX}d" "$FULL_PATH"
		message confirm "Memory Deleted"
	else 
		message alert "Canceled"
	fi
}

edit_memory()
{

	INPUT_TYPE="$(id_or_index "$1")"
	LINE_INDEX=""
	LINE_TEXT=""
	if [ $INPUT_TYPE -eq 0 ]; then
		TARGET_LINE="$(cat "$FULL_PATH" | grep -n "$1")"
		LINE_INDEX="$( echo $TARGET_LINE | cut -d: -f1)"
		LINE_TEXT="$( echo $TARGET_LINE | cut -d: -f2-)"
	else
		LINE_INDEX="$(("$1" + 1))"
		LINE_TEXT="$(head -n $(("$1" + 1)) "$STORAGE/$FILE" | tail -n 1)"
	fi
	temp=$(mktemp)
	IFS="|" read -r -a LINE_PARTS <<< "$LINE_TEXT"
	if [ "$USE_EDITOR" -eq 0 ]; then
		echo -e "${LINE_PARTS[3]}" > $temp
		"$EDITOR" $temp	
	else
		ask "Edit Memory (${LINE_PARTS[3]}) :"
		MEMORY="$ANSWER"
	fi
	ask "Edit Keywords (${LINE_PARTS[2]}) :"
	KEYWORDS="$ANSWER"
	###
	if [ "$USE_EDITOR" -eq 0 ]; then
		clean_memory "$temp"
		FULL_LINE="$1|${LINE_PARTS[1]}|$(pick_ne_str "$(clean_str "$KEYWORDS")" "${LINE_PARTS[2]}")|$MEMORY"
		save_update "$LINE_INDEX" "$FULL_LINE"
	else
		FULL_LINE="$1|${LINE_PARTS[1]}|$(pick_ne_str "$(clean_str "$KEYWORDS")" "${LINE_PARTS[2]}")|$(pick_ne_str "$(clean_str "$MEMORY")" "${LINE_PARTS[3]}")"
		sed -i "${LINE_INDEX}s/.*/$FULL_LINE/" "$FULL_PATH"
	fi
	rm "$temp"
	message confirm "New Memory Saved"
}




file()
{
	if [ -e "$STORAGE/$1" ]; then
		update_file "$1"
	elif [ -e "$STORAGE/$1.enc" ]; then
		decrypt "$1"
	else
		ask "[ $1 ] does not exit, do you want to create it? (y/n)"
		if [ $ANSWER = "y" ]; then
			touch "$STORAGE/$1"

			ask "would you like to encrypt it with a password? (y/n)"
			if [ $ANSWER = "y" ]; then
				set_password
				encrypt "$1"	
			fi
			message confirm "$1 file was created"
			update_file "$1"	
		fi
	fi
}

list_files()
{

	FILES="$(ls -t "$STORAGE")"
	for file in $FILES; do
		if echo -n "$file" | grep -q "\.enc" ; then
			printf "%-20s" "$(echo $file | sed "s/.enc//")" && echo -e "$(color fg green) [LOCKED] $NC" 
		else
			printf "%-20s" "$file" && echo -e "$(color fg red) [OPEN] $NC"
		fi
	done

}


delete_file()
{
	if [ -e "$STORAGE/$1" -o -e "$CONFIG_DIR/$1.enc" ]; then
		ask "Are you sure you want to delete [$1] ? (y/n)"
		if [ $ANSWER = "y" ]; then
			rm "$STORAGE/$1"*
			message confirm "$1 has been removed"
		fi
	else
		message reject "File doesn't exist"
	fi

}

password()
{

	if [ -e "$STORAGE/$1" ]; then
		set_password
		encrypt "$1"
	elif [ -e "$STORAGE/$1.enc" ]; then
		message alert "changing password"
		stty -echo
		ask "Enter current password"
		PASSWORD="$ANSWER"
		stty echo
		decrypt "$1"
		if [ -e "$STORAGE/$1" ]; then
			set_password
			encrypt "$1"
		fi
	else
		message reject "File doesn't exist"
	fi

}



#------+
# SIDE |
#------+

ask()
{
	echo -e "$NC\n- $1"
	echo -n -e "> $(color fg blue)"
	read -r ANSWER
}

random_id()
{
	echo -n "i$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)"
}

clean_str(){
	echo "$1" | tr "|" "-"
}


pick_ne_str(){
	if [ -n "$1" ];then
		echo "$1"
	else 
		echo "$2"
	fi
}

clean_memory()
{
	MEMORY=$(awk '{ printf "%s\\\\n", $0 }' "$1")
	MEMORY=${MEMORY%\\\\n}	
}
save(){
	echo "$1|$(get_date)|$KEYWORDS|$MEMORY" >> "$FULL_PATH"
}
save_update(){
	awk -v n="$1" -v repl="$2" 'NR == n { print repl; next } 1' "$FULL_PATH" > temp && mv temp "$FULL_PATH"	
}

output_list()
{
	IFS=$'\n'
	gID=0
	echo -e "$NC$LINKED_LINE"
	LINES_COUNT="$(echo "$1" | wc -l)"
	BLUE=$(color fg blue)
	for line in $1; do
		IFS="|"
		iID=0
		for col in $line; do
			case $iID in
				0)
					printf "\n$BLUE%-25s : $NC%s" "ID" "$col" 
					;;
				1)
					printf "\n$BLUE%-25s : $NC%s" "Date" "$col"
					;;
				2)
					printf "\n$BLUE%-25s : $NC%s" "Keywords" "$col"
					;;
				3)
					printf "\n\n$col"
					;;
				*)
					;;
			esac
			iID="$((iID + 1))"
		done
		IFS=$'\n'
		gID="$((gID + 1))"
		if [ ! "$LINES_COUNT" -eq "$gID" ]; then 
			echo -e "\n----"
		fi		
	done

	echo -e "\n$LINKED_LINE"
}


update_file()
{
	FILE="$1"
	FULL_PATH="$STORAGE/$FILE"
	# message alert "[ $1 ] is the current target file"
}

encrypt()
{
	if [ ! -n "$PASSWORD" ]; then
		stty -echo
		ask "Please enter password"
		stty echo
		PASSWORD="$ANSWER"
	fi
	openssl enc -aes-256-cbc -salt -in "$STORAGE/$1" -out "$CONFIG_DIR/$1.enc" -pass pass:"$PASSWORD" > /dev/null 2>&1
	rm -f "$STORAGE/$1"
}

decrypt()
{
	if [ ! -n "$PASSWORD" ]; then
		stty -echo
		ask "Please enter password"
		stty echo
		PASSWORD="$ANSWER"
	fi
	TMPFILE=$(mktemp)
	if openssl enc -aes-256-cbc -d -in "$STORAGE/$1.enc" -out "$TMPFILE" -pass pass:"$PASSWORD" > /dev/null 2>&1; then
    		mv "$TMPFILE" "$STORAGE/$1"
	else
    		rm "$TMPFILE"
		message reject "Wrong password"
		exit 1
	fi

	rm "$STORAGE/$1.enc"
	update_file "$1"
}


set_password()
{
	stty -echo
	ask "Enter the new password"
	PASSWORD="$ANSWER"
	ask "Confirm password"
	stty echo
	if [ "$PASSWORD" = "$ANSWER" ]; then
		message confirm "Password has been set"
	else
		message reject "Password isn't matching"
		exit 1
	fi
}

message() 
{
	case "$1" in
		confirm)
			echo -e "$NC\n$(color fg green)✔ $2."
			;;
		alert)		
			echo -e "$NC\n$(color fg yellow)! $2."
			;;
		reject)
			echo -e "$NC\n$(color fg red)✘ $2."
			;;
	esac
}

get_date(){
	echo -n "$(date +"%F %H:%M")" 
}


id_or_index()
{
	case "$1" in
		i*)
			echo -n 0
			;;
		*)
			if [ "$(echo -n "$1" | wc -m)" -eq 32 ]; then
				echo 0
			else
				echo 1
			fi		
			;;
	esac

}
