module RDKafka
    ( Offset(..)
    ) where

import Prelude

data Offset = OffsetBeginning
            | OffsetEnd
            | OffsetError
