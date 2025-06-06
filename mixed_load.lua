-- tests/wrk_scripts/mixed_load.lua
-- Alternates between regression and classification requests
wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

local request_count = 0

-- Use host.docker.internal for Docker environments, or get from environment
local regression_url = os.getenv("REGRESSION_URL") or "http://host.docker.internal:30001/predict"
local classification_url = os.getenv("CLASSIFICATION_URL") or "http://host.docker.internal:30002/predict"

init = function(args)
    -- Initialize random seed
    math.randomseed(os.time())
    print("Mixed load test initialized")
    print("Regression URL:", regression_url)
    print("Classification URL:", classification_url)
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
        return wrk.format("POST", regression_url, nil, body)
    else
        -- Classification request (4 features)
        local feature1 = math.random() * 4 - 2
        local feature2 = math.random() * 4 - 2
        local feature3 = math.random() * 4 - 2
        local feature4 = math.random() * 4 - 2
        local body = string.format('{"features": [%.3f, %.3f, %.3f, %.3f]}', 
                                  feature1, feature2, feature3, feature4)
        return wrk.format("POST", classification_url, nil, body)
    end
end

done = function(summary, latency, requests)
    print("\nMixed Load Test Results:")
    print("========================")
    print("Total Requests:", summary.requests)
    print("Duration:", summary.duration / 1000000, "seconds") 
    print("RPS:", summary.requests / (summary.duration / 1000000))
    print("Avg Latency:", latency.mean / 1000, "ms")
    print("99th Percentile:", latency:percentile(99) / 1000, "ms")
end