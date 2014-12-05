name             "sabnzbd"
maintainer       "Alex Howells"
maintainer_email "alex@howells.me"
license          "Apache 2.0"
description      "Installs and configures sabnzbd onto a node"
version          "1.1.1"

%w{ ubuntu }.each do |os|
  supports os
end

depends "bluepill"
depends "git"
