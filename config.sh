


check_validation()
{
	if [ "$2" != "$3" ]; then
		message reject "Config file has some syntax error at $1"
		exit 1
	fi
}



while IFS='=' read -r key value; do
	tvalue=$(echo "$value" | awk '{$1=$1; print}')
	check_validation "$key" "$value" "$tvalue"
	case $key in
		default_file)
			FILE="$value"
			;;
		default_editor)
			EDITOR="$value"
			;;
		use_editor)
			USE_EDITOR="$value"
			;;
		*)
			;;
	esac
done < "$CONFIG_DIR/rem.conf"



#


change_value(){
	sed -i "s/$1=$2/$1=$3/" "$CONFIG_DIR/rem.conf"
}
set_default_file()
{
	file "$1"
	if [ -e "$STORAGE/$1" -o -e "$STORAGE/$1.enc" ]; then
		change_value "default_file" "$FILE" "$1"
	fi
}
set_default_editor()
{
	change_value "default_editor" "$EDITOR" "$1"
	EDITOR="$1"
}
set_use_editor(){
	change_value "use_editor" "$USE_EDITOR" "$1"
	USE_EDITOR="$1"
}




