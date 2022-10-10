-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------
local http = require "resty.http"


local complianceCallout = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

function complianceCallout:init_worker()
  kong.log.debug("saying hi from the 'init_worker' handler")
end

function complianceCallout:access(conf)
  kong.log.inspect(conf)   -- check the logs for a pretty-printed config!
  local client = http.new()
  local compliancePayload = {}
  local reqData = {}

  -- Request Data
  local headerParams = kong.request.get_headers()
  local queryParams = kong.request.get_query()
  local formParams = {}

  local scheme = kong.request.get_scheme()
  local host = kong.request.get_host()
  local port = kong.request.get_port()
  local verb = kong.request.get_method()
  local path = kong.request.get_raw_path()
  local hostname = kong.request.get_host()

  local requestBody = kong.request.get_body()
  reqData.headerParams = headerParams
  reqData.queryParams = queryParams
  reqData.formParams = formParams
  reqData.hostname = hostname
  reqData.verb = verb
  reqData.path = path
  reqData.requestBody = requestBody

  compliancePayload.request = reqData

  -- Response Data
  local resData = {}
  local resHeaders = kong.response.get_headers()
  local resBody = kong.response.get_raw_body()
  local statusCode = kong.response.get_status()
  resData.headerParams = resHeaders
  resData.responseBody = resBody
  resData.statusCode = statusCode

  compliancePayload.response = resData

  local res, err = client:request_uri(kong.request.get_header('sc-target'), {
    method = kong.request.get_header('sc-method'),
    body = compliancePayload,
  })
  kong.response.set_header("compliance-callout-response",res.body)
end


return complianceCallout
