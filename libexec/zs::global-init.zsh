#!/usr/bin/env zsh
#
# Copyright (c) 2023 Sebastian Gniazdowski

# Possibly fix $0 with a new trick – use of a %x prompt expansion
0="${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}"

# Set the base and typically useful options
builtin emulate -L zsh
builtin setopt localoptions extendedglob warncreateglobal typesetsilent \
                noshortloops noautopushd nopromptsubst rcquotes

export ZSNICK=${ZSNICK:-ZSweep}
typeset -g -a reply match mbegin mend qreply
typeset -g REPLY MATCH TMP qe; integer MBEGIN MEND

# Plugins hash
typeset -gA Plugins ZS
# Already sourced?
((Plugins[ZS_GL_SRCD]))&&return 0
# Mark that init script has been sourced
Plugins[ZS_GL_SRCD]=1
# FUNCZSION: zsmsg [[[
# An wrapping function that looks for backend outputting function
# and uses a verbatim `print` builtin otherwise.
zsmsg_()
{
    if (($+functions[zsmsgi])); then
        \zsmsgi "$@"
    elif [[ -x $ZSDIR/functions/zsmsgi ]]; then
        $ZSDIR/functions/zsmsgi "$@"
    elif (($+commands[zsmsgi])); then
        command zsmsgi "$@"
    else
        builtin print -r -- ${(@)${@//(%f|%B|%F|%f)/}//\{[^\}]##\}/}
    fi
}
# ]]]
export ZSDIR

# Run as script? ZSH_SCRIPT is a Zsh 5.3 addition
if [[ $0 != */zs::global-init.zsh || ! -f $0 ]]; then
     if [[ -f $0:h/zs::global-init.zsh ]]; then
        Plugins[ZSDIR]=$0:h:h
        ZSDIR=$Plugins[ZSDIR]
    elif [[ -f $ZSDIR/libexec/zs::global-init.zsh ]]; then
        0=$ZSDIR/libexec/zs::global-init.zsh
        Plugins[ZSDIR]=$ZSDIR
    elif [[ -f $Plugins[ZSDIR]/libexec/zs::global-init.zsh ]]; then
        0=$Plugins[ZSDIR]/libexec/zs::global-init.zsh
        ZSDIR=$Plugins[ZSDIR]
    else
        local -a q=($Plugins[ZSDIR] $ZSDIR $0:h:h)
        zsmsg {204}Error:%f couldn\'t locate {39}$TINICK%f source \
            directory (tryied in dirs: {27}${(j:%f,{27}:)q}%f), \
            cannot continue.
        return 1
    fi
else
    Plugins[ZSDIR]=$0:h:h
    ZSDIR=$Plugins[ZSDIR]
fi

# Shorthand vars
local QZS=$0:h:h
local -aU path=($path) fpath=($fpath)
local -U PATH FPATH

# In case of the script using other scripts from the plugin, either set up
# $fpath and autoload, or add the directory to $PATH.
fpath+=( $QZS/{libexec,functions}(N/) )

# OR
path+=( $QZS/{bin,libexec,functions}(N/) )

# Modules
zmodload zsh/parameter zsh/datetime||return 3

export ZSCONFIG ZSNFO ZSCACHE ZSLOG ZSNL ZSTXT

 # Right customizable ~/.config/… and ~/.cache/… file paths
: ${ZSCONFIG:=${XDG_CONFIG_HOME:-$HOME/.config}/${(L)ZSNICK}}
: ${ZSNFO:=$ZSCONFIG/zsweep.conf}
: ${ZSCACHE:=${${XDG_CACHE_HOME:+$XDG_CACHE_HOME/${(L)ZSNICK}}:-$HOME/.cache/${(L)ZSNICK}}}
: ${ZSLOG:=$ZSCACHE/${(L)ZSNICK}.log}
: ${ZSNL:=$ZSLOG}
: ${ZSAES:=$ZSDIR/aliases}
: ${ZSTXT:=$ZSDIR/txt}
export ZSNFO=${~ZSNFO} ZSLOG=${~ZSLOG} ZSCACHE=${~ZSCACHE} \
        ZSCONFIG=${~ZSCONFIG} ZSNL=${~ZSNL} ZSAES=${~ZSAES}
command mkdir -p $ZSNFO:h $ZSLOG:h $ZSCACHE $ZSCONFIG $ZSNL:h $ZSAES:h

# No config ?
if [[ ! -f $ZSNFO ]]; then
    command touch $ZSNFO
    [[ ! -f $ZSNFO ]]&&{zsmsg -h %U{204}Error:%f couldn\'t create \
                the config %B{39}$ZSNFO%f%b, please addapt \
                file permissions or check if disk is full.
                return 4
    }
fi

# Autoload functions
autoload -z $QZS/functions/(zs:#|@)*~*'~'(#qN.non:t) \
                    $QZS/functions/*/zs:*~*'~'(#qN.non:t2) \
                        #zsweep:pass

# Export a few local var
util/zs::setup-aliases||return 1
util/zs::verify-zsweep-dir
util/zs::get-prj-dir&&local -x PDIR=$REPLY PID=$REPLY:t:r

# vim: ft=zsh sw=2 ts=2 et foldmarker=[[[,]]] foldmethod=marker
