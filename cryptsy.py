#!/usr/bin/python

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

import sys
import json
import time
import hmac
import urllib
import urllib2
import hashlib

#GET our currency pair from the .tcl plugin call
ircarg = sys.argv[1]

#PRIVATE KEY FROM CRYPTSY USER SETTINGS
privkey = 'YOUR CRYPTSY PRIVATE KEY HERE'

#PUBLIC KEY FROM SAME SOURCE
apikey = 'YOUR CRYPTSY PUBLIC KEY HERE'

#BTC from MTGOX
btcreq = urllib2.Request("https://data.mtgox.com/api/2/BTCUSD/money/ticker")
btccontent = json.load(urllib2.urlopen(btcreq))
btc = btccontent['data']
btchigh = float(btc['high']['value'])
btclast = float(btc['last_local']['value'])
btclow = float(btc['low']['value'])
btcvol = float(btc['vol']['value'])

#CRYPTSY request preparation
req = dict()
req["method"]='getmarkets'
req["nonce"]=int(time.time())
post_data=urllib.urlencode(req)
sign=hmac.new(privkey, post_data, hashlib.sha512).hexdigest()
headers=["Sign: "+sign, "Key: "+apikey]

#CRYPTSY request
req = urllib2.Request("https://www.cryptsy.com/api")
req.add_data(post_data)
req.add_header('Sign', sign)
req.add_header('Key', apikey)
content = json.load(urllib2.urlopen(req))
for market in content['return']:
    if market['label'] == ircarg.upper():
        high = float(market['high_trade'])
        last = float(market['last_trade'])
        vol = float(market['current_volume'])
        low = float(market['low_trade'])

        usdhigh = high * btchigh
        usdlow = low * btclow
        usdlast = last * btclast

        priAndSec = market['primary_currency_name'] + '/' + market['secondary_currency_name']
        priAndUSD = market['primary_currency_name'] + '/US Dollar'
        priName = market['primary_currency_name']
        pri = market['primary_currency_code']

        print '%s->USD \002cryptsy\002/mtgox.com: Last: $%0.3f - High: $%0.3f - Low: $%0.3f // %s->BTC \002cryptsy.com\002: Last: %0.7f - High: %0.7f - Low: %0.7f - Volume %s: %s - Volume BTC: %s' % \
              (pri, usdlast, usdhigh, usdlow, pri, last, high, low, pri, vol, btcvol)


