Template.seed do |s|
  s.id = 1, 
  s.name = 'シンプル1'
  s.image_path = '/templates/1.png' 
  s.next_path = '/profiles/1'
  s.only_student = false
end

Template.seed do |s|
  s.id = 2, 
  s.name = 'スクール生限定'
  s.image_path = '/templates/2.png'
  s.next_path = '/profiles/2'
  s.only_student = true
end

