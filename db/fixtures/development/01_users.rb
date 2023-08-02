User.seed do |s|
  s.id = "1"
  s.name = "operation"
  s.uid = "V8RP1QIUm7Pe8raVk0rXfwGjhr72"
  s.role = :admin
  s.is_student = true
  s.greeting = "よろしくだぞ！！！！"
end


69.times do |i|
  User.seed do |s|
    s.id = i + 1
    s.name = SecureRandom.alphanumeric(10) 
    s.uid =  SecureRandom.hex(10)
    s.role = :general
    s.is_student = true
    s.greeting = "よろしくだぞ！！！！"
  end
end

