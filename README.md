# `rem`

`rem` is command line memory manager, it's not intended to be used as a notebook or some fancy information displayer.

All rem does is this :
MemroyFile [locked?] -> ListOfMemories -> { id, date, keywords, memory }

##  Installation

To use `rem`, you'll need to manually set it up:

1. Clone or download this repository.
2. Place the files anywhere you like.
3. Ensure `entry.sh` is the entry point for running `rem`.

You can make `rem` globally available by creating a symbolic link:

```bash
chmod +x entry.sh
# then you can just add this line to ~/.zshrc or ~/.bashrc:
alias rem="path_to/rem/entry.sh"

# or create a simple launcher
echo '#!/bin/sh' > /bin/rem
echo 'sh path_to/rem/entry.sh "$@"' >> /bin/rem
chmod +x /bin/rem

```

## Contributions are welcome

I started this project to get more familiar with Linux scripting, so I’d really appreciate any contributions with helpful comments.

## Usage

Once set up, you can start using `rem` to manage memories directly from your terminal. 

Here are the available commands and their purposes:

### Memory Management

- -a, --add
  Add a new memory.

- -s, --search [keywords]
  searches for memories that matches at least 1 keyword from the keywords you have given.

- -e, --edit [ID]
  Edit a memory.

- -d, --delete [ID] 
  Delete a memory.

- -l, --list-all
  List all memories stored in the current memory file.

### File Management

- -f, --file [name]
  Specify which memory file to use. If it doesn’t exist, it will be created, if this option is not used rem will use the --default-file.

- -df, --delete-file [name]
  Permanently delete an entire memory file by name.

- -lf, --list-files
  Show a list of all memory files you've created.

- -p, --password [name]
  Set or update the password for a specific memory file.

### Configuration

You can customize how `rem` behaves by modifying or querying its configuration:

- --default-file
  Show the currently set default memory file.

- --set-default-file [name]
  Set a default memory file.

- --default-editor
  Display the editor currently used for writing and editing memories, default is nano.

- --set-default-editor [command]
  Change the terminal editor used (e.g., `nano`, `vim`, etc.).

- --use-editor
  Show whether the editor is automatically used when adding or editing.

- --set-use-editor [0|1]
  Configure editor usage. Use `0` to always use the editor, or `1` to skip it by default.


