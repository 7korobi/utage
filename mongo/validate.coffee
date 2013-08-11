db.auth('7korobi','kotatsu3');

(->
  check = true
  models = [
    db.auths
    db.users
    db.requests

    db.tags
    db.user_logs

    db.faces
    db.chr_sets

    db.potofs
    db.events
    db.stories
  ]
  for model in models
    check &&= model.validate(full:true).valid

  check
)()
