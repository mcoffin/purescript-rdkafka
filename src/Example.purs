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
import RDKafka.Consumer ( consumer
                        , consumeBatch
                        , Message(..)
                        )
import RDKafka.Options ( KafkaOptions
                       , bootstrapServers
                       )

showValue :: Either String Buffer -> String
showValue (Left s) = s
showValue (Right b) = unsafePerformEffect $ B.toString Encoding.UTF8 b

main :: Effect Unit
main = do
    log "Starting..."
    launchAff_ do
        c <- consumer throwException (bootstrapServers := ["localhost:9092"]) mempty ["messages"]
        messages <- consumeBatch 5 c
        liftEffect (fold $ log <$> showValue <$> (\(Message m) -> m.value) <$> messages)
