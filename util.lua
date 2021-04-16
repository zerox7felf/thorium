return {
    assert = function(ret, retMsg, msg, errCode)
        if ret == nil then
            print(msg)
            print(retMsg)
            os.exit(errCode)
        else
            return ret
        end
    end,
    log = function(msg)
        print("["..os.date().."] "..msg)
    end,
    urlDecode = function(str)
        if str == nil then
            return nil
        else
            return ({str:gsub(
                "%%(%x%x)",
                function(hex)
                    return string.char(tonumber(hex, 16))
                end
            )})[1]
        end
    end,
    -- prune the path from ..s
    prunePath = function(path)
        return ({path:gsub("%.%.","")})[1]
    end,
    fileExtension = function(path)
        return path:match(".+/[^%.]+(%..+)")
    end,
    mimeTypeMappings = {
        [".jpg"] = "Content-Type: image/jpeg",
        [".jpeg"] = "Content-Type: image/jpeg",
        [".png"] = "Content-Type: image/png",
        [".svg"] = "Content-Type: image/svg+xml",
        [".css"] = "Content-Type: text/css; charset=utf-8",
        [".htm"] = "Content-Type: text/html; charset=utf-8",
        [".html"] = "Content-Type: text/html; charset=utf-8",
        [".wav"] = "Content-Type: audio/wav",
        [".ttf"] = "Content-Type: font/ttf"
    }
}
