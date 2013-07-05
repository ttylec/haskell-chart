-----------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.Chart.Axis.Int
-- Copyright   :  (c) Tim Docker 2010
-- License     :  BSD-style (see chart/COPYRIGHT)
--
-- Calculate and render integer indexed axes

{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Graphics.Rendering.Chart.Axis.Int(
    defaultIntAxis,
    scaledIntAxis,
    autoScaledIntAxis
) where

import Data.List(genericLength)
import Graphics.Rendering.Chart.Geometry
import Graphics.Rendering.Chart.Drawing
import Graphics.Rendering.Chart.Axis.Types
import Graphics.Rendering.Chart.Axis.Floating

instance PlotValue Int where
    toValue    = fromIntegral
    fromValue  = round
    autoAxis   = autoScaledIntAxis defaultIntAxis

instance PlotValue Integer where
    toValue    = fromIntegral
    fromValue  = round
    autoAxis   = autoScaledIntAxis defaultIntAxis

defaultIntAxis :: (Show a) => LinearAxisParams a
defaultIntAxis  = LinearAxisParams {
    la_labelf_  = show,
    la_nLabels_ = 5,
    la_nTicks_  = 10
}

autoScaledIntAxis :: (Integral i, PlotValue i) =>
                     LinearAxisParams i -> AxisFn i
autoScaledIntAxis lap ps = scaledIntAxis lap (min,max) ps
  where
    (min,max) = (minimum ps,maximum ps)

scaledIntAxis :: (Integral i, PlotValue i) =>
                 LinearAxisParams i -> (i,i) -> AxisFn i
scaledIntAxis lap (min,max) ps =
    makeAxis (la_labelf_ lap) (labelvs,tickvs,gridvs)
  where
    range []  = (0,1)
    range _   | min == max = (fromIntegral $ min-1, fromIntegral $ min+1)
              | otherwise  = (fromIntegral $ min,   fromIntegral $ max)
--  labelvs  :: [i]
    labelvs   = stepsInt (fromIntegral $ la_nLabels_ lap) r
    tickvs    = stepsInt (fromIntegral $ la_nTicks_ lap)
                                  ( fromIntegral $ minimum labelvs
                                  , fromIntegral $ maximum labelvs )
    gridvs    = labelvs
    r         = range ps

stepsInt :: Integral a => a -> Range -> [a]
stepsInt nSteps range = bestSize (goodness alt0) alt0 alts
  where
    bestSize n a (a':as) = let n' = goodness a' in
                           if n' < n then bestSize n' a' as else a

    goodness vs          = abs (genericLength vs - nSteps)

    (alt0:alts)          = map (\n -> steps n range) sampleSteps

    sampleSteps          = [1,2,5] ++ sampleSteps1
    sampleSteps1         = [10,20,25,50] ++ map (*10) sampleSteps1

    steps size (min,max) = takeWhile (<b) [a,a+size..] ++ [b]
      where
        a = (floor   (min / fromIntegral size)) * size
        b = (ceiling (max / fromIntegral size)) * size

