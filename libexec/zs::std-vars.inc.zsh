setopt rcquotes
local \
    qd='$' qa='`' qaa="'" \
    qocb='{' qccb='}' \
    qob='(' qcb=')' \
    qsp='[[:space:]]##' \
    qosp='[[:space:]]#' \
    qnosp='[^[:space:]]##' qnoosp='[^[:space:]]#' \
    qnl=$'\n' \
    qinc=/ \
    qnoalnum='[^[:alnum:]]##' \
    qnooalnum='[^[:alnum:]]#' \
    qid='[[:IDENT:]]##' \
    qoid='[[:IDENT:]]#' \
    qqstr1='["]([^"]#)["]' \
    qqstr3='['']([^'']#)['']' \
    qqstr4='[\`]([^\`]#)[\`]' \
    qqstr5='$[\(][\(]([^\)]#)[\)][\)]' \
    qqstr5a='$[\(]([^\)]#)[\)]' \
    qqstr7='$[\{]([^\}]#)[\}]'

local qstr="($qqstr1|$qqstr3$qqstr4|$qqstr5|$qqstr5a|$qqstr7|)"
local qostr=$qstr[1,-2]'|([^[:space:]]#))'
local -a qqprecmd=('\{' '\(' noglob command exec nocorrect builtin
                    '\&\&' '\|\|' '\|' '\&' if while )
local qpre="($qosp(${(~j.|.)${qqprecmd[@]/(#e)/$qsp}}')|(#s)$qosp)"
local qemu="(emulate$qsp(-L|-RL|-LR|-R)$qsp(zsh|sh|ksh|bash)|\
setopt$qsp(localoptions|))$qosp"
# Options string, either opt1 opt2, or -o opt1 -o opt2
local qopt="((#b)(${(~j.|.)${(@)${(@f)"$(<$ZSDIR/data/14_recommended_options)"}/\
(#s)/"($qsp-o$qsp|$qsp)"}})#)"

#print -r qpre: $qpre
#print -r qopt:$qopt