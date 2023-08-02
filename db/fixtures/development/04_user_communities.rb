UserCommunity.seed do |s|
  s.id = 1
  s.user_id = "1"
  s.community_id = 1
end

69.times do |i|
  UserCommunity.seed do |s|
    s.id = i + 1
    s.user_id = i + 1
    s.community_id = 1
  end
end

