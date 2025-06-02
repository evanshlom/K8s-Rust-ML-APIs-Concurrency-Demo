wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

request = function()
    return wrk.format("POST", "http://host.docker.internal:30001/predict", nil, '{"features": [1.0, 2.0, 3.0]}')
end