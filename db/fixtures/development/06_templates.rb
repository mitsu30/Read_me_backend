Template.seed do |s|
  s.id = 1, 
  s.name = 'みにまむ'
  s.image_path = '/templates/minimum.png' 
  s.next_path = '/profiles/minimum'
  s.only_student = false
end

Template.seed do |s|
  s.id = 2, 
  s.name = 'べーしっく'
  s.image_path = '/templates/basic.png'
  s.next_path = '/profiles/basic'
  s.only_student = false
end

Template.seed do |s|
  s.id = 3, 
  s.name = 'すくーる'
  s.image_path = '/templates/school.png'
  s.next_path = '/profiles/school'
  s.only_student = true
end



