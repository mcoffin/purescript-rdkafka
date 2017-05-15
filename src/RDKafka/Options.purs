module RDKafka.Options where

import Prelude
import Data.Either (Either, either)
import Data.Foreign (toForeign)
import Data.Functor.Contravariant ((>#<))
import Data.Options (Option, opt)
import Data.String as S
import RDKafka.Consumer (ConsumerOptions)

groupId :: Option ConsumerOptions String
groupId = opt "group.id"

bootstrapServers :: ∀ o. Option o (Either String (Array String))
bootstrapServers = opt "bootstrap.servers" >#< either toForeign (toForeign <<< S.joinWith ",")
