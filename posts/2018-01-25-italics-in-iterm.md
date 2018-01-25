---
title: How to use italics in vim
tags: vim, colorscheme
language: english
---

# Issue

I want to use italics font for my
[codefocus](https://github.com/alexanderlobov/config/blob/master/vim/colors/codefocus.vim)
vim colorscheme. But it does not work in `iterm2` terminal.

# Solution

Good description of issues that can affect italics font rendering in a terminal
is
[here](https://www.reddit.com/r/vim/comments/24g8r8/italics_in_terminal_vim_and_tmux/).

I found out that italics works in `iterm2` terminal, because the output of

    `echo `tput sitm`italics`tput ritm`

was rendered in italics.
But vim rendered italics as "standout" text. The solution is to override the
codes vim uses to render font. It is "Step 4" in
[this article](https://www.reddit.com/r/vim/comments/24g8r8/italics_in_terminal_vim_and_tmux/).

    set t_ZH=^[[3m
    set t_ZR=^[[23m

Note that the character `^[` must be entered with `<C-V><Esc>`.
