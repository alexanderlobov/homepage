--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import System.FilePath.Posix ( takeDirectory
                             , takeBaseName
                             , (</>)
                             , splitFileName
                             )
import Data.List (isInfixOf)
import Control.Applicative (empty)


config :: Configuration
config = defaultConfiguration
    { deployCommand = "./deploy"
    }

--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "posts/*" $ do
        route niceRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls
            >>= removeIndexHtml

    match "archive.html" $ do
        route niceRoute
        compile makeIndex

    match "index.html" $ do
        route idRoute
        compile makeIndex

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    myUrlField `mappend`
    defaultContext

myUrlField :: Context a
myUrlField = field "myurl" $
    fmap (maybe empty $ removeIndexStr . toUrl) . getRoute . itemIdentifier

niceRoute :: Routes
niceRoute = customRoute createIndexRoute
    where createIndexRoute identifier =
            takeDirectory p </> takeBaseName p </> "index.html"
            where p = toFilePath identifier

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

makeIndex :: Compiler (Item String)
makeIndex = do
    posts <- recentFirst =<< loadAll "posts/*"
    let indexCtx =
            listField "posts" postCtx (return posts) `mappend`
            defaultContext

    getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls
        >>= removeIndexHtml
