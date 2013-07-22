db.auth('7korobi','kotatsu3');

check = true
models = [
  db.events
  db.stories
  db.users
  db.requests
]
for model in models
  check &&= model.validate(full:true).valid
