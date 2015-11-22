#!/bin/bash

# font: http://patorjk.com/software/taag/#p=display&f=Slant&t=Mediacenter
cat <<EOF | sudo tee /etc/motd
    __  ___         ___                       __           
   /  |/  /__  ____/ (_)___ _________  ____  / /____  _____
  / /|_/ / _ \/ __  / / __ `/ ___/ _ \/ __ \/ __/ _ \/ ___/
 / /  / /  __/ /_/ / / /_/ / /__/  __/ / / / /_/  __/ /    
/_/  /_/\___/\__,_/_/\__,_/\___/\___/_/ /_/\__/\___/_/                                                                
Info: https://github.com/alombarte/raspberry-osmc-automated

EOF
