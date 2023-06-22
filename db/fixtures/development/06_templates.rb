Template.seed do |s|
  s.id = 1, 
  s.name = 'シンプル1'
  s.image_path = '/image1.png' 
  s.next_path = '/next/page/1'
  s.only_student = false
end

Template.seed do |s|
  s.id = 2, 
  s.name = 'スクール生限定'
  s.image_path = '/image2.png'
  s.next_path = '/next/page/2'
  s.only_student = true
end

