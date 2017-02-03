---
title: Mac configuration cheatsheet
tags: mac
language: russian, english
---

Большую часть жизни моей рабочей операционной системой был Линукс. Когда я
работал в одной крупной компании, существенная часть сотрудников которой сидела
на Маках, общественное мнение приучило меня к мысли, что Мак -- это идеальная
сущность в виде гномика, перейдя на которую ты лишишься всех своих проблем, и
всё, о чём тебе останется думать, так это о том, какой кофе сегодня взять в
Старбаксе, или не лучше ли вообще пойти пить смузи.

Но мои влажные фантазии разбились о суровую действительность. Многие вещи, к
которым я привык в Убунте, не работали в Маке из коробки. В общем, [щас я вам
почистию сущность в виде гномика](https://www.youtube.com/watch?v=VT3OfQXLOHM),
или как я настраивал Мак.

## Combinations with Alt does not work in terminal

* Terminal -> Preference (Cmd + ,) -> Profiles -> Keyboard
* Set "Use Option as Meta key"

## Terminal blinking and bell

* Terminal -> Preference (Cmd + ,) -> Profiles -> Advanced
* Unset "Audible bell" and "Visual bell"

## Package manager

Install [homebrew](http://brew.sh/) and [brew cask](https://caskroom.github.io/).

## Get configs

Get .profile, .bashrc and vim configs from bitbucket repo

    git clone https://github.com/alexanderlobov/config.git

## Install byobu

    brew install python
    brew install byobu

If you do not install python from brew, byobu-config (invoked by F9) will not
work. It will fail with "Could not import the python snack module"

### Ctrl-F5 does not work

* System Preferences -> Keyboard -> Shortcuts -> Keyboard
* Unset "Move focus to the window toolbar"
* Terminal -> Preference (Cmd + ,) -> Profiles -> Keyboard
* Add escape sequence for Ctrl-F5. Click on "+" sign. Escape sequence is
`\033[15;5~`. Press Esc to add `\033` symbols.

See also [this stackoverflow answer](http://stackoverflow.com/a/26470118).

### Ctrl-Shift-F3/F4 does not work

* Terminal -> Preference (Cmd + ,) -> Profiles -> Keyboard
    * Add escape sequence for Ctrl-Shift-F3: `\033[1;6R`. Press Esc to add `\033` symbols.
    * Add escape sequence for Ctrl-Shift-F4: `\033[1;6S`. Press Esc to add `\033` symbols.

### Configure status notifications

F9 -> Configure status notifications

## Install terminus font

    $ brew tap caskroom/fonts
    $ brew cask install font-inconsolata

## Remove these strange square brackets in terminal

Edit -> Marks -> Automatically Mark Prompt Lines

