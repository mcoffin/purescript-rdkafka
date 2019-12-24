module RDKafka.Client
    ( RDKafkaClient
    , BrokerMetadata(..)
    , PartitionMetadata(..)
    , TopicMetadata(..)
    , Metadata(..)
    , getMetadata
    , queryWatermarkOffsets
    ) where

import Prelude
import Control.Monad.Error.Class ( class MonadError
                                 , throwError
                                 )
import Control.Monad.Except (runExcept)
import Control.Promise ( Promise
                       , toAffE
                       )
import Data.Either (Either(..))
import Data.Function.Uncurried ( Fn3
                               , Fn4
                               , runFn3
                               , runFn4
                               )
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception ( Error
                        , error
                        )
import Foreign ( F
               , Foreign
               )
import Foreign.Generic ( class Decode
                       , decode
                       )
import Foreign.Index (readProp)

foreign import data RDKafkaClient :: Type

type PartitionWatermarks = { highOffset :: Int
                           , lowOffset :: Int
                           }

foreign import queryWatermarkOffsetsImpl :: Fn4 String Int Int RDKafkaClient (Effect (Promise PartitionWatermarks))

queryWatermarkOffsets :: String -> Int -> Int -> RDKafkaClient -> Aff PartitionWatermarks
queryWatermarkOffsets topic partition timeout client =
    toAffE $ runFn4 queryWatermarkOffsetsImpl topic partition timeout client

readProp' :: ∀ a. (Decode a) => String -> Foreign -> F a
readProp' k = readProp k >=> decode

newtype BrokerMetadata =
    BrokerMetadata { id :: Int
                   , host :: String
                   , port :: Int
                   }

instance decodeBrokerMetadata :: Decode BrokerMetadata where
    decode v = do
        id <- readProp' "id" v
        host <- readProp' "host" v
        port <- readProp' "port" v
        pure $ BrokerMetadata { id: id
                              , host: host
                              , port: port
                              }

newtype PartitionMetadata =
    PartitionMetadata { id :: Int
                      , leader :: Int
                      , replicas :: Array Int
                      , isrs :: Array Int
                      }

instance decodePartitionMetadata :: Decode PartitionMetadata where
    decode v = do
        id <- readProp' "id" v
        leader <- readProp' "leader" v
        replicas <- readProp' "replicas" v
        isrs <- readProp' "isrs" v
        pure $ PartitionMetadata { id: id
                                 , leader: leader
                                 , replicas: replicas
                                 , isrs: isrs
                                 }

data TopicMetadata =
    TopicMetadata String (Array PartitionMetadata)

instance decodeTopicMetadata :: Decode TopicMetadata where
    decode v = do
        name <- readProp "name" v >>= decode
        partitions <- readProp "partitions" v >>= decode
        pure $ TopicMetadata name partitions

newtype Metadata =
    Metadata { originalBrokerId :: Int
             , originalBrokerName :: String
             , brokers :: Array BrokerMetadata
             , topics :: Array TopicMetadata
             }

instance decodeMetadata :: Decode Metadata where
    decode v = do
        origId <- readProp' "orig_broker_id" v
        origName <- readProp' "orig_broker_name" v
        brokers <- readProp' "brokers" v
        topics <- readProp' "topics" v
        pure $ Metadata { originalBrokerId: origId
                        , originalBrokerName: origName
                        , brokers: brokers
                        , topics: topics
                        }

foreign import getMetadataImpl :: Fn3 String Int RDKafkaClient (Effect (Promise Foreign))

valueOrThrowByShow :: ∀ m e a. MonadError Error m
                   => Show e
                   => Either e a
                   -> m a
valueOrThrowByShow (Left e) = throwError <$> error $ show e
valueOrThrowByShow (Right v) = pure v

getMetadata :: String -> Int -> RDKafkaClient -> Aff Metadata
getMetadata topic timeout =
    getMetadataImpl' topic timeout >=> (valueOrThrowByShow <$> runExcept <$> decode) where
        getMetadataImpl' = map (map toAffE) <$> runFn3 getMetadataImpl

