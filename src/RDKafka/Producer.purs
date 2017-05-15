module RDKafka.Producer where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Exception (EXCEPTION, Error)
import Data.Either (Either, either)
import Data.Foreign (Foreign, toForeign)
import Data.Functor.Contravariant ((>#<))
import Data.Maybe (Maybe, maybe)
import Data.Options (Option, Options, opt, options)
import Data.String (joinWith)
import Node.Buffer (Buffer)
import RDKafka (RDKAFKA)

foreign import data Producer :: # Effect -> Type

-- | Phantom data type for kafka producer options
data ProducerOptions

foreign import producerF :: ∀ ε. Foreign -> Int -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> Aff (rdkafka :: RDKAFKA | ε) (Producer (rdkafka :: RDKAFKA | ε))

producer :: ∀ ε. Options ProducerOptions
         -> Int
         -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit)
         -> Aff (rdkafka :: RDKAFKA | ε) (Producer (rdkafka :: RDKAFKA | ε))
producer = producerF <<< options

foreign import fNull :: Foreign

orNull :: ∀ a. Maybe a -> Foreign
orNull = maybe fNull toForeign

foreign import produceF :: ∀ ε. Producer (exception :: EXCEPTION, rdkafka :: RDKAFKA | ε)
                        -> String
                        -> Foreign
                        -> Buffer
                        -> Foreign
                        -> Eff (exception :: EXCEPTION, rdkafka :: RDKAFKA | ε) Unit

produce :: ∀ ε. Producer (exception :: EXCEPTION, rdkafka :: RDKAFKA | ε)
        -> String
        -> Maybe Int
        -> Buffer
        -> Maybe String
        -> Eff (exception :: EXCEPTION, rdkafka :: RDKAFKA | ε) Unit
produce p topic partition value key =
    produceF p topic (orNull partition) value (orNull key)
