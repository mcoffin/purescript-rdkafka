module RDKafka.Client
    ( RDKafkaClient
    , queryWatermarkOffsets
    ) where

import Prelude
import Control.Promise ( Promise
                       , toAffE
                       )
import Data.Function.Uncurried ( Fn4
                               , runFn4
                               )
import Effect (Effect)
import Effect.Aff (Aff)

foreign import data RDKafkaClient :: Type

type PartitionWatermarks = { highOffset :: Int
                           , lowOffset :: Int
                           }

foreign import queryWatermarkOffsetsImpl :: Fn4 String Int Int RDKafkaClient (Effect (Promise PartitionWatermarks))

queryWatermarkOffsets :: String -> Int -> Int -> RDKafkaClient -> Aff PartitionWatermarks
queryWatermarkOffsets topic partition timeout client =
    toAffE $ runFn4 queryWatermarkOffsetsImpl topic partition timeout client
