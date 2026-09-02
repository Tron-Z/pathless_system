#!/bin/bash

sudo sed -i  \
"s/autologin-user=.*/#&/"  \
/etc/lightdm/lightdm.conf.d/22-pathless-autologin.conf
