Rack::Attack.throttle("req/ip", limit: 10, period: 1.minute) do |req|
  req.ip if req.path == "/api/voice_generations" && req.post?
end