{-# LANGUAGE DeriveDataTypeable, PatternGuards, FlexibleInstances, MultiParamTypeClasses, TypeSynonymInstances, FlexibleContexts, NoMonomorphismRestriction #-}
import Data.List ( partition )
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.LayoutModifier
import XMonad.Layout.NoBorders
import XMonad.Prompt
import qualified XMonad.StackSet as S
import XMonad.Util.EZConfig

data Maximize a = Maximize (Maybe Window) deriving ( Read, Show )
maximize :: LayoutClass l Window => l Window -> ModifiedLayout Maximize l Window
maximize = ModifiedLayout $ Maximize Nothing

data MaximizeRestore = MaximizeRestore Window deriving ( Typeable, Eq )
instance Message MaximizeRestore
maximizeRestore :: Window -> MaximizeRestore
maximizeRestore = MaximizeRestore

instance LayoutModifier Maximize Window where
    modifierDescription (Maximize _) = "Maximize"
    pureModifier (Maximize (Just target)) rect (Just (S.Stack focused _ _)) wrs =
            if focused == target
                then (maxed ++ rest, Nothing)
                else (rest ++ maxed, lay)
        where
            (toMax, rest) = partition (\(w, _) -> w == target) wrs
            maxed = map (\(w, _) -> (w, maxRect)) toMax
            maxRect = Rectangle (rect_x rect + 2) (rect_y rect + 2)
                (rect_width rect - 4) (rect_height rect - 4)
            lay | null maxed = Just (Maximize Nothing)
                | otherwise  = Nothing
    pureModifier _ _ _ wrs = (wrs, Nothing)

    pureMess (Maximize mw) m = case fromMessage m of
        Just (MaximizeRestore w) -> case mw of
            Just w' -> if (w == w')
                        then Just $ Maximize Nothing   -- restore window
                        else Just $ Maximize $ Just w  -- maximize different window
            Nothing -> Just $ Maximize $ Just w        -- maximize window
        _ -> Nothing



tall_ = maximize $ Tall 1 (3/100) (1/2)

myLayoutHook = avoidStruts $ smartBorders $ tall_ ||| Full

wmWindowRole = stringProperty "WM_WINDOW_ROLE"
myManageHook =
    composeOne [ className =? "Xfce4-notifyd" -?> doIgnore
               , wmWindowRole =? "GtkFileChoserDialog" -?> doCenterFloat
               ] 

conf = ewmh $ withUrgencyHook NoUrgencyHook $ defaultConfig
  { focusFollowsMouse=True
  , focusedBorderColor = "red"
  , normalBorderColor = "black"
  , terminal = "urxvtcd"
  , modMask = mod4Mask
  , manageHook = myManageHook <+> manageDocks <+> manageHook defaultConfig
  , layoutHook = myLayoutHook
  , logHook = ewmhDesktopsLogHook >> setWMName "LG3D"
  }
  `additionalKeysP`
  [ ("M-r", spawn "dmenu_run")
  , ("M-w", prevScreen)
  , ("M-e", nextScreen)
  , ("M-m", withFocused (sendMessage . maximizeRestore))
  ]

main = xmonad =<< xmobar conf
