0=${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}

setopt rcquotes #zsweep:pass
local \
    qqob='[' qqcb=']' \
\
    qd='$' qa='`' qaa="'" \
    qocb='{' qccb='}' \
    qob='(' qcb=')' \
    qnobq='[^\\]' qbq='\\##' qobq='\\#' \
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

# Multiple ids and mul.ids optional
local qmid="(($qid)$qosp)##"
local qomid="(($qid)$qosp)#"
# The same with -o
local qmoptid="((-o |)$qid$qosp)##"
local qomoptid="((-o |)$qid$qosp)#"
# String and str. optional
local qstr="($qqstr1|$qqstr3$qqstr4|$qqstr5|$qqstr5a|$qqstr7|)"
local qostr=$qstr[1,-2]'|([^[:space:]]#))'

local -a qqprecmd=('\{' '\(' noglob command exec nocorrect builtin
                    '\&\&' '\|\|' '\|' '\&' if while ) \
        qqqprecmd=('\{' '\(' noglob nocorrect builtin
                    '\&\&' '\|\|' '\|' '\|\&' '>\(' '<\(' '\&' if while )

local qpre="($qosp(${(~j.|.)${qqprecmd[@]/(#e)/$qsp}}')|(#s)$qosp)"
local qqpre="($qosp(${(~j.|.)${qqqprecmd[@]/(#e)/$qsp}}')|(#s)$qosp)"
local qemu="(${qosp}emulate$qsp(-L|-RL|-LR|-R)$qsp(zsh|sh|ksh|bash)|\
setopt$qsp(localoptions|))$qsp" #zsweep:pass
# Options string, either opt1 opt2, or -o opt1 -o opt2
local qropt="((#b)(${(~j.|.)${(@)${(@f)"$(<$ZSDIR/data/14_recommended_options)"}/\
(#s)/"($qsp-o$qsp|$qsp)"}})#)"

#print -r qpre: $qpre
#print -r qopt:$qopt