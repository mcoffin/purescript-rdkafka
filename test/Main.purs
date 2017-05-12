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

main = logShow "You should add some tests"
