module RDKafka where

import Prelude
import Control.Monad.Eff (kind Effect)

foreign import data RDKAFKA :: Effect
