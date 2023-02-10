# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2023 Sebastian Gniazdowski

# Possibly fix $0 with a new trick – use of a %x prompt expansion
0=${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}

if [[ ${zsh_loaded_plugins[-1]} != */zsh-sweep && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}

# Standard hash for plugins, to not pollute the namespace
typeset -gA Plugins
Plugins[ZSDIR]="${0:h}"

# Minimal set of vars
export ZSDIR="${0:h}" ZSNICK ZSNL ZSTHEME ZSTXT ZSAES
: ${ZSTXT:=$ZSDIR/txt}
: ${ZSAES:=$ZSDIR/aliases}

# Accessing the binary
(($+zs_set_path))&&typeset -gU path=($ZSDIR/bin $path)

source $ZSDIR/functions/util/zs::setup-aliases
util/zs::setup-aliases
# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
