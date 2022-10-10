local typedefs = require "kong.db.schema.typedefs"


return {
  name = "kong-compliance-callout",
  fields = {
    { config = 
      {
          type = "record",
          fields = {
            { target = { type = "string" }, },
            { method = { type = "string", default = "GET", one_of = { "POST", "PUT", "PATCH" ,"GET"}, }, },
          },
      },
    },
  },
}
