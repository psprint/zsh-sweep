#!/usr/bin/env zsh
#
# Copyright (c) 2023 Sebastian Gniazdowski

# A shared stub loaded as the first command in Tig/tigrc binding.
# It sets up environment for all Tig defined commands/bindings

# Handle $0 according to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

# Possibly fix $0 with a new trick – use of a %x prompt expansion
0="${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}"

# Set the base and typically useful options
builtin emulate -L zsh
builtin setopt extendedglob kshglob warncreateglobal typesetsilent noshortloops \
    noautopushd promptsubst

local -x ZSNICK=TigSuite
typeset -gA Plugins

# FUNCZSION: tigmsg [[[
# An wrapping function that looks for backend outputting function
# and uses a verbatim `print` builtin otherwise.
\tigmsg_()
{
    if (($+functions[zmsg])); then
        zmsg "$@"
    elif [[ -x $TIG_SUITE_DIR/functions/zmsg ]]; then
        $TIG_SUITE_DIR/functions/zmsg "$@"
    elif (($+commands[zmsg])); then
        command zmsg "$@"
    else
        builtin print -- ${@${@//(%f|%B|%F|%f)/}//\{[^\}]##\}/}
    fi
}
alias tigmsg='noglob tigmsg_ $0:t\:$LINENO'
# ]]]

# Run as script? ZSH_SCRIPT is a Zsh 5.3 addition
if [[ $0 != */zs::global.zsh || ! -f $0 ]]; then
     if [[ -f $0:h/zs::global.zsh ]]; then
        Plugins[ZSDIR]=$0:h:h
        ZSDIR=$Plugins[ZSDIR]
    elif [[ -f $ZSDIR/libexec/zs::global.zsh ]]; then
        0=$ZSDIR/libexec/zs::global.zsh
        Plugins[ZSDIR]=$ZSDIR
    elif [[ -f $Plugins[ZSDIR]/libexec/zs::global.zsh ]]; then
        0=$Plugins[ZSDIR]/libexec/zs::global.zsh
        ZSDIR=$Plugins[ZSDIR]
    else
        local -a q=($Plugins[ZSDIR] $ZSDIR $0:h:h)
        tigmsg {204}Error:%f couldn\'t locate {39}$TINICK\'s%f source \
            directory (tryied in dirs: {27}${(j:%f,{27}:)q}%f), cannot \
            continue.
        return 1
    fi
else
    Plugins[ZSDIR]=$0:h:h
    ZSDIR=$Plugins[ZSDIR]
fi

# Shorthand vars
local TIG=$0:h:h

local -a reply match mbegin mend
local REPLY MATCH TMP qe; integer MBEGIN MEND
local -aU path=($path) fpath=($fpath)
local -U PATH FPATH

# In case of the script using other scripts from the plugin, either set up
# $fpath and autoload, or add the directory to $PATH.
fpath+=( $TIG/{libexec,functions}(N/) )

# OR
path+=( $TIG/{bin,libexec,functions}(N/) )

# Modules
zmodload zsh/parameter zsh/datetime

export ZSCONFIG ZSNFO ZSLOG ZSCACHE ZSCHOOSE_APP ZSNL

 # Right customizable ~/.config/… and ~/.cache/… file paths
: ${ZSCONFIG:=${XDG_CONFIG_HOME:-$HOME/.config}/${(L)ZSNICK}}
: ${ZSNFO:=$ZSCONFIG/features.reg}
: ${ZSCACHE:=${${XDG_CACHE_HOME:+$XDG_CACHE_HOME/${(L)ZSNICK}}:-$HOME/.cache/${(L)ZSNICK}}}
: ${ZSLOG:=$ZSCACHE/${(L)ZSNICK}.log}
: ${ZSNL:=$ZSLOG}
: ${ZSAES:=$ZSG/aliases}
export ZSNFO=${~ZSNFO} ZSLOG=${~ZSLOG} ZSCACHE=${~ZSCACHE} \
        ZSCONFIG=${~ZSCONFIG} ZSNL=${~ZSNL} ZSAES=${~ZSAES}
command mkdir -p $ZSNFO:h $ZSLOG:h $ZSCACHE $ZSCONFIG $ZSNL:h $ZSAES:h
local QCONF=${ZSNFO//(#s)$HOME/\~}
# useful global alias
alias -g ZSO="&>>!$ZSLOG"

# No config dir found ?
if [[ ! -d $ZSNFO:h ]]; then
    tigmsg -h {204}Error:%f Couldn\'t setup config directory \
                    at %B%F{39}$QCONF:h%b%f, exiting…
    return 1
fi

# No config ?
if [[ ! -f $ZSNFO ]]; then
    command touch $ZSNFO
    [[ ! -f $ZSNFO ]]&&{tigmsg -h %U{204}Error:%f couldn\'t create \
                the registry-file %B{39}$QCONF%f%b, please addapt \
                file permissions or check if disk is full.
                return 4}
fi

# Config empty?
[[ ! -s $ZSNFO ]]&&tigmsg -h %U{204}Warning:%f features registry-file \
                    \({41}$QCONF%F\) currently empty, need to \
                    add some entries

# Autoload functions
autoload -z regexp-replace $TIG/functions/(zmsg|zs::)*~*'~'(#qN.non:t) \
                $TIG/functions/*/zs::*~*'~'(#qN.non:t2)

util//zs::setup-aliases||return 1

# Export a few local var
util/zs::verify-tigsuite-dir||return 1
util/zs::verify-chooser-app||return 1
util/zs::get-prj-dir||return 1
local -x PDIR=$REPLY PID=$REPLY:t:r
local -x ZSPID_QUEUE=$ZSCACHE/PID::${(U)PID}.queue
local -x ZSZERO_PAT='(#s)0#(#e)'

util/zs::chkstr "$PDIR" "$PID" "$ZSPID_QUEUE" "ZSZERO_PAT"||return 1

# Snippets with code
for qe in $TIG/libexec/zs::*.zsh~*/zs::global.zsh(N.); do
    builtin source $qe
    integer ret=$?
    if ((ret));then
        tigmsg -h %U{204}Error:%f error %B{174}$ret%f%b when sourcing \
            sub-file: {39}$qe:t%f…
        return 1
    fi
done

# vim: ft=zsh sw=2 ts=2 et foldmarker=[[[,]]] foldmethod=marker
