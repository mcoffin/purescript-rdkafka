module RDKafka.Producer
    ( Producer
    , produce
    , producer
    , flush
    , disconnect
    , toClient
    ) where

import Prelude
import Control.Promise ( Promise
                       , toAffE
                       )
import Data.Function.Uncurried ( Fn2
                               , Fn5
                               , runFn2
                               , runFn5
                               )
import Data.Maybe ( Maybe
                  , fromMaybe
                  , maybe
                  )
import Data.Options ( Options
                    , options
                    )
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception (Error)
import Foreign ( Foreign
               , unsafeToForeign
               )
import Node.Buffer (Buffer)
import RDKafka.Client (RDKafkaClient)
import RDKafka.Options (KafkaOptions)
import Unsafe.Coerce (unsafeCoerce)

foreign import data Producer :: Type

foreign import foreignNull :: Foreign
foreign import producerImpl :: ∀ a. Fn2 (Error -> Effect a) Foreign (Effect (Promise Producer))
foreign import produceImpl :: Fn5 String Int Foreign Foreign Producer (Effect Unit)
foreign import flushImpl :: Fn2 Int Producer (Effect (Promise Unit))
foreign import disconnectImpl :: Fn2 Int Producer (Effect (Promise Unit))

-- | Creates a kafka producer with an error callback and options
producer :: ∀ a. (Error -> Effect a) -> Options KafkaOptions -> Aff Producer
producer handleError = toAffE <$> runFn2 producerImpl handleError <$> options

-- | Queue a single message for production
produce :: Tuple String (Maybe Int) -> Tuple (Maybe Buffer) Buffer -> Producer -> Effect Unit
produce (Tuple topic maybePartition) (Tuple maybeKey value) =
    runFn5 produceImpl topic partition key (unsafeToForeign value) where
        partition :: Int
        partition = fromMaybe (-1) maybePartition
        key :: Foreign
        key = maybe foreignNull unsafeToForeign maybeKey

-- | flush all messages queued on the given producer
flush :: Int -> Producer -> Aff Unit
flush = map toAffE <$> runFn2 flushImpl

-- | Disconnect a given `Producer`. You *must* call this or your program will stay alive
-- | as the producer's handlers are still waiting for more events
disconnect :: Int -> Producer -> Aff Unit
disconnect = map toAffE <$> runFn2 disconnectImpl

toClient :: Producer -> RDKafkaClient
toClient = unsafeCoerce
