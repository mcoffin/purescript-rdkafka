module RDKafka.Util
    ( readPropMaybe
    , valueOrError
    , valueOrThrowByShow
    , filterMaybe
    ) where

import Prelude
import Control.Monad.Error.Class ( class MonadError
                                 , throwError
                                 )
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Exception ( Error
                        , error
                        )
import Foreign ( F
               , Foreign
               , isNull
               , isUndefined
               )
import Foreign.Generic (decode)
import Foreign.Object (lookup)

filterMaybe :: ∀ a. (a -> Boolean) -> Maybe a -> Maybe a
filterMaybe filterFn (Just v)
  | filterFn v = Just v
  | otherwise = Nothing
filterMaybe _ Nothing = Nothing

readPropMaybe :: String -> Foreign -> F (Maybe Foreign)
readPropMaybe k = map (lookup k >=> filterMaybe (\v -> not isNull v && not isUndefined v)) <$> decode

valueOrError :: ∀ m e a. MonadError e m => Either e a -> m a
valueOrError (Left e) = throwError e
valueOrError (Right v) = pure v

valueOrThrowByShow :: ∀ m e a. MonadError Error m => Show e => Either e a -> m a
valueOrThrowByShow (Left e) = throwError <$> error $ show e
valueOrThrowByShow (Right v) = pure v
