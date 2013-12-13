eggdrop-quark
=============

REQUIREMENTS: Tcl 8.5, json.tcl (apt-get install tcllibs)

This started as a plugin to display prices for quarkcoins, but it became a plugin that can display prices for anything on bter.com or cryptsy.com. For supported coins this plugin will display high/low/last in BTC and in USD (derived from BTC through mtgox exchange rate) and volumes. It will display this data from BOTH bter.com and cryptsy.com if both sites support the coin, or from only one or the other.

This is a hack job. This code is full of repetition and expediencies. You have been warned.

"Quick" getting-started instructions

Place both the .tcl and .py file in your eggdrop scripts directory.

Get a cryptsy account. Go to your user settings page. Turn ON api access and copy down your two keys, private and API/public. Edit cryptsy.py, inserting your keys where indicated.

Edit eggdrop-quark.tcl - replace all occurrences of '/home/USER/eggdrop/scripts/cryptsy.py' with the actual path to cryptsy.py on your system.

add eggdrop-quark.tcl to your eggdrop.conf and rehash. That's it!