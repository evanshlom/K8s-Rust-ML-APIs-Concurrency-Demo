wrk.method="POST"
wrk.headers["Content-Type"]="application/json"
request=function() return wrk.format(nil,nil,nil,"\"features\":[0.5") wrk.format(nil,nil,nil,"1.2") wrk.format(nil,nil,nil,"-0.8") wrk.format(nil,nil,nil,"1.5]") end
