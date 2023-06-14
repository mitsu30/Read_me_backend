51.times do |i|
  Group.seed do |s|
    s.id = i + 1
    if i < 50
      s.name = "#{i + 1}期"
    else
      s.name = "運営"
    end
    s.community_id = 1
  end
end
