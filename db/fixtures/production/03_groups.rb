Group.seed do |s|
  s.id = 1
  s.name = "運営"
  s.community_id = 1
end

Group.seed do |s|
  s.id = 2
  s.name = "MSコース"
  s.community_id = 1
end

58.times do |i|
  Group.seed do |s|
    s.id = i + 3
    s.name = "#{i + 1}期"
    s.community_id = 1
  end
end
