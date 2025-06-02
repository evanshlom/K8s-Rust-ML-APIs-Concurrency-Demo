wrk.method="POST"
wrk.headers["Content-Type"]="application/json"
request=function() return wrk.format(nil,nil,nil,"\"features\":[1.5") wrk.format(nil,nil,nil,"-0.5") wrk.format(nil,nil,nil,"2.0]") end
