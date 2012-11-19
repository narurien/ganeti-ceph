{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

{-| Unittests for 'Ganeti.Types'.

-}

{-

Copyright (C) 2012 Google Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.

-}

module Test.Ganeti.Types
  ( testTypes
  , AllocPolicy(..)
  , DiskTemplate(..)
  , InstanceStatus(..)
  ) where

import Test.QuickCheck

import Test.Ganeti.TestHelper
import Test.Ganeti.TestCommon

import Ganeti.Types

-- * Arbitrary instance

$(genArbitrary ''AllocPolicy)

$(genArbitrary ''DiskTemplate)

$(genArbitrary ''InstanceStatus)

prop_AllocPolicy_serialisation :: AllocPolicy -> Property
prop_AllocPolicy_serialisation = testSerialisation

prop_DiskTemplate_serialisation :: DiskTemplate -> Property
prop_DiskTemplate_serialisation = testSerialisation

prop_InstanceStatus_serialisation :: InstanceStatus -> Property
prop_InstanceStatus_serialisation = testSerialisation

testSuite "Types"
  [ 'prop_AllocPolicy_serialisation
  , 'prop_DiskTemplate_serialisation
  , 'prop_InstanceStatus_serialisation
  ]