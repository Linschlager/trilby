module Trilby.Config.Host where

import Internal.Prelude
import Trilby.Config.Channel
import Trilby.Config.Edition
import Trilby.Config.User
import Trilby.HNix (canonicalSet)

data Keyboard = Keyboard
    { layout :: !Text
    , variant :: !(Maybe Text)
    }
    deriving stock (Generic)

instance ToExpr Keyboard where
    toExpr Keyboard{..} =
        [nix|
        {
            layout = layout;
            variant = variant;
        }
        |]
            & canonicalSet

data Host = Host
    { hostname :: !Text
    , edition :: !Edition
    , channel :: !Channel
    , keyboard :: !Keyboard
    , locale :: !Text
    , timezone :: !Text
    , user :: !User
    }
    deriving stock (Generic)

instance ToExpr Host where
    toExpr Host{..} =
        [nix|
        { lib, ... }:

        {
          imports = [
            (import userModule { inherit lib; })
          ];
          networking.hostName = hostname;
          time.timeZone = timezone;
          i18n = rec {
            defaultLocale = locale;
            extraLocaleSettings.LC_ALL = defaultLocale;
          };
          services.xserver.xkb = keyboard;
        }
        |]
      where
        userModule :: NExpr
        userModule = fromText $ "../../users/" <> user.username
