plug.sh(1)

# NAME

plug.sh - plugin updating system for vim

# SYNOPSIS

```
$ echo airline https://github.com/vim-airline/vim-airline >> ~/.vim/bundle/plug.list
$ ~/.vim/plug.sh
```

# DESCRIPTION

*plug.sh* is plugin updating script for Vim/Neovim to be used with pathogen.vim or Vim 8 packages. Plugins will be
installed and updated from a previously configured location. The plug.sh script will read a name and repository
url from the *$VIM_PLUG_DIR*/plug.list file in the previously configured location. *git*(1) is used to install and update the
plugins.

# INSTALLATION

1. Setup pathogen.vim or Vim 8 packages.

```
$ mkdir ~/.vim/pack/plugins/start/  # vim 8 packages
$ ln -s pack/plugins/start ~/.vim/bundle
```

2. Download and configure *plug.sh*. You should edit *$VIM_PLUG_DIR* to match your setup.

```
$ curl -sL https://github.com/eNV25/vim-plug-sh/raw/master/plug.sh > ~/.vim/plug.sh
$ vim ~/.vim/plug.sh
```

3. Add a plugin to  *$VIM_PLUG_DIR*/plug.list 

```
$ echo airline https://github.com/vim-airline/vim-airline >> ~/.vim/bundle/plug.list
$ chmod +x ~/.vim/plug.sh
$ ~/.vim/plug.sh
```

# SEE ALSO

vim(1) nvim(1) git(1) git-pull(1) git-clone(1)

# LICENSE

BSD Zero Clause License. See LICENSE.

# AUTHORS

eNV25 <https://github.com/eNV25>
