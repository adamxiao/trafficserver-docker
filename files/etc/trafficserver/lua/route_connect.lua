function do_global_pre_remap()
	local method = ts.client_request.get_method()
	if not method or method ~= 'CONNECT' then
		return
	end

	local url_host = ts.client_request.get_url_host()
	if url_host == 'www.baidu.com' then
		return
	end

	-- finally route method CONNECT to self, for certifier middle-in-man
	ts.server_request.server_addr.set_addr("127.0.0.1", 8443, TS_LUA_AF_INET)
	--ts.debug('route_connect', 'route CONNECT to self: ' .. url_host)
end
