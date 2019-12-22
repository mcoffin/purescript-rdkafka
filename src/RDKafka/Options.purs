module RDKafka.Options
    ( KafkaOptions
    , TopicOptions
    , autoOffsetReset
    , enableAutoCommit
    , metadataBrokerList
    , bootstrapServers
    , securityProtocol
    , saslMechanism
    , saslUsername
    , saslPassword
    , groupId
    ) where

import Data.Options ( Option
                    , opt
                    )
import Data.Functor.Contravariant ((>$<))
import Data.String.Common (joinWith)
import RDKafka (Offset(..))

-- | Phantom data type for kafka options
data KafkaOptions

-- | Phantom data type for topic options
data TopicOptions

metadataBrokerList :: Option KafkaOptions (Array String)
metadataBrokerList = joinWith "," >$< opt "metadata.broker.list"

bootstrapServers :: Option KafkaOptions (Array String)
bootstrapServers = joinWith "," >$< opt "bootstrap.servers"

securityProtocol :: Option KafkaOptions String
securityProtocol = opt "security.protocol"

saslMechanism :: Option KafkaOptions String
saslMechanism = opt "sasl.mechanism"

saslUsername :: Option KafkaOptions String
saslUsername = opt "sasl.username"

saslPassword :: Option KafkaOptions String
saslPassword = opt "sasl.password"

groupId :: Option KafkaOptions String
groupId = opt "group.id"

enableAutoCommit :: Option KafkaOptions Boolean
enableAutoCommit = opt "enable.auto.commit"

autoOffsetReset :: Option TopicOptions Offset
autoOffsetReset = offsetToString >$< opt "auto.offset.reset" where
    offsetToString :: Offset -> String
    offsetToString OffsetBeginning = "beginning"
    offsetToString OffsetEnd = "end"
    offsetToString OffsetError = "error"
