-- MagyArch xmonad.hs configuration
-- {-# OPTIONS_GHC -Wno-deprecations #-}

import XMonad hiding ((|||))
--UTILS
import XMonad.Util.Themes
import XMonad.Util.EZConfig
import System.IO (Handle, hPutStrLn)
import System.Exit
import XMonad.Util.NamedScratchpad

--LAYOUTS
import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen (fullscreenFull)
--import XMonad.Layout.Grid
--import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.DecorationMadness
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
--import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Reflect (reflectHoriz)
--HOOKS
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Minimize
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers(doFullFloat, doCenterFloat, isFullscreen, isDialog)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ServerMode
--DATA
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Monoid
import Control.Monad (liftM2)





-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 3

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask   = mod4Mask

-- Border colors for unfocused and focused windows, respectively.

myNormalBorderColor  = "#1a1a1a"
myFocusedBorderColor = "#2e8b57"

------------------------------------------------------------------------

-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

myLayout = avoidStruts $ smartBorders $ spacingRaw True (Border 5 5 5 5) True (Border 5 5 5 5) True $

           mkToggle (NBFULL ?? NOBORDERS ?? EOT)

           tiled ||| ResizableTall 1 (3/100) (1/2) [] ||| reflectHoriz (ResizableTall 1 (3/100) (1/2) []) ||| ThreeColMid 1 (3/100) (1/2) ||| Full

     where
     -- default tiling algorithm partitions the screen into two panes
     tiled  = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster  = 1

     -- Default proportion of screen occupied by master pane
     ratio  = 1/2

     -- Percent of screen to increment by when resizing panes
     delta  = 3/100

------------------------------------------------------------------------

myScratchPads :: [NamedScratchpad]
myScratchPads = [
    NS "scratchpad" "alacritty --class scratchpad" (resource =? "scratchpad")
        (customFloating $ W.RationalRect (1/4) (1/4) (2/4) (2/4)),

    NS "ncmpcpp" "alacritty --class ncmpcpp -e ncmpcpp" (resource =? "ncmpcpp")
        (customFloating $ W.RationalRect (1/4) (1/4) (2/4) (2/4)),

    NS "pavucontrol" "pavucontrol" (className =? "Pavucontrol")
        (customFloating $ W.RationalRect (1/4) (1/4) (2/4) (2/4))
  ]



-- WORKSPACES

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--

xmobarEscape = concatMap doubleLts
    where doubleLts '<' = "<<"
          doubleLts x = [x]

--myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myWorkspaces = clickable . (map xmobarEscape) $ ["\61612","\61899","\61947","\61635","\61502","\61501","\61705","\61564","\62150","\61872"]
     where
               clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" | (i,ws) <- zip [1..9] l, let n = i ]
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
    , [isFullscreen --> (doF W.focusDown <+> doFullFloat)]
    , [title =? "calcurse"  --> doFloat]
    , [resource =? "Downloads" --> doFloat]
    , [resource =? "Save As..." --> doFloat]
    , [resource =? "desktop_window" --> doIgnore]
    , [resource =? "sxiv" --> doCenterFloat]
    , [className =? "MEGAsync" --> doCenterFloat]
    , [className =? "Lxappearance" --> doCenterFloat]
    , [className =? "Zathura" --> doCenterFloat]
    , [className =? "Brave-browser" --> doShift (myWorkspaces !! 0) <+> viewShift (myWorkspaces !! 0)]
    , [className =? "discord" --> doShift (myWorkspaces !! 1) <+> viewShift (myWorkspaces !! 1)]
    , [className =? "Subl3"  --> doShift (myWorkspaces !! 2) <+> viewShift (myWorkspaces !! 2)]
    , [className =? "Gimp" --> doShift (myWorkspaces !! 3) <+> viewShift (myWorkspaces !! 3)]
    , [className =? "Vlc" --> doShift (myWorkspaces !! 4) <+> viewShift (myWorkspaces !! 4)]
    , [className =? "mpv" --> doCenterFloat <+> doShift (myWorkspaces !! 5) <+> viewShift (myWorkspaces !! 5)]
    , [className =? "Virtualbox" --> doShift (myWorkspaces !! 6) <+> viewShift (myWorkspaces !! 6)]
    , [className =? "Pcmanfm" --> doShift (myWorkspaces !! 7) <+> viewShift (myWorkspaces !! 7)]
    , [className =? "mkvtoolnix-gui" --> doShift (myWorkspaces !! 8) <+> viewShift (myWorkspaces !! 8)]
    ] where viewShift = doF . liftM2 (.) W.greedyView W.shift


------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.

myEventHook = serverModeEventHook <+> serverModeEventHookCmd <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)  <+> minimizeEventHook






--ewmhDesktopsEventHook = fullscreenEventHook <+> docksEventHook <+> minimizeEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

------------------------------------------------------------------------
-- Command to launch the bar.
myBar = "xmobar"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#2e8b57" "" . wrap "["  "]" }

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = xmonad . ewmhFullscreen . ewmh . docks=<< statusBar myBar myPP toggleStrutsKey  defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.

--defaults :: XConfig ((->) (l a))
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = (myManageHook <+> namedScratchpadManageHook myScratchPads),
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

------------------------------------------------------------------------

-- Key bindings. Add, modify or remove key bindings here

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    -- [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- close focused window
     [ ((modm,               xK_q     ), kill)

    -- toggle noboderfull
    , ((modm, xK_f), sendMessage $ Toggle NBFULL)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    -- , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    -- , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
--    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_m     ), windows W.swapMaster)

    -- Swap the focused window with the next window
     , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
     , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
     , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
     , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
     , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    --  Jump directly to favorite layout
    , ((modm .|. shiftMask, xK_t), sendMessage $ JumpToLayout "Tabbed Simplest") -- jump directly to the Tabbed layout

    , ((modm .|. shiftMask, xK_f), sendMessage $ JumpToLayout "Full")  -- jump directly to the Full layout

    , ((modm .|. shiftMask, xK_g), sendMessage $ JumpToLayout "Grid")

    , ((modm .|. shiftMask, xK_u), sendMessage $ JumpToLayout "Mirror Tall")

    , ((modm .|. shiftMask, xK_z), sendMessage $ JumpToLayout  "ThreeCol")

    -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    , ((modm .|. shiftMask, xK_Return), namedScratchpadAction myScratchPads "scratchpad")
    , ((modm .|. controlMask, xK_h), namedScratchpadAction myScratchPads "pavucontrol")
    , ((modm .|. shiftMask, xK_n), namedScratchpadAction myScratchPads "ncmpcpp")

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    -- , ((modm              , xK_g     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
     -- , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


