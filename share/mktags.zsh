#!/usr/bin/env zsh
emulate zsh -o extendedglob

command ctags -R -e -G --totals=yes --options=share/zsh.ctags --languages=zsh,zsh3,make \
            {functions,libexec,bin}/**/*~*~(.) && \
    print TAGS created ||\
    print Problem creating TAGS index
