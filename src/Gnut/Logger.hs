module Gnut.Logger
    ( Logger
    , makeLogger
    ) where

import           Control.Applicative        ((<$>))
import           Control.Concurrent.MVar    (newMVar, putMVar, takeMVar)
import           Data.Text                  (Text)
import qualified Data.Text.IO               as T
import           Data.Time.Clock            (getCurrentTime)
import           Data.Time.Format           (defaultTimeLocale, formatTime)
import qualified System.IO                  as IO

type Logger = Text -> IO ()

makeLogger :: FilePath -> IO Logger
makeLogger path = do
    h <- IO.openFile path IO.AppendMode
    lock <- newMVar ()
    return $ \line -> line `seq` do
        () <- takeMVar lock
        time <- formatTime defaultTimeLocale "%c " <$> getCurrentTime
        IO.hPutStr h time
        T.hPutStr h line
        IO.hFlush h
        putMVar lock ()
