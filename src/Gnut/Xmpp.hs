module Gnut.Xmpp
    ( Message(..)
    , sendMessage

    , Session(..)

    , Jid(..)
    , parseJid
    , jidFromText

    , Presence(..)
    , PresenceType(..)
    , sendPresence

    , InstantMessage(..)
    , MessageBody(..)
    , simpleIM
    , getIM

    , getMessage

    , setupSession
    )
    where

import Gnut.Config

import Control.Lens
import Control.Monad
import Control.Monad.IO.Class

import Data.Default

import qualified Data.Text as T

import Network.Xmpp
import Network.Xmpp.IM
import Network.Xmpp.Internal (TlsBehaviour(..))

setupSession :: Config -> IO Session
setupSession c = do
    result <- session (T.unpack $ c^.connection.domain) (Just (const [plain (c^.connection.user) Nothing (c^.connection.password)], Nothing)) $ def
        & streamConfigurationL .  tlsBehaviourL .~ RequireTls
        & onConnectionClosedL .~ reconnectSession
    sess <- case result of
            Right s -> return s
            Left e -> liftIO $ error $ "XMPP Failure: " ++ show e
    sendPresence presenceOnline sess
    return sess
  where
    reconnectSession sess failure = void (reconnect' sess)
