docker & sinatra % monitoring mfi mPower
========================================

Alpha software. Currently does not report power usage correctly, changing
approaches

I started with https://github.com/luisbebop/docker-sinatra-hello-world
to get a working sinatra + docker setup and am now working on the 
app itself.

Eventually this will expose a prometheus /metrics endpoint which
will trigger ssh runs into a mpower outlet and run mca-dump. Those
metrics will be massaged into counters for prometheus to track

I really tried getting the controller or web calls to work but nothing
wanted to expose the raw energy counter and I'm looking for a
non-decreasing counter to decouple the measurements from the frequency
of polling

Currently the ssh command executed on the outlet is mca-dump, which 
has interface stats and wifi counters, but only occasionally 
reports the outlet power stats as an array entry under the
"alarms" top level key.  Presumably this has to do something
with how the controller has configured the outlet, but I found
an easier way to get my info.

The linux device running inside the outlet has a helpful
/proc/power/ tree and inside are some counters for what
I want /proc/power/energy_sum1 and energy_sum2


