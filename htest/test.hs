{-| Unittest runner for ganeti-htools.

-}

{-

Copyright (C) 2009, 2011, 2012 Google Inc.

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

module Main(main) where

import Data.Monoid (mappend)
import Test.Framework
import System.Environment (getArgs)

import Test.Ganeti.TestImports ()
import Test.Ganeti.BasicTypes
import Test.Ganeti.Confd.Utils
import Test.Ganeti.HTools.CLI
import Test.Ganeti.HTools.Cluster
import Test.Ganeti.HTools.Container
import Test.Ganeti.HTools.Loader
import Test.Ganeti.HTools.Instance
import Test.Ganeti.HTools.Node
import Test.Ganeti.HTools.PeerMap
import Test.Ganeti.HTools.Simu
import Test.Ganeti.HTools.Text
import Test.Ganeti.HTools.Types
import Test.Ganeti.HTools.Utils
import Test.Ganeti.Jobs
import Test.Ganeti.JSON
import Test.Ganeti.Luxi
import Test.Ganeti.Objects
import Test.Ganeti.OpCodes
import Test.Ganeti.Query.Language
import Test.Ganeti.Rpc
import Test.Ganeti.Ssconf

-- | Our default test options, overring the built-in test-framework
-- ones.
fast :: TestOptions
fast = TestOptions
       { topt_seed                               = Nothing
       , topt_maximum_generated_tests            = Just 500
       , topt_maximum_unsuitable_generated_tests = Just 5000
       , topt_maximum_test_size                  = Nothing
       , topt_maximum_test_depth                 = Nothing
       , topt_timeout                            = Nothing
       }

-- | Our slow test options.
slow :: TestOptions
slow = fast
       { topt_maximum_generated_tests            = Just 50
       , topt_maximum_unsuitable_generated_tests = Just 500
       }

-- | All our defined tests.
allTests :: [(Bool, (String, [Test]))]
allTests =
  [ (True, testBasicTypes)
  , (True, testConfd_Utils)
  , (True, testHTools_CLI)
  , (True, testHTools_Container)
  , (True, testHTools_Instance)
  , (True, testHTools_Loader)
  , (True, testHTools_Node)
  , (True, testHTools_PeerMap)
  , (True, testHTools_Simu)
  , (True, testHTools_Text)
  , (True, testHTools_Types)
  , (True, testHTools_Utils)
  , (True, testJSON)
  , (True, testJobs)
  , (True, testLuxi)
  , (True, testObjects)
  , (True, testOpCodes)
  , (True, testQuery_Language)
  , (True, testRpc)
  , (True, testSsconf)
  , (False, testHTools_Cluster)
  , (False, testSlowObjects)
  ]

-- | Slow a test's max tests, if provided as such.
makeSlowOrFast :: Bool -> TestOptions -> TestOptions
makeSlowOrFast is_fast opts =
  let template = if is_fast then fast else slow
      fn_val v = if is_fast then v else v `div` 10
  in case topt_maximum_generated_tests opts of
       -- user didn't override the max_tests, so we'll do it here
       Nothing -> opts `mappend` template
       -- user did override, so we ignore the template and just directly
       -- decrease the max_tests, if needed
       Just max_tests -> opts { topt_maximum_generated_tests =
                                  Just (fn_val max_tests)
                              }

-- | Main function. Note we don't use defaultMain since we want to
-- control explicitly our test sizes (and override the default).
main :: IO ()
main = do
  ropts <- getArgs >>= interpretArgsOrExit
  -- note: we do this overriding here since we need some groups to
  -- have a smaller test count; so in effect we're basically
  -- overriding t-f's inheritance here, but only for max_tests
  let (act_fast, act_slow) =
       case ropt_test_options ropts of
         Nothing -> (fast, slow)
         Just topts -> (makeSlowOrFast True topts, makeSlowOrFast False topts)
      actual_opts is_fast = if is_fast then act_fast else act_slow
  let tests = map (\(is_fast, (group_name, group_tests)) ->
                     plusTestOptions (actual_opts is_fast) $
                     testGroup group_name group_tests) allTests
  defaultMainWithOpts tests ropts