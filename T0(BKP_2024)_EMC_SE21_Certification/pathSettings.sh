#!/bin/sh

echo "copy and paste:"
echo ' PATH=$PATH:$(pwd)  '
echo "initial PATH  $PATH"
PATH=$PATH:$(pwd)
echo "should become $PATH"
echo 'check it by calling echo $PATH '


