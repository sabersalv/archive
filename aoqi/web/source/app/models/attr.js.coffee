App.Attr = DS.Model.extend
  name: DS.attr("string")
  name2: DS.attr("string")

  heroes: DS.hasMany("App.Hero")
  attack_add: DS.hasMany("App.Attr")
  attack_reduce: DS.hasMany("App.Attr")
  defence_reduce: DS.hasMany("App.Attr")
  defence_add: DS.hasMany("App.Attr")
