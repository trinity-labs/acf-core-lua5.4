
-- require("acf.fs")
local fs = require("fs")

fs.write_line_file("/var/log/acf.log", "WARNING: old mvc.lua was used")

mvc = require("acf.mvc")
return mvc
