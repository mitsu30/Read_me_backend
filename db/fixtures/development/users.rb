User.seed(
  :id,
  { id: 1, name: 'admin', uid: 'sample1@exapmle.com', role: :admin, is_student: :true},
  { id: 2, name: 'RUNTEQ', uid: 'sample2@exapmle.com', role: :general, is_student: :true},
  { id: 3, name: 'NORMAL', uid: 'sample3@exapmle.com', role: :general, is_student: :false},
)
