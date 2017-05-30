module RDKafka.Consumer where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Except (runExcept)
import Data.Either (fromRight)
import Data.Foreign (Foreign, unsafeFromForeign)
import Data.Foreign.Index (readProp)
import Data.Foreign.Class (class Decode, decode)
import Data.Foreign.NullOrUndefined (unNullOrUndefined)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Data.Options (Options, options)
import Node.Buffer (Buffer)
import Partial.Unsafe (unsafePartial)
import RDKafka (RDKAFKA)

newtype Message = Message
    { value :: Buffer
    , size :: Int
    , topic :: String
    , offset :: Int
    , partition :: Int
    , key :: Maybe String
    }

derive instance newtypeMessage :: Newtype Message _

derive instance genericMessage :: Generic Message _

instance showMessage :: Show Message where
    show = genericShow

instance decodeMessage :: Decode Message where
    decode obj = do
        value <- unsafeFromForeign <$> readProp "value" obj
        size <- readProp "size" obj >>= decode
        topic <- readProp "topic" obj >>= decode
        offset <- readProp "offset" obj >>= decode
        partition <- readProp "partition" obj >>= decode
        key <- map unNullOrUndefined $ readProp "key" obj >>= decode
        pure $ Message
            { value: value
            , size: size
            , topic: topic
            , offset: offset
            , partition: partition
            , key: key
            }

-- | Phantom data type for kafka consumer options
data ConsumerOptions

-- | Phantom data type for streaming consumer options
data StreamingOptions

data ConsumerMode = FlowingConsumer
                  | StreamingConsumer (Options StreamingOptions)
                  | NonFlowingConsumer Int Int

foreign import data Consumer :: Type

type ConsumeFunction ε msg = Foreign -> Array String -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> (msg -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> (Consumer -> Eff (rdkafka :: RDKAFKA | ε) Unit) -> Eff (rdkafka :: RDKAFKA | ε) Unit

foreign import consumeFlowing :: ∀ ε. ConsumeFunction ε Foreign

foreign import consumeStreaming :: ∀ ε. Foreign -> ConsumeFunction ε Foreign

foreign import consumeNonFlowing :: ∀ ε. Int -> Int -> ConsumeFunction ε Foreign

consume :: ∀ ε. ConsumerMode
        -> Options ConsumerOptions
        -> Array String
        -> (Error -> Eff (rdkafka :: RDKAFKA | ε) Unit)
        -> (Message -> Eff (rdkafka :: RDKAFKA | ε) Unit)
        -> Aff (rdkafka :: RDKAFKA | ε) Consumer
consume mode consumerOptions topics onError onData = makeAff $ consumeF opts topics onError onDataF where
    onDataF = decode >>> runExcept >>> unsafePartial fromRight >>> onData
    opts = options consumerOptions
    consumeF = case mode of
                 FlowingConsumer -> consumeFlowing
                 StreamingConsumer streamingOptions -> consumeStreaming $ options streamingOptions
                 NonFlowingConsumer interval count -> consumeNonFlowing interval count
