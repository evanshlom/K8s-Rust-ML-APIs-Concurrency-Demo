-- tests/wrk_scripts/classification.lua
wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

-- Generate random features for each request (4 features for classification)
request = function()
    local feature1 = math.random() * 4 - 2  -- Random between -2 and 2
    local feature2 = math.random() * 4 - 2
    local feature3 = math.random() * 4 - 2
    local feature4 = math.random() * 4 - 2
    
    local body = string.format('{"features": [%.3f, %.3f, %.3f, %.3f]}', 
                              feature1, feature2, feature3, feature4)
    return wrk.format(nil, nil, nil, body)
end

-- Track predictions distribution
local predictions = {[0] = 0, [1] = 0}
local errors = 0

response = function(status, headers, body)
    if status == 200 then
        -- Parse JSON to extract prediction (simple pattern matching)
        local pred = body:match('"prediction":(%d+)')
        if pred then
            local prediction = tonumber(pred)
            predictions[prediction] = predictions[prediction] + 1
        end
    else
        errors = errors + 1
        print("Error response:", status, body)
    end
end

done = function(summary, latency, requests)
    print("\nClassification API Results:")
    print("===========================")
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
    
    print("\nPrediction Distribution:")
    local total_predictions = predictions[0] + predictions[1]
    if total_predictions > 0 then
        print("Class 0:", predictions[0], string.format("(%.1f%%)", predictions[0]/total_predictions*100))
        print("Class 1:", predictions[1], string.format("(%.1f%%)", predictions[1]/total_predictions*100))
    end
end