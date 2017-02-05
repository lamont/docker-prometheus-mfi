class Mfi_exporter

  def initialize
    # is this a reasonable place to tuck these?
    require 'rubygems'
    require 'net/ssh'
    require 'json'
  end

  def metrics(host, user, password)

    command = 'mca-dump'
    command_output = ''
    metrics_buffer = []

    Net::SSH.start(host, user, :password => password) do |ssh|
      command_output = ssh.exec!(command)
    end

    mca = JSON.parse(command_output)
    hostname, mac, uptime = mca['hostname'], mca['mac'], mca['uptime']
    #puts mac
    #puts uptime

    # [47] pry(main)> mca['alarm'].map { |m| Hash[ m['index'], m['entries'].select{|s| s['type'] == 'rmsSum'}.first['val'] ] }
    # => [{"vpower1"=>3360.3125}, {"vpower2"=>1684.6875}]

    labels = "mac=\"#{mac}\""

    # select anything from if_table that has a non 0.0.0.0 ip
    active_if_table = mca['if_table'].select { |i| i['ip'] != '0.0.0.0' }
    active_if_table.each do |i|

      metrics_buffer << <<EOB
# HELP node_network_receive_bytes Network device statistic receive_bytes
# TYPE node_network_receive_bytes counter
node_network_receive_bytes{#{labels},device="#{i['name']}"} #{i['rx_bytes']}
# HELP node_network_receive_drop Network device statistic receive_drop.
# TYPE node_network_receive_drop counter
node_network_receive_drop{#{labels},device="#{i['name']}"} #{i['rx_dropped']}
# HELP node_network_receive_errs Network device statistic receive_errs.
# TYPE node_network_receive_errs counter
node_network_receive_errs{#{labels},device="#{i['name']}"} #{i['rx_errors']}
# HELP node_network_receive_packets Network device statistic receive_packets.
# TYPE node_network_receive_packets counter
node_network_receive_packets{#{labels},device="#{i['name']}"} #{i['rx_packets']}
# HELP node_network_transmit_bytes Network device statistic transmit_bytes.
# TYPE node_network_transmit_bytes counter
node_network_transmit_bytes{#{labels},device="#{i['name']}"} #{i['tx_bytes']}
# HELP node_network_transmit_drop Network device statistic transmit_drop.
# TYPE node_network_transmit_drop counter
node_network_transmit_drop{#{labels},device="#{i['name']}"} #{i['tx_dropped']}
# HELP node_network_transmit_errs Network device statistic transmit_errs.
# TYPE node_network_transmit_errs counter
node_network_transmit_errs{#{labels},device="#{i['name']}"} #{i['tx_errors']}
# HELP node_network_transmit_packets Network device statistic transmit_packets.
# TYPE node_network_transmit_packets counter
node_network_transmit_packets{#{labels},device="#{i['name']}"} #{i['tx_packets']}
EOB

    end

    metrics_buffer << <<ENDRMS
# HELP mfi_outlet_rms_sum watt hours
# TYPE mfi_outlet_rms_sum counter
ENDRMS

    rms_sums = mca['alarm'].map { |m| Hash[m['index'], m['entries'].select { |s| s['type'] == 'rmsSum' }.first['val']] }
    metrics_buffer << rms_sums.map {|m| "mfi_outlet_rms_sum{#{labels},outlet=\"#{m.keys.first}\"} #{m.values.first}" }

    metrics_buffer.reject { |r| r == "\n" }.join("\n")
  end
end