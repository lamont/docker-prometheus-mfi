require 'rubygems'
require 'net/ssh'
require 'json'

host = ENV['MFI_HOST']
user = ENV['MFI_USER']
command = 'mca-dump'
# import a key and use that, not a password
password = ENV['MFI_PASS']
command_output = ''
metrics_buffer = ''

Net::SSH.start( host, user, :password => password) do |ssh|
  command_output = ssh.exec!(command)
end

mca = JSON.parse(command_output)
hostname, mac, uptime = mca['hostname'], mca['mac'], mca['uptime']
#puts mac
#puts uptime

# [47] pry(main)> mca['alarm'].map { |m| Hash[ m['index'], m['entries'].select{|s| s['type'] == 'rmsSum'}.first['val'] ] }
# => [{"vpower1"=>3360.3125}, {"vpower2"=>1684.6875}]

rmsSums = mca['alarm'].map { |m| Hash[ m['index'], m['entries'].select{|s| s['type'] == 'rmsSum'}.first['val'] ] }

lables = "mac=\"#{mac}\""

# select anything from if_table that has a non 0.0.0.0 ip
active_if_table = mca['if_table'].select {|i| i['ip'] != '0.0.0.0' }
active_if_table.each do |i|

metrics_buffer << <<EOB
# HELP node_network_receive_bytes Network device statistic receive_bytes
# TYPE node_network_receive_bytes counter
node_network_receive_bytes{#{lables},device="#{i['name']}"} #{i['rx_bytes']}
# HELP node_network_receive_drop Network device statistic receive_drop.
# TYPE node_network_receive_drop counter
node_network_receive_drop{#{lables},device="#{i['name']}"} #{i['rx_dropped']}
# HELP node_network_receive_errs Network device statistic receive_errs.
# TYPE node_network_receive_errs counter
node_network_receive_errs{#{lables},device="#{i['name']}"} #{i['rx_errors']}
# HELP node_network_receive_packets Network device statistic receive_packets.
# TYPE node_network_receive_packets counter
node_network_receive_packets{#{lables},device="#{i['name']}"} #{i['rx_packets']}
# HELP node_network_transmit_bytes Network device statistic transmit_bytes.
# TYPE node_network_transmit_bytes counter
node_network_transmit_bytes{#{lables},device="#{i['name']}"} #{i['tx_bytes']}
# HELP node_network_transmit_drop Network device statistic transmit_drop.
# TYPE node_network_transmit_drop counter
node_network_transmit_drop{#{lables},device="#{i['name']}"} #{i['tx_dropped']}
# HELP node_network_transmit_errs Network device statistic transmit_errs.
# TYPE node_network_transmit_errs counter
node_network_transmit_errs{#{lables},device="#{i['name']}"} #{i['tx_errors']}
# HELP node_network_transmit_packets Network device statistic transmit_packets.
# TYPE node_network_transmit_packets counter
node_network_transmit_packets{#{lables},device="#{i['name']}"} #{i['tx_packets']}
EOB

end

metrics_buffer << <<ENDRMS
# HELP outlet_rms_sum watt hours
# TYPE outlet_rms_sum counter
ENDRMS

rmsSums.each do |outlet|
  metrics_buffer << "outlet_rms_sum{#{lables},outlet=\"#{outlet.keys.first}\"} #{outlet.values.first}\n"
end

puts metrics_buffer 

