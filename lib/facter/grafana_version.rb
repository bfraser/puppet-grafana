if  FileTest.exists?("/usr/bin/dpkg-query")
	Facter.add("grafana_version") do
		setcode do
			%x{/usr/bin/dpkg-query -W -f='${Version}' grafana}
		end
	end
end
