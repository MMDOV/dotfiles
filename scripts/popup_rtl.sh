#!/bin/bash

wl-paste --no-newline >/tmp/rtl_content

CSS_THEME="
/* 1. The Nuclear Reset: Force EVERYTHING to your dark color */
* {
    background-color: #1a1b26;
    background-image: none;
    border: none;
    box-shadow: none;
}

/* 2. Re-apply the Blue Border to the main window only */
window {
    border: 2px solid #33aaffee; 
}

/* 3. Ensure Text Color is correct */
textview text {
    color: #cdd6f4;
    background-color: #1a1b26;
}

/* 4. Fix Selection Colors */
selection {
    background-color: #585b70;
    color: #cdd6f4;
}"

yad --text-info \
  --filename=/tmp/rtl_content \
  --title="RTL_Popup" \
  --undecorated \
  --no-buttons \
  --escape-ok \
  --justify=right \
  --fontname="Fira Code 12" \
  --margins=20 \
  --width=600 \
  --height=150 \
  --css="$CSS_THEME" \
  --borders=0
