import Data.Monoid
import System.Exit
import XMonad

import qualified Data.Map as M
import qualified XMonad.StackSet as W

-- LAYOUT
import XMonad.Layout.IndependentScreens
  ( onCurrentScreen
  , withScreens
  , workspaces'
  )
import XMonad.Layout.Spacing (spacing)

-- HOOKS
import XMonad.Hooks.ManageDocks (avoidStruts)

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

--
myBorderWidth = 1

myModMask = mod1Mask

myWorkspaces = withScreens 2 ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

--
myNormalBorderColor = "#dddddd"

myFocusedBorderColor = "#ff0000"

myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- launch a terminal
  [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- launch dmenu
  , ((modm, xK_p), spawn "dmenu_run")
  , ((modm .|. shiftMask, xK_c), kill)
    -- Spawn browser
  , ((modm, xK_u), spawn "brave")
     -- Rotate through the available layout algorithms
  , ((modm, xK_space), sendMessage NextLayout)
    --  Reset the layouts on the current workspace to default
  , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
  , ((modm, xK_n), refresh)
    -- Move focus to the next window
  , ((modm, xK_Tab), windows W.focusDown)
    -- Move focus to the next window
  , ((modm, xK_j), windows W.focusDown)
    -- Move focus to the previous window
  , ((modm, xK_k), windows W.focusUp)
    -- Move focus to the master window
  , ((modm, xK_m), windows W.focusMaster)
    -- Swap the focused window and the master window
  , ((modm, xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
  , ((modm .|. shiftMask, xK_j), windows W.swapDown)
    -- Swap the focused window with the previous window
  , ((modm .|. shiftMask, xK_k), windows W.swapUp)
    -- Shrink the master area
  , ((modm, xK_h), sendMessage Shrink)
    -- Expand the master area
  , ((modm, xK_l), sendMessage Expand)
    -- Push window back into tiling
  , ((modm, xK_t), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
  , ((modm, xK_comma), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
  , ((modm, xK_period), sendMessage (IncMasterN (-1)))
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
    -- Quit xmonad
  , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess))
    -- Restart xmonad
  , ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")
    -- Run xmessage with a summary of the default keybindings (useful for beginners)
  ] ++
  [ ((m .|. modm, k), windows $ onCurrentScreen f i)
  | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9]
  , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]

myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
  [ ( (modm, button1)
    , (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    -- mod-button2, Raise the window to the top of the stack
  , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
  , ( (modm, button3)
    , (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

myLayout = spacing 5 $ avoidStruts $ tiled ||| Mirror tiled ||| Full
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2
    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

myManageHook =
  composeAll
    [ className =? "MPlayer" --> doFloat
    , className =? "Gimp" --> doFloat
    , resource =? "desktop_window" --> doIgnore
    , resource =? "kdesktop" --> doIgnore
    ]

myEventHook = mempty

myLogHook = return ()

myStartupHook = return ()

main = xmonad defaults

defaults =
  def
      -- simple stuff
    { terminal = "alacritty"
    , focusFollowsMouse = myFocusFollowsMouse
    , clickJustFocuses = myClickJustFocuses
    , borderWidth = myBorderWidth
    , modMask = myModMask
    , workspaces = myWorkspaces
    , normalBorderColor = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
      -- key bindings
    , keys = myKeys
    , mouseBindings = myMouseBindings
      -- hooks, layouts
    , layoutHook = myLayout
    , manageHook = myManageHook
    , handleEventHook = myEventHook
    , logHook = myLogHook
    , startupHook = myStartupHook
    }
