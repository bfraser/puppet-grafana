# == Function get_sub_paths
#
# This function receives an input path as an input parameter, and
# returns an array of the subpaths in the input, excluding the input
# path itself. The function will attempt to ignore any extra slashes
# in the path given.
#
# This function will only work on UNIX paths with forward slashes (/).
#
# Examples:
# input = '/var/lib/grafana/dashboards'
# output = [ '/var', '/var/lib', '/var/lib/grafana'/ ]
#
# input = '/opt'
# output = []
#
# input = '/first/second/'
# output = [ '/first' ]
Puppet::Functions.create_function(:'get_sub_paths') do
  dispatch :get_sub_paths do
    param 'String', :inputpath
    return_type 'Array'
  end

  def get_sub_paths(inputpath)
    ip = inputpath.gsub(/\/+/,"/")
    allsubs = Array.new
    parts = ip.split('/')
    parts.each_with_index do |value, index|
      if (index==0) or (index==(parts.length-1))
        next
      end

      if index==1
        allsubs << '/' + value
      else
        allsubs << allsubs[index-2] + '/' + value
      end
    end
    return allsubs
  end

end
