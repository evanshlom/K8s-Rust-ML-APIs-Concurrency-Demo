-- tests/wrk_scripts/mixed_load.lua
-- Alternates between regression and classification requests with FORCED VISUAL FEEDBACK
wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

local request_count = 0

init = function(args)
    math.randomseed(os.time())
    print("=== 🚀 MIXED LOAD TEST STARTING 🚀 ===")
    print("🔄 ALTERNATING between REGRESSION and CLASSIFICATION APIs")
    print("📊 Regression API: 3 features")
    print("🤖 Classification API: 4 features") 
    print("========================================")
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
        
        -- Force output for every request to show activity
        print("🔹 REQ #" .. request_count .. " ➡️  REGRESSION")
        
        return wrk.format("POST", "http://host.docker.internal:30001/predict", 
                         {["Content-Type"] = "application/json"}, body)
    else
        -- Classification request (4 features)
        local feature1 = math.random() * 4 - 2
        local feature2 = math.random() * 4 - 2
        local feature3 = math.random() * 4 - 2
        local feature4 = math.random() * 4 - 2
        local body = string.format('{"features": [%.3f, %.3f, %.3f, %.3f]}', 
                                  feature1, feature2, feature3, feature4)
        
        -- Force output for every request to show activity
        print("🔸 REQ #" .. request_count .. " ➡️  CLASSIFICATION")
        
        return wrk.format("POST", "http://host.docker.internal:30002/predict", 
                         {["Content-Type"] = "application/json"}, body)
    end
end

done = function(summary, latency, requests)
    print("\n🏁 MIXED LOAD TEST COMPLETED!")
    print("========================================")
    print("📊 Total Requests: " .. summary.requests)
    print("✅ All Successful: " .. (summary.requests - summary.errors.status))
    print("⏱️  Duration: " .. (summary.duration / 1000000) .. " seconds")
    print("🚀 RPS: " .. (summary.requests / (summary.duration / 1000000)))
    print("⚡ Avg Latency: " .. (latency.mean / 1000) .. " ms")
    print("========================================")
    print("🎬 Demo complete - both APIs tested concurrently!")
end