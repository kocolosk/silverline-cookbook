maintainer        "Librato, Inc."
maintainer_email  "silverline@librato.com"
license           "Apache 2.0"
description       "Installs/Configures Librato Silverline"
version           "0.0.8"

depends 'apt', '>= 1.2.0'

%w{ubuntu debian}.each do |os|
  supports os
end
