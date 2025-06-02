-- tests/wrk_scripts/mixed_load_verbose.lua
-- Alternates between regression and classification requests with verbose output
wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

local request_count = 0
local regression_url = "http://host.docker.internal:30001/predict"
local classification_url = "http://host.docker.internal:30002/predict"

init = function(args)
    math.randomseed(os.time())
    print("Mixed load test initialized - VERBOSE MODE")
    print("Regression URL:", regression_url)
    print("Classification URL:", classification_url)
    print("===========================================")
end

request = function()
    request_count = request_count + 1
    
    if request_count % 2 == 1 then
        -- Regression request (3 features)
        local feature1 = math.random() * 4 - 2
        local feature2 = math.random() * 4 - 2  
        local feature3 = math.random() * 4 - 2
        local body = string.format('{"features": [%.3f, %.3f, %.3f]}', 
                                  feature1, feature2, feature3)
        print(string.format("REQ #%d -> REGRESSION API: %s", request_count, body))
        return wrk.format("POST", regression_url, nil, body)
    else
        -- Classification request (4 features)
        local feature1 = math.random() * 4 - 2
        local feature2 = math.random() * 4 - 2
        local feature3 = math.random() * 4 - 2
        local feature4 = math.random() * 4 - 2
        local body = string.format('{"features": [%.3f, %.3f, %.3f, %.3f]}', 
                                  feature1, feature2, feature3, feature4)
        print(string.format("REQ #%d -> CLASSIFICATION API: %s", request_count, body))
        return wrk.format("POST", classification_url, nil, body)
    end
end

response = function(status, headers, body)
    if request_count <= 20 then  -- Only show first 20 responses to avoid spam
        if request_count % 2 == 1 then
            print(string.format("RESP #%d <- REGRESSION: Status=%d, Body=%s", request_count, status, body))
        else
            print(string.format("RESP #%d <- CLASSIFICATION: Status=%d, Body=%s", request_count, status, body))
        end
    end
end

done = function(summary, latency, requests)
    print("\n===========================================")
    print("Mixed Load Test Results:")
    print("===========================================")
    print("Total Requests:", summary.requests)
    print("Duration:", summary.duration / 1000000, "seconds") 
    print("RPS:", summary.requests / (summary.duration / 1000000))
    print("Avg Latency:", latency.mean / 1000, "ms")
    print("99th Percentile:", latency:percentile(99) / 1000, "ms")
    print("Errors:", summary.errors.connect + summary.errors.read + summary.errors.write + summary.errors.status + summary.errors.timeout)
end