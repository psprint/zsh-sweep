# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2023 Sebastian Gniazdowski

# Possibly fix $0 with a new trick – use of a %x prompt expansion
0=${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}

if [[ ${zsh_loaded_plugins[-1]} != */zsh-scan && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}

# Standard hash for plugins, to not pollute the namespace
typeset -gA Plugins
Plugins[ZSDIR]="${0:h}"

export ZSDIR="${0:h}" ZSNICK ZSCONFIG ZSNFO ZSLOG ZSCACHE ZSNL \
        ZSAES ZSTHEME

() {
builtin emulate -L zsh -o extendedglob
# Right customizable ~/.config/… and ~/.cache/… file paths
: ${ZSNICK:=ZshScan}
# Config dir and file
: ${ZSCONFIG:=${XDG_CONFIG_HOME:-$HOME/.config}/${(L)ZSNICK}}
: ${ZSNFO:=$ZSCONFIG/zscan.conf}
# Cache dir and file
: ${ZSCACHE:=${XDG_CACHE_HOME:-$HOME/.config}/${(L)ZSNICK}}
: ${ZSLOG:=$ZSCACHE/${(L)ZSNICK}.log}
# Aliases dir
: ${ZSAES:=$ZSDIR/aliases}
# /dev/null file
: ${ZSNL:=$ZSLOG}

export ZSNICK ZSNFO=${~ZSNFO} ZSLOG=${~ZSLOG} ZSCONFIG=${~ZSCONFIG} \
        ZSCACHE=${~ZSCACHE} ZSNL=${~ZSNL} ZSAES=${~ZSAES}
command mkdir -p $ZSNFO:h $ZSLOG:h $ZSCACHE $ZSCONFIG $ZSNL:h $ZSAES
}

(($+zs_set_path))&&typeset -gU path=($ZSDIR/bin $path)

autoload -z functions/*[^~](N.,@:t) functions/*/*[^~](N.,@:t2)

util/zs::setup-aliases||return 1
# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
