# :sponge: zsh-sweep

```
Usage: zsweep [--help/-h] [-C work-dir] [--auto] [--func]
                 [--script] [--src] [--dbg]
 
--help/-h        – this message 
-C work-dir      – like -C in Git – first cd to a dir 
--auto           – guess type of Zsh file 
--func           – set input file type to function 
--script         – set input file type to binary-script 
--src            – set input file type to sourced-script 
--dbg            – enable debug messages
```
## Screenshots

![screenshot](https://raw.githubusercontent.com/psprint/zsh-sweep/master/img/screenshot.png)

## Instalation

### No plugin manager

```zsh
    git clone https://github.com/psprint/zsh-sweep {CLONE-OUT-DIR}
    print 'zs_set_path=1' >> ~/.zshrc # add to $PATH
    print 'source {CLONE-OUT-DIR}/zsh-sweep.plugin.zsh' >> ~/.zshrc
```

### Zinit
#### Without zinit-annex-bin-gem-node
```zsh
zinit param'zs_set_path' for @psprint/zsh-sweep
```

#### With zinit-annex-bin-gem-node
```
zinit sbin'bin/zsweep' for @psprint/zsh-sweep
```