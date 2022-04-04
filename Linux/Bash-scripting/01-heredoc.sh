#!/bin/bash

cat << EOF
The current user is: $USER
The user's home is: $HOME
EOF

cat << EOF > heredoc
The current user is: $USER
The user's home is: $HOME
EOF

#Heredoc can be used as a comment

<< COMM
Multiline comment
here
COMM
