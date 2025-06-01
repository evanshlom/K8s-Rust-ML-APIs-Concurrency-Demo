wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

-- Generate random features for each request
request = function()
    local feature1 = math.random() * 4 - 2  -- Random between -2 and 2
    local feature2 = math.random() * 4 - 2
    local feature3 = math.random() * 4 - 2
    
    local body = string.format('{"features": [%.3f, %.3f, %.3f]}', 
                              feature1, feature2, feature3)
    return wrk.format(nil, nil, nil, body)
end

-- Track response statistics
local responses = {}
local errors = 0
local latencies = {}

response = function(status, headers, body)
    if status == 200 then
        responses[#responses + 1] = body
        -- Extract latency from response time
        -- Note: wrk doesn't directly expose per-request latency in Lua
    else
        errors = errors + 1
        print("Error response:", status, body)
    end
end

done = function(summary, latency, requests)
    print("\nRegression API Results:")
    print("======================")
    print("Requests:", summary.requests)
    print("Duration:", summary.duration / 1000000, "seconds")
    print("Bytes:", summary.bytes)
    print("Errors:", summary.errors.read + summary.errors.write + summary.errors.status + summary.errors.timeout)
    print("RPS:", summary.requests / (summary.duration / 1000000))
    
    print("\nLatency Distribution:")
    print("50%:", latency:percentile(50) / 1000, "ms")
    print("90%:", latency:percentile(90) / 1000, "ms")
    print("99%:", latency:percentile(99) / 1000, "ms")
    print("Max:", latency.max / 1000, "ms")
end