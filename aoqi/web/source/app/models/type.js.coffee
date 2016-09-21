App.Type = DS.Model.extend
  name: DS.attr("string")
  name2: DS.attr("string")

  heroes: DS.hasMany("App.Hero")
