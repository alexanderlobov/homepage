---
title: Deploying a site to git
tags: hakyll,git
language: english
---

I use [Hakyll](https://jaspervdj.be/hakyll) to create my blog and [Github
pages](http://pages.github.com) for hosting. I deploy the site as follows:

Replace `hakyll` to `hakyllWith config` in the code.
Define config:

``` haskell
config :: Configuration
config = defaultConfiguration
    { deployCommand = "./deploy"
    }
```

Code of `deploy` script:

``` bash
#!/bin/bash

SITE_PATH="../alexanderlobov.github.io/"

echo Deploying site

if git diff-index --quiet HEAD; then
    echo "No changes in the working copy of the source code found"
    commit_hash=`git log -n 1 --oneline | cut -f 1 -d ' '`
    echo Last commit is $commit_hash
    cp -r _site/* $SITE_PATH
    cd $SITE_PATH
    git status

    echo "Commit the changes to $SITE_PATH (y/n)?"
    read answer
    case $answer in
        y | yes) git add -A && git commit -m "Updating from $commit_hash" && git push origin master ;;
        *) echo No changes has been commited; exit 2 ;;
    esac
else
    echo "There are changes in the working copy."
    echo "You should commit them before deploying."
    exit 1
fi

```

Don't forget to make `deploy` executable:

```
chmod u+x deploy
```

You can deploy in two ways

1. `./deploy`
2. `stack exec site deploy`


