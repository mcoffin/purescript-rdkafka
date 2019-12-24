module RDKafka.Options
    ( KafkaOptions
    , TopicOptions
    , SASLMechanism(..)
    , autoOffsetReset
    , enableAutoCommit
    , metadataBrokerList
    , bootstrapServers , securityProtocol
    , saslMechanism
    , saslUsername
    , saslPassword
    , groupId
    ) where

import Prelude
import Data.Options ( Option
                    , opt
                    , tag
                    )
import Data.Functor.Contravariant ((>$<))
import Data.String.Common (joinWith)
import RDKafka (Offset(..))

-- | Phantom data type for kafka options
data KafkaOptions

-- | Phantom data type for topic options
data TopicOptions

-- | Enum data type for sasl.mechanism
data SASLMechanism = Plain
                   | GssApi

metadataBrokerList :: Option KafkaOptions (Array String)
metadataBrokerList = joinWith "," >$< opt "metadata.broker.list"

bootstrapServers :: Option KafkaOptions (Array String)
bootstrapServers = joinWith "," >$< opt "bootstrap.servers"

securityProtocol :: Option KafkaOptions String
securityProtocol = opt "security.protocol"

saslMechanism :: Option KafkaOptions SASLMechanism
saslMechanism = mechanismToString >$< opt "sasl.mechanism" where
    mechanismToString :: SASLMechanism -> String
    mechanismToString Plain = "PLAIN"
    mechanismToString GssApi = "GSSAPI"

saslUsername :: Option KafkaOptions String
saslUsername = opt "sasl.username"

saslPassword :: Option KafkaOptions String
saslPassword = opt "sasl.password"

groupId :: Option KafkaOptions String
groupId = opt "group.id"

enableAutoCommit :: Option KafkaOptions Boolean
enableAutoCommit = opt "enable.auto.commit"

socketKeepAliveEnable :: Option KafkaOptions Boolean
socketKeepAliveEnable = opt "socket.keepalive.enable"

socketKeepAliveDisable :: Option KafkaOptions Unit
socketKeepAliveDisable = opt "socket.keepalive.enable" `tag` false

autoOffsetReset :: Option TopicOptions Offset
autoOffsetReset = offsetToString >$< opt "auto.offset.reset" where
    offsetToString :: Offset -> String
    offsetToString OffsetBeginning = "beginning"
    offsetToString OffsetEnd = "end"
    offsetToString OffsetError = "error"
