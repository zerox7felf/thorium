local socket = require("socket")
local lfs = require("lfs")
local util = require("util")

-- TODO: replace with args
local port = 8888
local address = "*"
local hostDir = lfs.currentdir()

if hostDir:sub(-1) == "/" then
    hostDir = hostDir:sub(1,-2)
end
print("Hosting directory: "..hostDir)

local ret, err = socket.bind(address, port)
local server = util.assert(ret, err, "Unable to bind socket:", 1)

local ip, port = server:getsockname()
util.log("Listening on "..ip..":"..port)

while true do
    local client = server:accept()
    if client ~= nil then
        local clientAddress = client:getpeername()
        util.log("Connection from "..clientAddress)
        client:settimeout(5)

        local lineNo, msg = 1, ""
        local method, path, version = "", "", ""
        while true do
            local line, err = client:receive("*l")
            if line == nil then
                if err == "closed" then
                    util.log(clientAddress.." closed connection.")
                    break
                elseif err == "timeout" then
                    util.log(clientAddress.." timed out.")
                    break
                end
            end

            -- start line
            if lineNo == 1 then
                method, path, version = line:match("([^ ]+) ([^ ]+) HTTP/([1-9.]+)")
                if method == nil then
                    util.log(clientAddress.." invalid start line in request. Closing.")
                    break
                elseif version ~= "1.1" then
                    util.log(clientAddress.." unsupported HTTP version: "..version)
                    client:send("HTTP/1.1 505 HTTP Version Not Supported\n\n")
                    break
                end
            end

            msg = msg.."\n"..line
            lineNo = lineNo + 1
            if line == "" then
                -- reached body section
                -- TODO: not handled yet, needed for post requests.

                -- handle request
                util.log(clientAddress.." "..method.." "..path.." ->")

                path = util.urlDecode(path)
                if path == nil then
                    util.log("HTTP/1.1 400 Bad Request")
                    client:send("HTTP/1.1 400 Bad Request\n\n")
                    break
                else
                    path = util.prunePath(hostDir..path)
                end

                if method == "GET" then
                    -- serve static files
                    local fh, err = io.open(path)
                    if fh == nil then
                        util.log("HTTP/1.1 404 Not Found")
                        client:send("HTTP/1.1 404 Not Found\n\n")
                        break
                    else
                        local content, err = fh:read("*all")
                        fh:close()
                        if content == nil then
                            util.log("HTTP/1.1 404 Not Found")
                            client:send("HTTP/1.1 404 Not Found\n\n")
                            print(err)
                        else
                            util.log("HTTP/1.1 200 OK")
                            local extension = util.fileExtension(path)
                            local mime = util.mimeTypeMappings[extension] or "Content-Type: text/plain"
                            client:send("HTTP/1.1 200 OK\n"..mime.."\n\n"..content)
                        end
                    end
                    break
                elseif method == "HEAD" then
                    -- TODO, this is required
                    util.log("HTTP/1.1 501 Not Implemented")
                    client:send("HTTP/1.1 501 Not Implemented\n\n")
                    break
                else
                    util.log("HTTP/1.1 501 Not Implemented")
                    client:send("HTTP/1.1 501 Not Implemented\n\n")
                    break
                end
                break
            end
        end
    end
    client:close()
end
