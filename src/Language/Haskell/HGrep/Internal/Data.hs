{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
module Language.Haskell.HGrep.Internal.Data (
    ParsedSource (..)
  , ParseError (..)
  , Query (..)
  , Regex (..)
  , compileRegex
  , SearchResult (..)
  , PrintOpts (..)
  , defaultPrintOpts
  , ColourOpts (..)
  ) where


import qualified Data.ByteString.Char8 as B8

import           Language.Haskell.HGrep.Prelude

import qualified Language.Haskell.GHC.ExactPrint.Annotater as EA
import qualified Language.Haskell.GHC.ExactPrint.Types as ET

import qualified Text.Regex.PCRE.Heavy as PCRE

import qualified GHC
import qualified SrcLoc


newtype ParsedSource = ParsedSource {
    unParsedSource :: (ET.Anns, GHC.Located (GHC.HsModule GHC.RdrName))
  }

newtype ParseError = ParseError {
    unParseError :: (SrcLoc.SrcSpan, [Char])
  }

data Query =
    MatchSimple [Char]
  | MatchRegex Regex
  deriving (Eq, Ord, Show)

newtype Regex = Regex {
    unRegex :: PCRE.Regex
  } deriving (Eq, Ord, Show)

compileRegex :: [Char] -> Either [Char] Regex
compileRegex str =
  fmap Regex (PCRE.compileM (B8.pack str) [])

data SearchResult =
  forall ast. EA.Annotate ast =>
    SearchResult ET.Anns (SrcLoc.Located ast)

data PrintOpts = PrintOpts {
    poColourOpts :: ColourOpts
  } deriving (Eq, Ord, Show)

data ColourOpts =
    DefaultColours
  | NoColours
  deriving (Eq, Ord, Show)

defaultPrintOpts :: PrintOpts
defaultPrintOpts =
  PrintOpts {
      poColourOpts = DefaultColours
    }
