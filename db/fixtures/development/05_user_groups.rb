UserGroup.seed do |s|
  s.id = 1
  s.user_id = "1"
  s.group_id = 42 # 40期
end


69.times do |i|
  UserGroup.seed do |s|
    s.id = i + 1
    s.user_id = i + 1
    s.group_id = 40
  end
end
