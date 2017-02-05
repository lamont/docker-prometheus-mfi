docker & sinatra % monitoring mfi mPower
========================================

Alpha software. Currently does not report power usage correctly, changing
approaches. Does export network stats (everything in mca-dump) in prometheus
expected /metric format

I started with https://github.com/luisbebop/docker-sinatra-hello-world
to get a working sinatra + docker setup and am now working on the 
app itself.

```
lamont@docker1:~/docker-prometheus-mfi$ sudo ./run.sh
21:24:11 web.1  | started with pid 7
21:24:17 web.1  | [2017-02-05 21:24:17] INFO  WEBrick 1.3.1
21:24:17 web.1  | [2017-02-05 21:24:17] INFO  ruby 2.3.1 (2016-04-26) [x86_64-linux-musl]
21:24:17 web.1  | == Sinatra (v1.4.7) has taken the stage on 5000 for development with backup from WEBrick
21:24:17 web.1  | [2017-02-05 21:24:17] INFO  WEBrick::HTTPServer#start: pid=7 port=5000
```
and since I'm remapping the 5000 port (see run.sh)

```
wafer:~ lamont$ curl http://docker1:9401/metrics
# HELP node_network_receive_bytes Network device statistic receive_bytes
# TYPE node_network_receive_bytes counter
node_network_receive_bytes{mac="XX:XX:XX:XX:XX:XX",device="ath0"} 1449072774
# HELP node_network_receive_drop Network device statistic receive_drop.
# TYPE node_network_receive_drop counter
node_network_receive_drop{mac="04:18:d6:XX:XX:XX",device="ath0"} 0
# HELP node_network_receive_errs Network device statistic receive_errs.
# TYPE node_network_receive_errs counter
node_network_receive_errs{mac="04:18:d6:XX:XX:XX",device="ath0"} 0
# HELP node_network_receive_packets Network device statistic receive_packets.
# TYPE node_network_receive_packets counter
node_network_receive_packets{mac="04:18:d6:XX:XX:XX",device="ath0"} 5410466
# HELP node_network_transmit_bytes Network device statistic transmit_bytes.
# TYPE node_network_transmit_bytes counter
node_network_transmit_bytes{mac="04:18:d6:XX:XX:XX",device="ath0"} 610430756
# HELP node_network_transmit_drop Network device statistic transmit_drop.
# TYPE node_network_transmit_drop counter
node_network_transmit_drop{mac="04:18:d6:XX:XX:XX",device="ath0"} 0
# HELP node_network_transmit_errs Network device statistic transmit_errs.
# TYPE node_network_transmit_errs counter
node_network_transmit_errs{mac="04:18:d6:XX:XX:XX",device="ath0"} 0
# HELP node_network_transmit_packets Network device statistic transmit_packets.
# TYPE node_network_transmit_packets counter
node_network_transmit_packets{mac="04:18:d6:XX:XX:XX",device="ath0"} 1980865

# HELP mfi_outlet_rms_sum watt hours
# TYPE mfi_outlet_rms_sum counter
```
The containerized sinatra app responds on the /metrics endpoint which
triggers ssh runs into a mpower outlet and runs mca-dump. Those
metrics will be massaged into counters for prometheus to track.

I really tried getting webui calls to work against the controller but nothing
wanted to expose the raw energy counter. I'm looking for a
non-decreasing counter to decouple the measurements from the frequency
of polling. This approach requires you to manage the list of outlets in use (and map/label
them) but does not rely on a EOL'd central controller java app.

Currently the ssh command executed on the outlet is mca-dump, which 
has interface stats and wifi counters, but only occasionally 
reports the outlet power stats as an array entry under the
"alarms" top level key.  Presumably this has to do something
with how the controller has configured the outlet, but I found
an easier way to get my info.

The linux device running inside the outlet has a helpful
/proc/power/ tree and inside are some counters for what
I want /proc/power/energy_sum1 and energy_sum2. So I'll tweak the ssh commands to 
give me that as well as all the internal counters I'm getting from mca-dump


