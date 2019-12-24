module Example
    ( main
    ) where

import Prelude
import Data.Either (Either(..))
import Data.Foldable (fold)
import Data.Options ((:=))
import Effect (Effect)
import Effect.Aff ( Aff
                  , launchAff_
                  )
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (throwException)
import Effect.Unsafe (unsafePerformEffect)
import Node.Buffer (Buffer)
import Node.Buffer as B
import Node.Encoding as Encoding
import RDKafka (Offset(..))
import RDKafka.Client (queryWatermarkOffsets)
import RDKafka.Consumer ( consumer
                        , consumeBatch
                        , Message(..)
                        , toClient
                        )
import RDKafka.Options ( KafkaOptions
                       , autoOffsetReset
                       , enableAutoCommit
                       , bootstrapServers
                       , metadataBrokerList
                       , groupId
                       )

showValue :: Either String Buffer -> String
showValue (Left s) = s
showValue (Right b) = unsafePerformEffect $ B.toString Encoding.UTF8 b

main :: Effect Unit
main = do
    log "Starting..."
    launchAff_ do
        c <- consumer throwException (metadataBrokerList := ["localhost:9092"] <> groupId := "purescript-rdkafka-example" <> enableAutoCommit := false) (autoOffsetReset := OffsetBeginning) ["messages"]
        let cc = toClient c
        watermarks <- queryWatermarkOffsets "messages" 0 10000 cc
        liftEffect <$> log $ "(" <> show watermarks.lowOffset <> " -> " <> show watermarks.highOffset <> ")"
        messages <- consumeBatch 5 c
        liftEffect (fold $ log <$> showValue <$> (\(Message m) -> m.value) <$> messages)
