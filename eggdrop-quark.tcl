# Copyright (c) 2013 David Moore. All rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

package require Tcl 8.5
package require http
package require tls
package require json

# Comment out the 'bind pub' line for any commands you don't want to use

bind pub - !qrk quark
bind pub - !xpm prime
bind pub - !pts proto
bind pub - !ppc peer
bind pub - !nmc name
bind pub - !wdc world
bind pub - !mec mega
bind pub - !ftc feather
bind pub - !nvc nova
bind pub - !fst fast
bind pub - !arg argentum

http::register https 443 [list ::tls::socket -require 0 -request 1]
proc s:wget { url } {
   http::config -useragent "Mozilla/EggdropWget"
   catch {set token [http::geturl $url -binary 1 -timeout 10000]} error
   if {![string match -nocase "::http::*" $error]} {
      putserv "PRIVMSG $chan: Error: [string totitle [string map {"\n" " | "} $error]] \( $url \)"
      s:debug "Error: [string totitle [string map {"\n" " | "} $error]] \( $url \)"
      return 0
   }
   if {![string equal -nocase [::http::status $token] "ok"]} {
      putserv "PRIVMSG $chan: Http error: [string totitle [::http::status $token]] \( $url \)"
      s:debug "Http error: [string totitle [::http::status $token]] \( $url \)"
      http::cleanup $token
      return 0
   }
   if {[string match "*[http::ncode $token]*" "303|302|301" ]} {
      upvar #0 $token state
      foreach {name value} $state(meta) {
         if {[regexp -nocase ^location$ $name]} {
            if {![string match "http*" $value]} {
               if {![string match "/" [string index $value 0]]} {
                  set value "[join [lrange [split $url "/"] 0 2] "/"]/$value"
               } else {
                  set value "[join [lrange [split $url "/"] 0 2] "/"]$value"
               }
            }
            s:wget $value
            return
         }
      }
   }
   if {[string match 4* [http::ncode $token]] || [string match 5* [http::ncode $token]]} {
      putserv "PRIVMSG $chan: Http resource is not evailable: [http::ncode $token] \( $url \)"
      s:debug "Http resource is not evailable: [http::ncode $token] \( $url \)"
      return 0
   }
    set data [http::data $token]
    http::cleanup $token
    return $data
}

proc quark {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/qrk_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set qrklast [dict get $bter last]
   set qrkhigh [dict get $bter high]
   set qrklow [dict get $bter low]
   set qrkvol [dict get $bter vol_qrk]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $qrklast * $btclast]]
   set usdhigh [format "%.3f" [expr $qrkhigh * $btchigh]]
   set usdlow [format "%.3f" [expr $qrklow * $btclow]]
   putserv "PRIVMSG $chan :QRK->USD \002bter\002/mtgox: Last: \$$usdlast - High: \$$usdhigh - Low: \$$usdlow // QRK->BTC \002bter.com\002: Last: $qrklast - High: $qrkhigh - Low: $qrklow - Volume QRK: $qrkvol - Volume BTC: $btcvol"
   
   set currpair QRK/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"
   
}

proc prime {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/xpm_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set xpmlast [dict get $bter last]
   set xpmhigh [dict get $bter high]
   set xpmlow [dict get $bter low]
   set xpmvol [dict get $bter vol_xpm]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $xpmlast * $btclast]]
   set usdhigh [format "%.3f" [expr $xpmhigh * $btchigh]]
   set usdlow [format "%.3f" [expr $xpmlow * $btclow]]
   putserv "PRIVMSG $chan :XPM->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // XPM->BTC bter.com: Last: $xpmlast - High: $xpmhigh - Low: $xpmlow - Volume XPM: $xpmvol - Volume BTC: $btcvol"

   set currpair XPM/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc proto {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/pts_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set ptslast [dict get $bter last]
   set ptshigh [dict get $bter high]
   set ptslow [dict get $bter low]
   set ptsvol [dict get $bter vol_pts]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $ptslast * $btclast]]
   set usdhigh [format "%.3f" [expr $ptshigh * $btchigh]]
   set usdlow [format "%.3f" [expr $ptslow * $btclow]]
   putserv "PRIVMSG $chan :PTS->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // PTS->BTC \002bter.com\002: Last: $ptslast - High: $ptshigh - Low: $ptslow - Volume PTS: $ptsvol - Volume BTC: $btcvol"

   set currpair PTS/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc peer {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/ppc_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set ppclast [dict get $bter last]
   set ppchigh [dict get $bter high]
   set ppclow [dict get $bter low]
   set ppcvol [dict get $bter vol_ppc]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $ppclast * $btclast]]
   set usdhigh [format "%.3f" [expr $ppchigh * $btchigh]]
   set usdlow [format "%.3f" [expr $ppclow * $btclow]]
   putserv "PRIVMSG $chan :PPC->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // PPC->BTC \002bter.com\002: Last: $ppclast - High: $ppchigh - Low: $ppclow - Volume PPC: $ppcvol - Volume BTC: $btcvol"

   set currpair PPC/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc name {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/nmc_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set nmclast [dict get $bter last]
   set nmchigh [dict get $bter high]
   set nmclow [dict get $bter low]
   set nmcvol [dict get $bter vol_nmc]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $nmclast * $btclast]]
   set usdhigh [format "%.3f" [expr $nmchigh * $btchigh]]
   set usdlow [format "%.3f" [expr $nmclow * $btclow]]
   putserv "PRIVMSG $chan :NMC->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // NMC->BTC \002bter.com\002: Last: $nmclast - High: $nmchigh - Low: $nmclow - Volume NMC: $nmcvol - Volume BTC: $btcvol"

   set currpair NMC/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc world {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/wdc_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set wdclast [dict get $bter last]
   set wdchigh [dict get $bter high]
   set wdclow [dict get $bter low]
   set wdcvol [dict get $bter vol_wdc]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $wdclast * $btclast]]
   set usdhigh [format "%.3f" [expr $wdchigh * $btchigh]]
   set usdlow [format "%.3f" [expr $wdclow * $btclow]]
   putserv "PRIVMSG $chan :WDC->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // WDC->BTC \002bter.com\002: Last: $wdclast - High: $wdchigh - Low: $wdclow - Volume WDC: $wdcvol - Volume BTC: $btcvol"

   set currpair WDC/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc mega {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/mec_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set meclast [dict get $bter last]
   set mechigh [dict get $bter high]
   set meclow [dict get $bter low]
   set mecvol [dict get $bter vol_mec]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $meclast * $btclast]]
   set usdhigh [format "%.3f" [expr $mechigh * $btchigh]]
   set usdlow [format "%.3f" [expr $meclow * $btclow]]
   putserv "PRIVMSG $chan :MEC->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // MEC->BTC \002bter.com\002: Last: $meclast - High: $mechigh - Low: $meclow - Volume MEC: $mecvol - Volume BTC: $btcvol"

   set currpair MEC/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc feather {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/ftc_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set ftclast [dict get $bter last]
   set ftchigh [dict get $bter high]
   set ftclow [dict get $bter low]
   set ftcvol [dict get $bter vol_ftc]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $ftclast * $btclast]]
   set usdhigh [format "%.3f" [expr $ftchigh * $btchigh]]
   set usdlow [format "%.3f" [expr $ftclow * $btclow]]
   putserv "PRIVMSG $chan :FTC->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // FTC->BTC \002bter.com\002: Last: $ftclast - High: $ftchigh - Low: $ftclow - Volume FTC: $ftcvol - Volume BTC: $btcvol"

   set currpair FTC/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc nova {nick uhost handle chan arg} {
   set bterhttp [s:wget https://bter.com/api/1/ticker/nvc_btc ]
   set mtgoxhttp [s:wget https://data.mtgox.com/api/2/BTCUSD/money/ticker ]

   set bter [json::json2dict $bterhttp]
   set mtgox [json::json2dict $mtgoxhttp]

   set nvclast [dict get $bter last]
   set nvchigh [dict get $bter high]
   set nvclow [dict get $bter low]
   set nvcvol [dict get $bter vol_nvc]
   set btcvol [dict get $bter vol_btc]

   set btclast [dict get [dict get [dict get $mtgox data] last_local] value]
   set btchigh [dict get [dict get [dict get $mtgox data] high] value]
   set btclow [dict get [dict get [dict get $mtgox data] low] value]

   set usdlast [format "%.3f" [expr $nvclast * $btclast]]
   set usdhigh [format "%.3f" [expr $nvchigh * $btchigh]]
   set usdlow [format "%.3f" [expr $nvclow * $btclow]]
   putserv "PRIVMSG $chan :NVC->USD \002bter\002/mtgox: Last: $$usdlast - High: \$$usdhigh - Low: \$$usdlow // NVC->BTC \002bter.com\002: Last: $nvclast - High: $nvchigh - Low: $nvclow - Volume NVC: $nvcvol - Volume BTC: $btcvol"

   set currpair NVC/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"

}

proc fast {nick uhost handle chan arg} {
   set currpair FST/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"
}

proc argentum {nick uhost handle chan arg} {
   set currpair ARG/BTC
   set rv [exec python /home/USER/eggdrop/scripts/cryptsy.py $currpair ]
   putserv "PRIVMSG $chan :$rv"
}
