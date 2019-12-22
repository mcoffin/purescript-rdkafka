module RDKafka.Consumer
    ( Consumer
    , Message(..)
    , consumer
    , consumeBatch
    , consumeStream
    ) where

import Prelude
import Control.Alt ((<|>))
import Control.Monad.Except (runExcept)
import Control.Promise ( Promise
                       , toAffE
                       , fromAff
                       )
import Data.Either (Either(..))
import Data.Function.Uncurried ( Fn2
                               , Fn4
                               , runFn2
                               , runFn4
                               )
import Data.Maybe (Maybe(..))
import Data.Options ( Options
                    , options
                    )
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception (Error)
import Foreign ( Foreign
               , F
               , ForeignError(..)
               , unsafeFromForeign
               , fail
               , tagOf
               )
import Foreign.Class ( class Decode
                     , decode
                     )
import Foreign.Index (readProp)
import Node.Buffer (Buffer)
import RDKafka.Options ( KafkaOptions
                       , TopicOptions
                       )
import RDKafka.Util ( readPropMaybe
                    , valueOrThrowByShow
                    )

foreign import data Consumer :: Type

foreign import isBuffer :: ∀ a. a -> Boolean
foreign import consumerImpl :: ∀ a. Fn4 (Error -> Effect a) Foreign Foreign (Array String) (Effect (Promise Consumer))
foreign import consumeBatchImpl :: Fn2 Int Consumer (Effect (Promise (Array Foreign)))
foreign import consumeStreamImpl :: ∀ a. Fn2 (Message -> Effect (Promise a)) Consumer (Effect Unit)

newtype Message = Message { value :: Either String Buffer
                          , size :: Int
                          , topic :: String
                          , offset :: Int
                          , partition :: Int
                          , key :: Maybe (Either String Buffer)
                          , timestamp :: Maybe Int
                          }

decodeBuffer :: Foreign -> F Buffer
decodeBuffer v
  | isBuffer v = pure $ unsafeFromForeign v
  | otherwise = fail $ TypeMismatch "Buffer" (tagOf v)

decodeValue :: Foreign -> F (Either String Buffer)
decodeValue v = (Left <$> decode v) <|> (Right <$> decodeBuffer v)

instance decodeMessage :: Decode Message where
    decode v = do
        value <- readProp "value" v >>= decodeValue
        size <- readProp "size" v >>= decode
        topic <- readProp "topic" v >>= decode
        offset <- readProp "offset" v >>= decode
        partition <- readProp "partition" v >>= decode
        key <- readPropMaybe "key" v >>= traverse decodeValue
        timestamp <- readPropMaybe "key" v >>= traverse decode
        pure $ Message { value: value
                       , size: size
                       , topic: topic
                       , offset: offset
                       , partition: partition
                       , key: key
                       , timestamp: timestamp
                       }

consumer :: ∀ a. (Error -> Effect a) -> Options KafkaOptions ->  Options TopicOptions -> Array String -> Aff Consumer
consumer handleError kafkaOptions topicOptions =
    map toAffE $ runFn4 consumerImpl handleError (options kafkaOptions) (options topicOptions)

consumeBatch :: Int -> Consumer -> Aff (Array Message)
consumeBatch batchSize = (toAffE <$> runFn2 consumeBatchImpl batchSize) >=> \results ->
    let messages = traverse decode results in
        valueOrThrowByShow $ runExcept messages

consumeStream :: ∀ a. (Message -> Aff a) -> Consumer -> Effect Unit
consumeStream handleMessage = runFn2 consumeStreamImpl $ fromAff <$> handleMessage
