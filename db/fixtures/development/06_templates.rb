Template.seed do |s|
  s.id = 1, 
  s.name = 'みにまむ'
  s.image_path = '/templates/1.png' 
  s.next_path = '/profiles/1'
  s.only_student = false
end

Template.seed do |s|
  s.id = 2, 
  s.name = 'べーしっく'
  s.image_path = '/templates/2.png'
  s.next_path = '/profiles/2'
  s.only_student = true
end

Template.seed do |s|
  s.id = 3, 
  s.name = 'すくーる'
  s.image_path = '/templates/3.png'
  s.next_path = '/profiles/3'
  s.only_student = true
end



