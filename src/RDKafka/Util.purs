module RDKafka.Util
    ( readPropMaybe
    , valueOrError
    , valueOrThrowByShow
    ) where

import Prelude
import Control.Monad.Error.Class ( class MonadError
                                 , throwError
                                 )
import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Effect.Exception ( Error
                        , error
                        )
import Foreign ( F
               , Foreign
               )
import Foreign.Generic (decode)
import Foreign.Object (lookup)

readPropMaybe :: String -> Foreign -> F (Maybe Foreign)
readPropMaybe k = map (lookup k) <$> decode

valueOrError :: ∀ m e a. MonadError e m => Either e a -> m a
valueOrError (Left e) = throwError e
valueOrError (Right v) = pure v

valueOrThrowByShow :: ∀ m e a. MonadError Error m => Show e => Either e a -> m a
valueOrThrowByShow (Left e) = throwError <$> error $ show e
valueOrThrowByShow (Right v) = pure v
