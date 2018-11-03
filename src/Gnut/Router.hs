module Gnut.Router
    ( setupRouterNetwork
    , pureModuleStore
    )
    where

import Prelude hiding (lookup)

import Control.Monad

import Reactive.Banana
import Reactive.Banana.Frameworks

import Network.Xmpp.Internal

import Gnut.Types
import Gnut.Module
import Gnut.Permissions

setupRouterNetwork :: AddHandler Stanza -> Handler Stanza -> ModuleStore -> IO EventNetwork
setupRouterNetwork esin hout bplugins = compile $ do
    -- Stanzas the XMPP module has forwarded to us specifically
    ein <- fromAddHandler esin

    -- TODO Figure this valueB out like in Xmpp.hs
    plugins <- valueB bplugins
    let
        ea = fmap (\s -> (getPlugins plugins s, s)) ein
        ea :: Event ([ModuleHandler], Stanza)
        eb = fmap (\(m, s) -> (m, (s, hout))) ea
        eb :: Event ([ModuleHandler], (Stanza, ReplyCallback))
        ec = fmap (\(m, x) -> map (\f -> f x) m) eb
        ec :: Event ([IO ()])
        eend = fmap msum ec
        eend :: Event (IO ())

    reactimate eend

getPlugins :: [(ModuleFilter, ModuleHandler)] -> Stanza -> [ModuleHandler]
getPlugins p s = map snd $ filter (\(f,h) -> f s) p

pureModuleStore :: ModuleStore
pureModuleStore = pure [(pure True, (print <$> fst))]
