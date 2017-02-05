---
title: Urls without html extension in Hakyll
tags: hakyll, disqus
language: english
---

I have begun to use urls without an extension for this site. For example,

    alexanderlobov.ru/posts/2016-11-11-deploying-a-site-to-git/

instead of

    alexanderlobov.ru/posts/2016-11-11-deploying-a-site-to-git.html

The idea and implementation are based on [Yann Esposito's
article](http://yannesposito.com/Scratch/en/blog/Hakyll-setup/#simplify-url).

Why are such urls better? Because `html` extension is an implementation detail,
and url is an interface of site. It is bad to place implementation details in
interface. If I change the site engine (e.g. to
[Yesod](http://www.yesodweb.com/)), urls with an extension
will inevitable change. It will result in issues with broken links, search
engines indexation, integration with Disqus and similar systems.

My solution is mostly the same as Yann uses. The only difference is that I also
changes url and identifier used by [Disqus](http://disqus.com).

You can see all changes in
[this commit](https://github.com/alexanderlobov/homepage/commit/fb9446a5ad238c041c407cb2e7e35a1f9aeab491).

Here is a short summary.

Introduce new routing function

``` haskell
niceRoute :: Routes
niceRoute = customRoute createIndexRoute
    where createIndexRoute identifier =
            takeDirectory p </> takeBaseName p </> "index.html"
            where p = toFilePath identifier
```

Use it for all pathes you want to change. I do it for `posts/*` and
`archive.html`.

You need to changes hyperlinks in HTML code. `removeIndexHtml` do this

``` haskell
removeIndexHtml :: Item String -> Compiler (Item String)
removeIndexHtml item = return $ fmap (withUrls removeIndexStr) item

removeIndexStr :: String -> String
removeIndexStr url = case splitFileName url of
    (dir, "index.html") | isLocal dir -> dir
                        | otherwise -> url
    _ -> url
    where
        isLocal :: String -> Bool
        isLocal uri = not ("://" `isInfixOf` uri)

```

I use it for `index.html`, `archive.html` and `posts/*`.

If you have hardcoded links in your html or template, you need to fix them. I
have to do it for `templates/default.html`.

I use [Disqus](http://disqus.com) for comments. And Disqus
[recommends](https://help.disqus.com/customer/en/portal/articles/2158629) to
explicitly set `url` and `identifier` variables. I used `$url$` variable in
Hakyll templates before, but now it contains urls with `index.html` suffix. So I
need to fix it too. I introduce a new context variable:

``` haskell
myUrlField :: Context a
myUrlField = field "myurl" $
    fmap (maybe empty $ removeIndexStr . toUrl) . getRoute . itemIdentifier
```

It is implemented similar to default url field, but uses `removeIndexStr` to
trim `index.html`.

I add this field to posts' context:
``` haskell
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    myUrlField `mappend`
    defaultContext
```
And this is a part of Disqus script:

``` javascript
var disqus_config = function () {
    this.page.url = 'http://alexanderlobov.ru$myurl$';
    this.page.identifier = '$myurl$';
};
```
