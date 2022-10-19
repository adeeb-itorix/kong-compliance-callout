
local http = require "resty.http"

local complianceCallout = {
  PRIORITY = 1000, 
  VERSION = "0.1",
}

local compliancePayload = {
  request = {},
  response = {}
}
local resData = {}

function complianceCallout:init_worker()
  kong.log.debug("saying hi from the 'init_worker' handler")
end

function complianceCallout:access(conf)
  kong.log.inspect(conf)

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
  local reqData = {}

  reqData.headerParams = headerParams
  reqData.queryParams = queryParams
  reqData.formParams = formParams
  reqData.hostname = hostname
  reqData.verb = verb
  reqData.path = path
  reqData.requestBody = requestBody

  compliancePayload.request = reqData

  
end

function complianceCallout:response(conf)
  local resHeaders = kong.response.get_headers()
  local statusCode = kong.response.get_status()
  resData.headerParams = resHeaders
  resData.statusCode = statusCode
  resData.body = kong.response.get_body()
  compliancePayload.response = resData

  local res, err = client:request_uri(conf.target, {
    method = "POST",
    body = compliancePayload,
  })

  kong.response.set_header("compliance-callout-response",res)
end


return complianceCallout
