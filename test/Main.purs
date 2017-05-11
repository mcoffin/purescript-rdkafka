module Test.Main where

import Prelude
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import Control.Monad.Eff.Exception (EXCEPTION, Error, throwException)
import Data.Either (Either(..))
import Data.Foldable (fold)
import Data.Foreign (Foreign, toForeign)
import Data.Monoid (mempty)
import Data.Options (Options, (:=))
import RDKafka.Consumer

foreign import jsonStringify :: Foreign -> String

opts :: Options ConsumerOptions
opts = fold [ groupId := "test-consumer"
            , bootstrapServers := Right ["localhost:9092"]
            ]

mode :: ConsumerMode
mode = StreamingConsumer mempty

main = launchAff do
    consume mode opts ["test"] throwException logShow
