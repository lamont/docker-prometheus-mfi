docker & sinatra % monitoring mfi mPower
========================================

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

