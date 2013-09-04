--
-- xmonad.hs - Xmonad configuration file
--
-- Author: Saneyuki Tadokoro <saneyan@mail.gfunction.com>
--
-- Key bindings (meta key is commnad or win):
-- Meta+Enter         switch focused window to master window
-- Meta+Shift+C       close focused window
-- Meta+Shift+Q       close xmonad
-- Meta+Shift+N       switch next workspace
-- Meta+Shift+P       switch previous workspace
-- Meta+Shift+Enter   start a terminal (XTerm)
-- Meta+B             start a web browser (Firefox Nightly)
-- Meta+M             start a mailer (Thunderbird)
-- Meta+K             start a password manager (KeePassX)
-- Meta+C             start a cashier (GnuCash)
-- Meta+S             start a client software of online strage (Wuala)
-- Meta+G             start a paint software (GIMP)
-- Meta+F1            paste a private email address (1)
-- Meta+F2            paste a private email address (2)
-- Meta+F3            paste a public email address
--
-- Startup programs and workspaces:
-- /--------------------------------------------------\
-- | Num  | ID        | Program                       |
-- |------+-----------+-------------------------------|
-- | 1    | > Term    | *XTerm                        |
-- | 2    | > Browser | *Firefox Nightly, Chromium    |
-- | 3    | > Mailer  | *Thunderbird                  |
-- | 4    | > Psmgr   | *KeePassX                     |
-- | 5    | > Cashier | *GnuCash                      |
-- | 6    | > Paint   | GIMP, Inkscape                |
-- | 7    | > Player  | VLC                           |
-- | 8    | > Strage  | Wuala                         |
-- | 9~15 | > 9~F     | (None)                        |
-- \--------------------------------------------------/
-- *) These programs start after staring up xmonad
--

import XMonad
import XMonad.Prompt.Window
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Paste (pasteString)
import XMonad.Actions.SpawnOn (spawnOn, manageSpawn)
import XMonad.Actions.CycleWS (nextWS, prevWS)
import Configs.Private (email)

-- Main --
main :: IO ()
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc.hs"
  xmonad $ defaultConfig {
    -- modMask is "command" key
    modMask = myModMask
  , workspaces = myWorkspaces
  , layoutHook = myLayoutHook
  , manageHook = myManageHook
  , logHook = myLogHook xmproc
  , startupHook = myStartupHook
  , borderWidth = 2
  , normalBorderColor = "#52799e"
  , focusedBorderColor = "#a0bc61"
  , focusFollowsMouse = False
  }
    `additionalKeys`
    myAdditionalKeys

-- Default application --
-- Double size font is IPAPGothic and starting with tmux
myTerm            = "xterm -fd IPAPGothic -fw IPAPGothic -e tmux"
myWebBrowser      = "firefox-nightly"
myPasswordManager = "keepassx"
myMailer          = "thunderbird"
-- Use wuala client software in user directory
myOnlineStrage    = "~/wuala/wuala"
myCashier         = "gnucash"
myPaint           = "gimp"

{-
 - Workspaces
 -}

-- Workspaces --
myWorkspaces :: [WorkspaceId]
-- It should be like "ABC > DEF > GHI > ..."
myWorkspaces = ["> Term", "> Browser", "> Mailer", "> Psmgr", "> Cashier", "> Paint", "> Player", "> Strage", "> 9", "> A", "> B", "> C", "> D", "> E", "> F"]

{-
 - Hooks 
 -}

-- Layout hook --
myLayoutHook = avoidStruts $ layoutHook defaultConfig

-- Manage hook --
myManageHook = composeAll
  [ className =? "XTerm"          --> doShift (myWorkspaces!!0)
  , className =? "Firefox"        --> doShift (myWorkspaces!!1)
  , className =? "Chromium"       --> doShift (myWorkspaces!!1)
  , className =? "Thunderbird"    --> doShift (myWorkspaces!!2)
  , className =? "Keepassx"       --> doShift (myWorkspaces!!3)
  , className =? "Gnucash"        --> doShift (myWorkspaces!!4)
  , className =? "Gimp"           --> doShift (myWorkspaces!!5)
  , className =? "Inkscape"       --> doShift (myWorkspaces!!5)
  , className =? "Vlc"            --> doShift (myWorkspaces!!6)
  , className =? "Wuala"          --> doShift (myWorkspaces!!7)
  , manageSpawn
  , manageDocks
  , manageHook defaultConfig
  ]

-- Log hook --
myLogHook h = dynamicLogWithPP xmobarPP {
  ppOutput = hPutStrLn h
, ppTitle = xmobarColor "#a0bc61" "" . shorten 50
}

-- Startup hook --
myStartupHook :: X ()
myStartupHook = do
  spawnOn (myWorkspaces!!0) myTerm
  spawnOn (myWorkspaces!!1) myWebBrowser
  spawnOn (myWorkspaces!!2) myMailer
  spawnOn (myWorkspaces!!3) myPasswordManager
  spawnOn (myWorkspaces!!4) myCashier

{-
 - Key bindings
 -}

-- Prefix key --
myModMask = mod4Mask
myMSMask  = myModMask .|. shiftMask

-- Additional keys --
myAdditionalKeys =  [
  {-
    b: browser, k: keypass, m: mailer, s: storage
    * Override starting term key binding
  -}
    ((myMSMask, xK_Return), spawn myTerm)
  , ((myModMask, xK_b), spawn myWebBrowser)
  , ((myModMask, xK_k), spawn myPasswordManager)
  , ((myModMask, xK_m), spawn myMailer)
  , ((myModMask, xK_s), spawn myOnlineStrage)
  , ((myModMask, xK_c), spawn myCashier)
  , ((myModMask, xK_g), spawn myPaint)
  , ((myModMask, xK_F1), pasteString $ email "private")
  , ((myModMask, xK_F2), pasteString $ email "service")
  , ((myModMask, xK_F3), pasteString $ email "public")
  , ((myMSMask, xK_n), nextWS)
  , ((myMSMask, xK_p), prevWS)
  ]