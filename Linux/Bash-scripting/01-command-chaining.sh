#!/bin/bash

#  cmd1;cmd2  =  run cmd1 and then cmd2 regardless of the result of cmd1
ls / ; echo "yes"

# cmd1&&cmd2  =  run cmd2 only if cmd1 succedes
ls / && echo "yes"
ls /notexist && echo "will never run"

# cmd1||cmd2  =  run cmd2 only if cmd1 fails
ls / || echo "will never run"
ls /notexist || echo "yes"

# cmd1&&cmd2||cmd3  =  run cmd2 only if cmd1 succedes else run cmd3
ls / && echo "yes" || echo "will never run"
ls /nothing && echo "will never run" || echo "yes"
