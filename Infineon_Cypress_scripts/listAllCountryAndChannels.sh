#!/bin/bash
freqList=$(wl country list | cut -c1-2)
echo "CY4373 list of countries"
echo
echo ${freqList:2}
echo
echo "List of frequencies for each country"
for XX in ${freqList:2} ; do
  echo -n "$XX: "
  echo -n $(wl channels_in_country $XX b)
  echo -n "       "
  echo $(wl channels_in_country $XX a)
done

