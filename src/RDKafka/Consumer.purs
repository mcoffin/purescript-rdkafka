module RDKafka.Consumer where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Either (Either, either)
import Data.Foreign (Foreign, toForeign)
import Data.Functor.Contravariant ((>#<))
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Options (Option, Options, options, opt)
import Data.String (joinWith)
import Node.Buffer (Buffer)
import RDKafka (RDKAFKA)

newtype Message = Message
    { value :: Buffer
    , size :: Int
    , topic :: String
    , offset :: Int
    , partition :: Int
    , key :: String
    }

derive instance genericMessage :: Generic Message _

instance showMessage :: Show Message where
    show = genericShow

-- | Phantom data type for kafka consumer options
data ConsumerOptions

data ConsumerMode = FlowingConsumer
                  | NonFlowingConsumer Int Int

foreign import data Consumer :: Type

type ConsumeFunction ε = Foreign -> Array String -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> (Message -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> (Consumer -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> Eff (rdkafka :: RDKAFKA | ε) Unit

foreign import consumeFlowing :: ∀ ε. ConsumeFunction ε

foreign import consumeNonFlowing :: ∀ ε. Int -> Int -> ConsumeFunction ε

consume :: ∀ ε. ConsumerMode
        -> Options ConsumerOptions
        -> Array String
        -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit)
        -> (Message -> Eff (rdkafka :: RDKAFKA | ε) Unit)
        -> Aff (rdkafka :: RDKAFKA | ε) Consumer
consume mode consumerOptions topics onError onData = makeAff $ consumeF opts topics onError onData where
    opts = options consumerOptions
    consumeF = case mode of
                 FlowingConsumer -> consumeFlowing
                 NonFlowingConsumer interval count -> consumeNonFlowing interval count

groupId :: Option ConsumerOptions String
groupId = opt "group.id"

bootstrapServers :: Option ConsumerOptions (Either String (Array String))
bootstrapServers = opt "bootstrap.servers" >#< either toForeign (toForeign <<< joinWith ",")
